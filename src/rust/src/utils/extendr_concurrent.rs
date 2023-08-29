use extendr_api::prelude::*;

//use std::sync::mpsc::{Receiver, Sender};
use std::sync::RwLock;
use std::thread;

use flume;
use flume::{Receiver, Sender};

pub use state::InitCell;

//shamelessly make Robj send + sync
//no crashes so far for the 'data'-SEXPS as Vectors, lists, pairlists
//mainly for debug should not be used in production
//CLOSEXP crashes every time
#[derive(Clone, Debug)]
pub struct ParRObj(pub Robj);
unsafe impl Send for ParRObj {}
unsafe impl Sync for ParRObj {}

impl From<Robj> for ParRObj {
    fn from(robj: Robj) -> Self {
        ParRObj(robj)
    }
}

impl std::fmt::Display for ParRObj {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "{:?}", self.0)
    }
}

//ThreadCom allow any subthread to request main thread to e.g. run R code
//main thread handles requests sequentially and return answer to the specific requestee thread

#[derive(Debug)]
pub struct ThreadCom<S, R> {
    mains_tx: Sender<(S, Sender<R>)>,
    child_rx: Receiver<R>,
    child_tx: Sender<R>,
    //counter: std::sync::Arc<std::sync::Mutex<i64>>, //debug threads
}

impl<S, R> Clone for ThreadCom<S, R> {
    //clone only main unbounded, create new unique child unbounded (such that each thread has unique comminucation when main)
    fn clone(&self) -> Self {
        let (tx, rx) = flume::unbounded::<R>();

        // //debug threads
        // {
        //     let mut lock = self.counter.lock().unwrap();
        //     let val = *lock + 1;
        //     dbg!(val);
        //     *lock = val;
        // }
        ThreadCom {
            mains_tx: self.mains_tx.clone(),
            child_rx: rx,
            child_tx: tx,
            // counter: self.counter.clone(), //debug threads
        }
    }
}

impl<S, R> ThreadCom<S, R>
where
    S: Send,
    R: Send,
{
    //return tupple with ThreadCom for child thread and m_rx to stay in main_thread

    pub fn create() -> (Self, Receiver<(S, Sender<R>)>) {
        let (m_tx, m_rx) = flume::unbounded::<(S, Sender<R>)>();
        let (c_tx, c_rx) = flume::unbounded::<R>();
        (
            ThreadCom {
                mains_tx: m_tx,
                child_tx: c_tx,
                child_rx: c_rx,
                //counter: std::sync::Arc::new(Mutex::new(0)), //debug threads
            },
            m_rx,
        )
    }

    //send request to main thread
    pub fn send(&self, s: S) {
        self.mains_tx
            .send((s, self.child_tx.clone()))
            .expect("thread failed send, likely a user interrupt")
    }

    //wait to recieve answer from main thread
    pub fn recv(&self) -> R {
        self.child_rx
            .recv()
            .expect("thread failed recieve, likely a user interrupt")
    }

    pub fn update_global(&self, conf: &InitCell<RwLock<Option<ThreadCom<S, R>>>>)
    where
        S: Send,
        R: Send,
    {
        //set or update global thread_com
        let conf_status = conf.set(RwLock::new(Some(self.clone())));
        //dbg!(conf_status);
        if !conf_status {
            let mut gtc = conf
                .get()
                .write()
                .expect("failed to modify GLOBAL therad_com");
            *gtc = Some(self.clone());
        }
    }

    pub fn kill_global(conf: &InitCell<RwLock<Option<ThreadCom<S, R>>>>) {
        let mut val = conf
            .get()
            .write()
            .expect("another thread crashed while touching CONFIG");
        *val = None;
    }

    pub fn from_global(config: &InitCell<RwLock<Option<ThreadCom<S, R>>>>) -> Self
    where
        S: Send,
        R: Send,
    {
        let thread_com = config
            .get()
            .read()
            .expect("failded to restore thread_com")
            .as_ref()
            .unwrap()
            .clone();

        thread_com
    }

    pub fn try_from_global(
        config: &InitCell<RwLock<Option<ThreadCom<S, R>>>>,
    ) -> std::result::Result<Self, String>
    where
        S: Send,
        R: Send,
    {
        let thread_com = config
            .try_get()
            .ok_or(
                "Failed to communicate with R from polars. \
                It is not possible collect_background a LazyFrame containing user R functions",
            )?
            .read()
            .expect("failded to restore thread_com")
            .as_ref()
            .unwrap()
            .clone();

        Ok(thread_com)
    }
}

