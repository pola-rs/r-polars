use crate::rdataframe::DataFrame as RDF;
use crate::rpolarserr::{rdbg, RPolarsErr, RResult, Rctx, WithRctx};
use extendr_api::{extendr, extendr_module, symbol::class_symbol, Attributes, Rinternals, Robj};
use ipc_channel::ipc;
use std::collections::VecDeque;
use std::sync::{Arc, Mutex};
use std::thread;

#[derive(Debug)]
pub struct RThreadHandle<T> {
    handle: Option<thread::JoinHandle<T>>,
}

impl<T: Send + Sync + 'static> RThreadHandle<T> {
    pub fn new(compute: fn() -> T) -> Self {
        RThreadHandle {
            handle: Some(thread::spawn(compute)),
        }
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
}

pub fn serialize_robj(robj: Robj) -> RResult<Vec<u8>> {
    use extendr_api::*;
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
    use extendr_api::*;
    call!("unserialize", &bits)
        .map_err(RPolarsErr::from)
        .bad_val(rdbg(bits))
        .when("deserializing an R object")
}

/// Defines all kinds of tasks that can be sent to background R processes
#[derive(Debug, serde::Deserialize, serde::Serialize)]
pub enum RIPCJob {
    /// Evaluate a R function with R arguments
    Reval {
        raw_func: Vec<u8>,
        raw_arg: Vec<u8>,
        collector: ipc::IpcSender<RResult<Vec<u8>>>,
    },
    // Map a Polars series with a R function
    // SeriesMap {
    //     raw_func: Vec<u8>,
    //     arrow: Vec<u8>,
    //     collector: ipc::IpcSender<RResult<Vec<u8>>>,
    // },
}

impl RIPCJob {
    pub fn handle(self) -> RResult<()> {
        use extendr_api::*;
        match self {
            Self::Reval {
                raw_func,
                raw_arg,
                collector,
            } => {
                let lambda = deserialize_robj(raw_func)?;
                let arg = deserialize_robj(raw_arg)?;
                let ret = lambda
                    .as_function()
                    .ok_or(RPolarsErr::new())
                    .bad_val(rdbg(lambda))
                    .mistyped("pure R function")?
                    .call(
                        arg.as_pairlist()
                            .or_else(|| {
                                call!("as.pairlist", &arg)
                                    .ok()
                                    .and_then(|l| l.as_pairlist())
                            })
                            .ok_or(RPolarsErr::new())
                            .bad_val(rdbg(arg))
                            .mistyped("pairlist (as R function arguments)")?,
                    )?;
                collector.send(serialize_robj(ret))?;
                Ok(())
            } // Self::SeriesMap {
              //     raw_func,
              //     arrow,
              //     collector,
              // } => {
              //     use polars::prelude::Series;
              //     let input_series: RResult<Series> = {
              //         use polars::chunked_array::ChunkedArray;
              //         use polars::export::arrow::io::ipc::read::*;
              //         use polars::io::ArrowReader;
              //         let lambda = deserialize_robj(raw_func)?;
              //         let mut arrow_slice = arrow.as_slice();
              //         let metadata = read_stream_metadata(&mut arrow_slice)?;
              //         let array = StreamReader::new(arrow_slice, metadata, None)
              //             .next_record_batch()?
              //             .ok_or(RPolarsErr::new())?
              //         // ChunkedArray::from_chunks("RBGSeries", vec![array]);
              //         todo!();
              //     };
              //     todo!();
              // }
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
                "polars::pl$handle_background_request(\"{server_name}\") |> invisible()"
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
        let res: RResult<_> = {
            let mut lpool = self.pool.lock()?;
            if handle.proc.try_wait()?.is_none() && self.cap.lock()?.gt(&lpool.len()) {
                lpool.push_back(handle);
            }
            Ok(())
        };
        res.when("trying to handle a completed R process")
    }

    pub fn resize(&self, new_cap: usize) -> RResult<()> {
        let res: RResult<_> = {
            let mut lpool = self.pool.lock()?;
            let mut old_cap = self.cap.lock()?;
            if new_cap.lt(&lpool.len()) {
                lpool.truncate(new_cap);
            }
            *old_cap = new_cap;
            Ok(())
        };
        res.when("trying to resize the global R process pool")
    }

    pub fn reval<'t>(
        &'t self,
        raw_func: Vec<u8>,
        raw_arg: Vec<u8>,
    ) -> RResult<impl FnOnce() -> RResult<Vec<u8>> + 't> {
        let handler = self.lease()?;
        let (tx, rx) = ipc::channel::<RResult<Vec<u8>>>()?;
        handler.submit(RIPCJob::Reval {
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
    use extendr_api::*;
    rprintln!(
        "Existing processes in background pool: {}",
        crate::RBGPOOL.pool.lock()?.len()
    );
    deserialize_robj(crate::RBGPOOL
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

extendr_module! {
    mod rthreadhandle;
    impl RThreadHandle;
    fn handle_background_request;
    fn test_rbackgroundhandler;
    fn test_rthreadhandle;
}
