// ThreadCom allow any subthread to request main thread to e.g. run R code
// main thread handles requests sequentially and return answer to the specific requestee thread
// Copied from https://github.com/pola-rs/r-polars/blob/9572aef7b3c067ffebe124e61d22279674c17871/src/rust/src/utils/extendr_concurrent.rs

use flume::{Receiver, Sender};
use savvy::r_println;
use state::InitCell;
use std::{sync::RwLock, thread};

#[derive(Debug)]
pub struct ThreadCom<S, R> {
    mains_tx: Sender<(S, Sender<R>)>,
    child_rx: Receiver<R>,
    child_tx: Sender<R>,
}

impl<S, R> Clone for ThreadCom<S, R> {
    // clone only main unbounded, create new unique child unbounded
    // (such that each thread has unique comminucation when main)
    fn clone(&self) -> Self {
        let (tx, rx) = flume::unbounded::<R>();
        ThreadCom {
            mains_tx: self.mains_tx.clone(),
            child_rx: rx,
            child_tx: tx,
        }
    }
}

impl<S, R> ThreadCom<S, R>
where
    S: Send,
    R: Send,
{
    // return tupple with ThreadCom for child thread and m_rx to stay in main_thread
    pub fn create() -> (Self, Receiver<(S, Sender<R>)>) {
        let (m_tx, m_rx) = flume::unbounded::<(S, Sender<R>)>();
        let (c_tx, c_rx) = flume::unbounded::<R>();
        (
            ThreadCom {
                mains_tx: m_tx,
                child_tx: c_tx,
                child_rx: c_rx,
            },
            m_rx,
        )
    }

    // send request to main thread
    pub fn send(&self, s: S) {
        self.mains_tx
            .send((s, self.child_tx.clone()))
            .expect("thread failed send, likely a user interrupt")
    }

    // wait to recieve answer from main thread
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
        // set or update global thread_com
        let conf_status = conf.set(RwLock::new(Some(self.clone())));
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

    // TODO: use TryFrom trait instead of this function
    pub fn try_from_global(
        config: &InitCell<RwLock<Option<ThreadCom<S, R>>>>,
    ) -> std::result::Result<Self, String>
    where
        S: Send,
        R: Send,
    {
        let lock = config.try_get();
        let inner_lock = lock
            .ok_or("internal error: global ThreadCom storage has not already been initialized")?
            .read()
            .expect("internal error: RwLock was poisoned (some other thread used the RwLock but panicked)");

        let opt_thread_com = inner_lock.as_ref();

        let thread_com = opt_thread_com
            .ok_or("Global ThreadCom storage is empty")?
            .clone();

        Ok(thread_com)
    }
}

// start serving requests from child threads.
// f is closure of child threads to start, child thread takes an ThreadCom argument
// i is the closure which handles incomming request e.g. execute commands in R interpreter
// conf is a global storage where thread can recover a ThreadCom object from.
pub fn concurrent_handler<F, I, R, S, T>(
    f: F,
    i: I,
    conf: &InitCell<RwLock<Option<ThreadCom<S, R>>>>,
) -> std::result::Result<T, Box<dyn std::error::Error>>
where
    F: FnOnce(ThreadCom<S, R>) -> T + Send + 'static,
    I: Fn(S) -> std::result::Result<R, Box<dyn std::error::Error>> + Send + 'static,
    R: Send + 'static + std::fmt::Debug,
    S: Send + 'static,
    T: Send + 'static,
{
    // start new com and clone to global
    let (thread_com, main_rx) = ThreadCom::create();
    thread_com.update_global(conf);

    // execute main closure on first child thread
    let handle = thread::spawn(move || f(thread_com));

    // serve any request from child threads until all child_phones are dropped or R interrupt
    loop {
        // Wakeup thread on request or disconnect, else wakeup every 1000ms to check R user interrupts.
        let any_new_msg = main_rx.recv_timeout(std::time::Duration::from_millis(1000));

        // avoiding unwrap/unwrap_err if msg T does not have trait Debug
        if let Ok(packet) = any_new_msg {
            let (s, c_tx) = packet;
            let answer = i(s); // handle requst with i closure
            let Ok(a) = answer else {
                // TODO: after this error, map_batches may freeze
                ThreadCom::kill_global(conf);
                return Err("User function raised an error".into());
            };

            c_tx.send(a).unwrap();
        } else if let Err(recv_err) = any_new_msg {
            match recv_err {
                // no threadcoms connections left, new request impossible, shut down loop,
                flume::RecvTimeoutError::Disconnected => {
                    break;
                }

                // waking up with no now requests since last
                flume::RecvTimeoutError::Timeout => {
                    // check user interrupts flags in R in a fast high-level way with Sys.sleep(0)

                    // TODO: uncomment this block
                    // let res_res = extendr_api::eval_string("Sys.sleep(0)");
                    // if res_res.is_err() {
                    //     r_println!("R user interrupt");
                    //     return Err("interupt by user".into());
                    // }

                    // check if spawned thread has ended, first child thread should have
                    // dropped the last ThreadComs, so more likely waking up to a disconnect
                    if handle.is_finished() {
                        r_println!("polars: closing concurrent R handler");
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

    Ok(thread_return_value)
}
