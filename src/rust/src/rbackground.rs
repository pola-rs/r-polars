use crate::rdataframe::DataFrame as RDF;
use crate::robj_to;
use crate::rpolarserr::rerr;
use crate::rpolarserr::{
    extendr_to_rpolars_err, polars_to_rpolars_err, rdbg, RPolarsErr, RResult, Rctx, WithRctx,
};
use extendr_api::{
    call, eval_string, extendr, extendr_module, list, pairlist, symbol::class_symbol, Attributes,
    Conversions, Length, List, Operators, Pairlist, Rinternals, Robj, NULL, R,
};
use flume::{bounded, Sender};
use ipc_channel::ipc;
use once_cell::sync::Lazy;
use polars::prelude::Series as PSeries;
use std::collections::VecDeque;
use std::sync::{Arc, Mutex};
use std::thread;
#[derive(Debug)]
pub struct RThreadHandle<T> {
    handle: Option<thread::JoinHandle<T>>,
}

impl<T: Send + Sync + 'static> RThreadHandle<T> {
    pub fn new(compute: impl FnOnce() -> T + Send + 'static) -> Self {
        RThreadHandle {
            handle: Some(thread::spawn(compute)),
        }
    }

    pub fn thread_description_generic(&self) -> RResult<String> {
        let thread = self.handle.as_ref().ok_or(RPolarsErr::new())?.thread();
        Ok(format!(
            "Handle of thread [{:?}] with ID [{:?}]",
            thread.name().unwrap_or("<anonymous>"),
            thread.id()
        ))
    }

    pub fn join_generic(&mut self) -> RResult<T> {
        use Rctx::*;
        self.handle
            .take()
            .ok_or(RPolarsErr::new())
            .handled()
            .and_then(|handle| {
                handle
                    .join()
                    .map_err(|err| RPolarsErr::new_from_ctx(BadJoin(rdbg(err))))
            })
    }

    pub fn is_finished_generic(&self) -> RResult<bool> {
        self.handle
            .as_ref()
            .ok_or(RPolarsErr::new())
            .handled()
            .map(thread::JoinHandle::is_finished)
    }
}

#[extendr]
impl RThreadHandle<RResult<RDF>> {
    fn join(&mut self) -> RResult<RDF> {
        // Could use *.flatten() when it's stable
        self.join_generic().and_then(std::convert::identity)
    }

    fn is_finished(&self) -> RResult<bool> {
        self.is_finished_generic()
    }

    fn thread_description(&self) -> RResult<String> {
        self.thread_description_generic()
    }
}

pub fn serialize_robj(robj: Robj) -> RResult<Vec<u8>> {
    call!("serialize", &robj, NULL)
        .map_err(RPolarsErr::from)
        .bad_robj(&robj)
        .when("serializing an R object")?
        .as_raw_slice()
        .ok_or(RPolarsErr::new())
        .bad_robj(&robj)
        .when("accessing raw bytes of an serialized R object")
        .map(|bits| bits.to_vec())
}

pub fn deserialize_robj(bits: Vec<u8>) -> RResult<Robj> {
    call!("unserialize", &bits)
        .map_err(RPolarsErr::from)
        .bad_val(rdbg(bits))
        .when("deserializing an R object")
}

pub fn serialize_dataframe(dataframe: &mut polars::prelude::DataFrame) -> RResult<Vec<u8>> {
    use polars::io::SerWriter;

    let mut dump = Vec::new();
    polars::io::ipc::IpcWriter::new(&mut dump)
        .finish(dataframe)
        .map_err(polars_to_rpolars_err)?;
    Ok(dump)
}

pub fn deserialize_dataframe(bits: &[u8]) -> RResult<polars::prelude::DataFrame> {
    use polars::io::SerReader;

    polars::io::ipc::IpcReader::new(std::io::Cursor::new(bits))
        .finish()
        .map_err(polars_to_rpolars_err)
}

