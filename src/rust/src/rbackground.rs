use crate::rdataframe::DataFrame as RDF;
use crate::rpolarserr::{rdbg, RPolarsErr, RResult, Rctx, WithRctx};
use extendr_api::{
    call, eval_string, extendr, extendr_module, list, pairlist, symbol::class_symbol, Attributes,
    Conversions, List, Operators, Pairlist, Rinternals, Robj, NULL,
};
use ipc_channel::ipc;
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
            .ok_or(Handled.into())
            .and_then(|handle| handle.join().map_err(|err| BadJoin(rdbg(err)).into()))
    }

    pub fn is_finished_generic(&self) -> RResult<bool> {
        self.handle
            .as_ref()
            .ok_or(Rctx::Handled.into())
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
        .map_err(crate::rpolarserr::polars_to_rpolars_err)?;
    Ok(dump)
}

pub fn deserialize_dataframe(bits: &[u8]) -> RResult<polars::prelude::DataFrame> {
    use polars::io::SerReader;

    polars::io::ipc::IpcReader::new(std::io::Cursor::new(bits))
        .finish()
        .map_err(crate::rpolarserr::polars_to_rpolars_err)
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

pub struct RBackgroundHandler {
    proc: std::process::Child,
    chan: ipc::IpcSender<RIPCJob>,
}

impl RBackgroundHandler {
    pub fn new() -> RResult<Self> {
        use std::process::*;

        let (server, server_name) = ipc::IpcOneShotServer::new()
            .when("trying to create a one-shot channel to setup inter-process communication")?;

        let child = Command::new("R")
            .arg("--vanilla")
            .arg("-q")
            .arg("-e")
            // Remove rextendr::document() if possible
            .arg(format!(
                "invisible(polars:::handle_background_request(\"{server_name}\"))\n"
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

pub struct RBackgroundPool {
    pool: Arc<Mutex<VecDeque<RBackgroundHandler>>>,
    cap: Arc<Mutex<usize>>,
}

impl RBackgroundPool {
    pub fn new(cap: usize) -> Self {
        RBackgroundPool {
            pool: Arc::new(Mutex::new(VecDeque::new())),
            cap: Arc::new(Mutex::new(cap)),
        }
    }

    pub fn lease(&self) -> RResult<RBackgroundHandler> {
        if let Some(handle) = self.pool.lock()?.pop_front() {
            Ok(handle)
        } else {
            RBackgroundHandler::new()
        }
        .when("trying to rent a R process from the global R process pool")
    }

    pub fn shelf(&self, mut handle: RBackgroundHandler) -> RResult<()> {
        let res = || {
            let mut lpool = self.pool.lock()?;
            if handle.proc.try_wait()?.is_none() && self.cap.lock()?.gt(&lpool.len()) {
                lpool.push_back(handle);
            }
            RResult::Ok(())
        };
        res().when("trying to handle a completed R process")
    }

    pub fn resize(&self, new_cap: usize) -> RResult<()> {
        let res = || {
            let mut lpool = self.pool.lock()?;
            let mut old_cap = self.cap.lock()?;
            if new_cap.lt(&lpool.len()) {
                lpool.truncate(new_cap);
            }
            *old_cap = new_cap;
            RResult::Ok(())
        };
        res().when("trying to resize the global R process pool")
    }

    pub fn reval<'t>(
        &'t self,
        raw_func: Vec<u8>,
        raw_arg: Vec<u8>,
    ) -> RResult<impl FnOnce() -> RResult<Vec<u8>> + 't> {
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

pub static RBGPOOL: once_cell::sync::Lazy<RBackgroundPool> =
    once_cell::sync::Lazy::new(|| RBackgroundPool::new(1));

#[extendr]
pub fn set_global_rpool_cap(c: Robj) -> RResult<()> {
    RBGPOOL.resize(crate::utils::robj_to_usize(c)?)
}

#[extendr]
pub fn get_global_rpool_cap() -> RResult<List> {
    Ok(list!(
        available = RBGPOOL.pool.lock()?.len(),
        capacity = RBGPOOL.cap.lock()?.clone()
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
    use extendr_api::*;

    RThreadHandle::new(move || {
        rprintln!("Intense sleeping in Rust for 10 seconds!");
        let duration = std::time::Duration::from_millis(10000);
        thread::sleep(duration);
        rprintln!("Wake up!");
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
    fn test_serde_df;
    fn set_global_rpool_cap;
    fn get_global_rpool_cap;
    fn handle_background_request;
    fn test_rbackgroundhandler;
    fn test_rthreadhandle;
}