// //debug threads
// impl<S, R> Drop for ThreadCom<S, R> {
//     fn drop(&mut self) {
//         let mut lock = self.counter.lock().unwrap();
//         *lock = *lock - 1;
//         let drop_count = *(lock);
//         dbg!(drop_count);
//         println!("Dropping ThreadCom");
//     }
// }

//start serving requests from child threads.
//f is closure of child threads to start, child thread takes an ThreadCom argument
//i is the closure which handles incomming request e.g. execute commands in R interpreter
//conf is a global storage where thread can recover a ThreadCom object from.
pub fn concurrent_handler<F, I, R, S, T>(
    f: F,
    //y: Y,
    i: I,
    conf: &InitCell<RwLock<Option<ThreadCom<S, R>>>>,
) -> std::result::Result<T, Box<dyn std::error::Error>>
where
    F: FnOnce(ThreadCom<S, R>) -> T + Send + 'static,
    I: Fn(S) -> std::result::Result<R, Box<dyn std::error::Error>> + Send + 'static,
    R: Send + 'static + std::fmt::Debug,
    S: Send + 'static,
    T: Send + 'static,
    //Y: FnOnce() -> std::result::Result<Function, Box<dyn std::error::Error>>,
{
    //start new com and clone to global
    let (thread_com, main_rx) = ThreadCom::create();
    thread_com.update_global(conf);

    //execute main closure on first child thread
    let handle = thread::spawn(move || f(thread_com));

    //only for performance diagnostics
    // let mut before = std::time::Instant::now();
    // let mut loop_counter = 0u64;

    //serve any request from child threads until all child_phones are dropped or R interrupt
    loop {
        // loop_counter += 1;
        // let now = std::time::Instant::now();
        // let duration = now - before;
        // before = std::time::Instant::now();
        // dbg!(duration, loop_counter);

        // Wakeup thread on request or disconnect, else wakeup every 1000ms to check R user interrupts.
        // let recv_time = std::time::Instant::now();
        let any_new_msg = main_rx.recv_timeout(std::time::Duration::from_millis(1000));
        // let sleep_time = std::time::Instant::now() - recv_time;
        // dbg!(sleep_time);

        // avoiding unwrap/unwrap_err if msg T does not have trait Debug
        if let Ok(packet) = any_new_msg {
            let (s, c_tx) = packet;
            let answer = i(s); //handle requst with i closure
            let a = answer.map_err(|err| format!("user function raised an error: {:?} \n", err))?;

            c_tx.send(a).unwrap();
        } else if let Err(recv_err) = any_new_msg {
            //dbg!(&recv_err);
            match recv_err {
                //no threadcoms connections left, new request impossible, shut down loop,
                flume::RecvTimeoutError::Disconnected => {
                    break;
                }

                // waking up with no now requests since last
                flume::RecvTimeoutError::Timeout => {
                    //check user interrupts flags in R in a fast high-level way with Sys.sleep(0)
                    let res_res = extendr_api::eval_string("Sys.sleep(0)");
                    //dbg!(&res_res);
                    if res_res.is_err() {
                        rprintln!("R user interrupt");
                        return Err("interupt by user".into());
                    }

                    //check if spawned thread has ended, first child thread should have
                    //dropped the last ThreadComs, so more likely waking up to a disconnect
                    if handle.is_finished() {
                        rprintln!("polars: closing concurrent R handler");
                        break;
                    }
                }
            }
        } else {
            unreachable!("a result was neither error or ok");
        }
    }

    let thread_return_value = handle.join().map_err(|err| {
        format!(
            "A polars sub-thread panicked. See panic msg, which is likely more informative than this error: {:?}",
            err
        )
    })?;

    //let run_time = std::time::Instant::now() - start_time;
    //dbg!(run_time);

    Ok(thread_return_value)
}

use std::thread::JoinHandle;

pub fn start_background_handler<F, T>(
    f: F,
    //y: Y,
) -> JoinHandle<T>
where
    F: FnOnce() -> T + Send + 'static,
    T: Send + 'static,
{
    thread::spawn(f)
}

pub fn join_background_handler<T>(
    handle: JoinHandle<T>,
) -> std::result::Result<T, Box<dyn std::error::Error>>
where
    T: Send + 'static,
{
    let thread_return_value = handle.join().map_err(|err| {
        format!(
            "A polars background thread panicked. See panic msg, which is likely more informative than this error: {:?}",
            err
        )
    })?;

    Ok(thread_return_value)
}