pub fn serialize_series(series: PSeries) -> RResult<Vec<u8>> {
    serialize_dataframe(&mut std::iter::once(series).into_iter().collect())
}

pub fn deserialize_series(bits: &[u8]) -> RResult<PSeries> {
    let tn = std::any::type_name::<PSeries>();
    deserialize_dataframe(bits)?
        .get_columns()
        .split_first()
        .ok_or(RPolarsErr::new())
        .mistyped(tn)
        .and_then(|(s, r)| {
            r.is_empty()
                .then_some(s.clone())
                .ok_or(RPolarsErr::new())
                .mistyped(tn)
        })
}

/// Defines all kinds of tasks that can be sent to background R processes
#[derive(Debug, serde::Deserialize, serde::Serialize)]
pub enum RIPCJob {
    /// Evaluate a R function with R arguments
    REval {
        raw_func: Vec<u8>,
        raw_arg: Vec<u8>,
        collector: ipc::IpcSender<RResult<Vec<u8>>>,
    },
    /// Map a Polars series with a R function
    RMapSeries {
        raw_func: Vec<u8>,
        raw_series: ipc::IpcSharedMemory,
        collector: ipc::IpcSender<RResult<ipc::IpcSharedMemory>>,
    },
}

impl RIPCJob {
    pub fn handle(self) -> RResult<()> {
        match self {
            Self::REval {
                raw_func,
                raw_arg,
                collector,
            } => {
                let bits = || {
                    let func_robj = deserialize_robj(raw_func)?;
                    let arg_robj = deserialize_robj(raw_arg)?;
                    let func = func_robj
                        .as_function()
                        .ok_or(RPolarsErr::new())
                        .bad_val(rdbg(func_robj))
                        .mistyped("pure R function")?;
                    let arg = arg_robj
                        .as_pairlist()
                        .or_else(|| {
                            call!("as.pairlist", &arg_robj)
                                .ok()
                                .and_then(|l| l.as_pairlist())
                        })
                        .ok_or(RPolarsErr::new())
                        .bad_val(rdbg(arg_robj))
                        .mistyped("pairlist (as R function arguments)")?;
                    serialize_robj(func.call(arg)?)
                };
                collector.send(
                    bits().when("trying to evaluate R function call in the background R process"),
                )?;
                Ok(())
            }
            Self::RMapSeries {
                raw_func,
                raw_series,
                collector,
            } => {
                let bits = || {
                    use crate::series::Series as RSeries;
                    let func_robj = deserialize_robj(raw_func)?;
                    let series = deserialize_series(&raw_series)?;
                    let func = func_robj
                        .as_function()
                        .ok_or(RPolarsErr::new())
                        .bad_val(rdbg(func_robj))
                        .mistyped("pure R function")?;
                    let shared_memory = serialize_series(RSeries::any_robj_to_pl_series_result(
                        func.call(pairlist!(RSeries(series)))?,
                    )?)?;
                    RResult::Ok(ipc::IpcSharedMemory::from_bytes(shared_memory.as_slice()))
                };
                collector.send(bits().when(
                    "trying to map a polars series with R function in the background R process",
                ))?;
                Ok(())
            }
        }
    }
}

#[derive(Debug)]
struct RBackgroundHandler {
    proc: std::process::Child,
    chan: ipc::IpcSender<RIPCJob>,
    in_pool: bool,
}

impl RBackgroundHandler {
    pub fn new() -> RResult<Self> {
        use std::process::*;

        let (server, server_name) = ipc::IpcOneShotServer::new()
            .when("trying to create a one-shot channel to setup inter-process communication")?;
        let libs = RENV
            .1
            .iter()
            .map(|lib| format!("\"{lib}\", "))
            .collect::<Vec<_>>()
            .join("");
        let child = Command::new(RENV.0.as_str())
            .arg("--vanilla")
            .arg("-q")
            .arg("-e")
            // Remove rextendr::document() if possible
            .arg(format!(
                ".libPaths(c({libs}.libPaths())); polars:::handle_background_request(\"{server_name}\") |> invisible()"
            ))
            .stdin(Stdio::null())
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .spawn()
            .when("trying to spawn a background R process")?;
        let (_, tx): (_, ipc::IpcSender<RIPCJob>) = server
            .accept()
            .when("waiting for the background R process to establish a job channel")?;
        Ok(RBackgroundHandler {
            proc: child,
            chan: tx,
            in_pool: false,
        })
    }

    pub fn submit(&self, job: RIPCJob) -> RResult<()> {
        self.chan
            .send(job)
            .when("trying to submit a job to the background R process")
    }
}

impl Drop for RBackgroundHandler {
    fn drop(&mut self) {
        #[cfg(feature = "rpolars_debug_print")]
        println!("dropping handler");
        if self.in_pool {
            panic!("Internal error: in-pool handler dropped unaccounted for. Please use InnerRBackgroundPool::destroy_handler()")
        }
        if self
            .proc
            .try_wait()
            .ok()
            .and_then(std::convert::identity)
            .is_none()
        {
            self.proc.kill().unwrap();
        }
    }
}

// The InnerRBackgroundPool exists to hide implementation behind a single Arc<Mutex> not one for
// each field. Having multiple Mutex could perhaps lead to some race condition or deadlock.
// Each method call must leave the pool in a valid state. Most important, the active count stays correct.
#[derive(Debug)]
pub struct InnerRBackgroundPool {
    pool: VecDeque<RBackgroundHandler>,
    queue: VecDeque<Sender<RBackgroundHandler>>,
    active: usize,
    cap: usize,
}
impl InnerRBackgroundPool {
    fn new(cap: usize) -> Self {
        InnerRBackgroundPool {
            pool: VecDeque::new(),
            queue: VecDeque::new(),
            active: 0,
            cap,
        }
    }

    fn create_handler(&mut self) -> RResult<RBackgroundHandler> {
        #[cfg(feature = "rpolars_debug_print")]
        println!("create handler");
        self.active += 1;
        let mut handle = RBackgroundHandler::new()?;
        handle.in_pool = true;
        Ok(handle)
    }

    fn destroy_handler(&mut self, mut handle: RBackgroundHandler) {
        #[cfg(feature = "rpolars_debug_print")]
        println!("destroy handler");
        if !handle.in_pool {
            panic!(
                "internal error: destroying an out-of-pool handler should not be done with this method"
            );
        } else {
            self.active -= 1;
            handle.in_pool = false; // tag handle as freed from pool, will be dropped now
        }
    }

    fn release_handler(&mut self, mut handle: RBackgroundHandler) -> RResult<()> {
        match (handle.proc.try_wait()?, self.queue.pop_front()) {
            // 1a: too many active handlers. Kill it !
            (_, _) if self.active > self.cap => {
                #[cfg(feature = "rpolars_debug_print")]
                println!("1a - too many kill it!");
                self.destroy_handler(handle)
            }

            // 1b: handler terminated, and not needed. Kill it !
            (Some(_exit_status), None) => {
                #[cfg(feature = "rpolars_debug_print")]
                println!("1b - terminated, kill it!");
                self.destroy_handler(handle)
            }

            // 2a: handler is fine and needed in queue. Pass it on !
            (None, Some(tx)) => {
                #[cfg(feature = "rpolars_debug_print")]
                println!("2a - fine, pass it on!");
                tx.send(handle)?
            }

            // 2b: handler terminated and needed in queue. Reset and pass it on !
            (Some(_exit_status), Some(tx)) => {
                #[cfg(feature = "rpolars_debug_print")]
                println!("2b - create new  and pass it on!");
                self.destroy_handler(handle);
                let new_bg_handler = self.create_handler()?;
                tx.send(new_bg_handler)?
            }

            // 3a: handler is fine but queue is empty. Place it in idle pool !
            (None, None) => {
                #[cfg(feature = "rpolars_debug_print")]
                println!("3a - park handler in pool");
                self.pool.push_back(handle)
            }
        }
        Ok(())
    }

    pub fn resize(&mut self, new_cap: usize) {
        self.cap = new_cap;
        while (self.active > self.cap) & (self.pool.len() > 0) {
            let handle = self
                .pool
                .pop_front()
                .expect("pool has at least one element");
            self.destroy_handler(handle)
        }
    }
}

#[derive(Debug)]
pub struct RBackgroundPool(Arc<Mutex<InnerRBackgroundPool>>);

impl RBackgroundPool {
    pub fn new(cap: usize) -> Self {
        RBackgroundPool(Arc::new(Mutex::new(InnerRBackgroundPool::new(cap))))
    }

    fn lease(&self) -> RResult<RBackgroundHandler> {
        #[cfg(feature = "rpolars_debug_print")]
        dbg!("METHOD lease", &self);
        let mut pool_guard = self.0.lock()?;

        match pool_guard.pool.pop_front() {
            Some(handle) => {
                #[cfg(feature = "rpolars_debug_print")]
                println!("lease handler from pool");
                Ok(handle)
            }
            None if pool_guard.cap < 1 => {
                #[cfg(feature = "rpolars_debug_print")]
                println!("lease fail cap <0 ");
                rerr()
                    .plain("cannot run background R process with zero capacity")
                    .hint("try increase cap e.g. pl$set_global_rpool_cap(4)")
            }
            None if pool_guard.active < pool_guard.cap => {
                #[cfg(feature = "rpolars_debug_print")]
                println!("lease a newly created handler");
                pool_guard.create_handler()
            }
            None => {
                #[cfg(feature = "rpolars_debug_print")]
                println!("active == cap, no more handlers allowed, go into queue");
                let (tx, rx) = bounded(1);
                pool_guard.queue.push_back(tx);
                drop(pool_guard); // avoid deadlock
                #[cfg(feature = "rpolars_debug_print")]
                println!("wait for freed handler");
                let ok = Ok(rx.recv()?);
                #[cfg(feature = "rpolars_debug_print")]
                println!("thread was awoken queue and passed a handler");
                ok
            }
        }
        .when("trying to rent a R process from the global R process pool")
    }

    fn shelf(&self, handle: RBackgroundHandler) -> RResult<()> {
        #[cfg(feature = "rpolars_debug_print")]
        dbg!("shelf", &self);
        self.0
            .lock()?
            .release_handler(handle)
            .when("trying to shelf a handler in pool")
    }

    pub fn resize(&self, new_cap: usize) -> RResult<()> {
        #[cfg(feature = "rpolars_debug_print")]
        dbg!("resize", &self);
        self.0
            .lock()
            .when("trying to resize the global R process pool")?
            .resize(new_cap);
        Ok(())
    }

    pub fn reval<'t>(
        &'t self,
        raw_func: Vec<u8>,
        raw_arg: Vec<u8>,
    ) -> RResult<impl FnOnce() -> RResult<Vec<u8>> + 't> {
        #[cfg(feature = "rpolars_debug_print")]
        dbg!("reval");
        let handler = self.lease()?;
        let (tx, rx) = ipc::channel()?;
        handler.submit(RIPCJob::REval {
            raw_func,
            raw_arg,
            collector: tx,
        })?;
        Ok(move || {
            let raw_ret = rx
                .recv()
                .when("trying to receive the result from the background R process")?;
            self.shelf(handler)?;
            raw_ret
        })
    }

    pub fn rmap_series<'t>(
        &'t self,
        raw_func: Vec<u8>,
        series: PSeries,
    ) -> RResult<impl FnOnce() -> RResult<PSeries> + 't> {
        #[cfg(feature = "rpolars_debug_print")]
        dbg!("rmap_series");
        let handler = self.lease()?;
        let (tx, rx) = ipc::channel()?;
        let shared_memory = serialize_series(series)?;
        handler.submit(RIPCJob::RMapSeries {
            raw_func,
            raw_series: ipc::IpcSharedMemory::from_bytes(shared_memory.as_slice()),
            collector: tx,
        })?;
        Ok(move || {
            let raw_series = rx
                .recv()
                .when("waiting for the background R process to finish mapping a polars series")?;
            self.shelf(handler)?;
            deserialize_series(&raw_series?)
        })
    }
}

pub static RENV: Lazy<(String, Vec<String>)> = Lazy::new(|| {
    let bin_path = R!("file.path(R.home(\"bin\"), \"R\")")
        .map_err(extendr_to_rpolars_err)
        .and_then(|r| robj_to!(String, r))
        .unwrap_or("R".into());
    let lib_paths = R!(".libPaths()")
        .map_err(extendr_to_rpolars_err)
        .and_then(|rv| robj_to!(Vec, String, rv))
        .unwrap_or_default();
    (bin_path, lib_paths)
});

#[extendr]
pub fn setup_renv() -> List {
    list!(binary = &RENV.0, libraries = &RENV.1)
}

pub static RBGPOOL: Lazy<RBackgroundPool> = Lazy::new(|| RBackgroundPool::new(1));

#[extendr]
pub fn set_global_rpool_cap(c: Robj) -> RResult<()> {
    RBGPOOL.resize(crate::utils::robj_to_usize(c)?)
}

#[extendr]
pub fn get_global_rpool_cap() -> RResult<List> {
    let pool_guard = RBGPOOL.0.lock()?;
    Ok(list!(
        available = pool_guard.active,
        capacity = pool_guard.cap
    ))
}

#[extendr]
pub fn handle_background_request(server_name: String) -> RResult<()> {
    let rtx = ipc::IpcSender::connect(server_name)?;

    let (tx, rx) = ipc::channel::<RIPCJob>()?;
    rtx.send(tx)?;

    while let Ok(job) = rx.recv() {
        job.handle()?;
    }
    Ok(())
}

#[extendr]
pub fn test_rbackgroundhandler(lambda: Robj, arg: Robj) -> RResult<Robj> {
    deserialize_robj(RBGPOOL
        .reval(serialize_robj(lambda)?, serialize_robj(arg)?)?(
    )?)
}

#[extendr]
pub fn test_rthreadhandle() -> RThreadHandle<RResult<RDF>> {
    RThreadHandle::new(move || {
        println!("Intense sleeping in Rust for 10 seconds!");
        let duration = std::time::Duration::from_millis(10000);
        thread::sleep(duration);
        println!("Wake up!");
        let plf = {
            use polars::prelude::*;
            df!("Fruit" => &["Apple", "Banana", "Pear"],
            "Color" => &["Red", "Yellow", "Green"],
            "Cost" => &[2, 4, 6])
            .unwrap()
            .lazy()
            .with_column(
                col("Cost")
                    .apply(|c| Ok(Some(c + 1)), GetOutput::default())
                    .alias("Price"),
            )
        };
        let rlf = crate::lazy::dataframe::LazyFrame::from(plf)
            .collect()
            .unwrap();
        Ok(rlf)
    })
}

#[extendr]
pub fn test_serde_df(df: &RDF) -> RResult<RDF> {
    let x = serialize_dataframe(&mut df.0.clone())?;
    let df2 = deserialize_dataframe(x.as_slice())?;
    Ok(RDF(df2))
}

extendr_module! {
    mod rbackground;
    impl RThreadHandle<RResult<RDF>>;
    fn setup_renv;
    fn set_global_rpool_cap;
    fn get_global_rpool_cap;
    fn handle_background_request;
    fn test_rbackgroundhandler;
    fn test_rthreadhandle;
    fn test_serde_df;
}
