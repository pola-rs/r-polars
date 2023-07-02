use crate::rdataframe::DataFrame as RDF;
use crate::rpolarserr::{rdbg, RPolarsErr, RResult, Rctx, WithRctx};
use extendr_api::{extendr, extendr_module, symbol::class_symbol, Attributes, Rinternals, Robj};
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

#[derive(Debug, serde::Deserialize, serde::Serialize)]
pub enum RIPCPacket {
    Reval {
        raw_func: Vec<u8>,
        raw_arg: Vec<u8>,
        collector: ipc_channel::ipc::IpcSender<RResult<Vec<u8>>>,
    },
    Done,
}

impl RIPCPacket {
    pub fn has_job(self) -> Option<Self> {
        match self {
            Self::Done => None,
            _ => Some(self),
        }
    }

    pub fn handle(self) -> RResult<()> {
        use extendr_api::*;
        match self {
            Self::Reval {
                raw_func,
                raw_arg,
                collector,
            } => {
                let lambda = call!("unserialize", raw_func)?;
                let arg = call!("unserialize", raw_arg)?;
                let ret = lambda
                    .as_function()
                    .ok_or(RPolarsErr::new())
                    .bad_val(rdbg(lambda))
                    .mistyped("pure R function")?
                    .call(
                        arg.as_pairlist()
                            .ok_or(RPolarsErr::new())
                            .bad_val(rdbg(arg))
                            .mistyped("pairlist (as R function arguments)")?,
                    )?;
                Ok(collector.send(Ok(call!("serialize", ret, NULL)?
                    .as_raw_slice()
                    .unwrap()
                    .to_vec()))?)
            }
            Self::Done => Ok(()),
        }
    }
}

pub struct RBackgroundHandler {
    proc: std::process::Child,
    chan: ipc_channel::ipc::IpcSender<RIPCPacket>,
}

impl RBackgroundHandler {
    pub fn new() -> RResult<Self> {
        use ipc_channel::ipc;
        use std::process::*;

        let (server, server_name) = ipc::IpcOneShotServer::new()?;
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
            .spawn()?;
        let (_, tx): (_, ipc::IpcSender<RIPCPacket>) = server.accept()?;
        Ok(RBackgroundHandler {
            proc: child,
            chan: tx,
        })
    }

    pub fn close(mut self) -> RResult<()> {
        Ok(self.proc.kill()?)
    }
}

#[extendr]
pub fn handle_background_request(server_name: String) -> RResult<()> {
    use ipc_channel::ipc;
    let rtx = ipc::IpcSender::connect(server_name)?;

    let (tx, rx) = ipc::channel::<RIPCPacket>()?;
    rtx.send(tx)?;

    while let Some(job) = rx.recv()?.has_job() {
        job.handle()?;
    }

    Ok(())
}

#[extendr]
pub fn test_rbackgroundhandler(lambda: Robj, arg: Robj) -> RResult<Robj> {
    let handler = RBackgroundHandler::new().unwrap();
    use extendr_api::prelude::*;
    use ipc_channel::ipc;
    let (tx, rx) = ipc::channel::<RResult<Vec<u8>>>()?;
    let raw_func = call!("serialize", lambda, NULL)?
        .as_raw_slice()
        .unwrap()
        .to_vec();
    let raw_arg = call!("serialize", arg, NULL)?
        .as_raw_slice()
        .unwrap()
        .to_vec();

    handler.chan.send(RIPCPacket::Reval {
        raw_func,
        raw_arg,
        collector: tx,
    })?;

    let raw_res = rx.recv()??;
    handler.chan.send(RIPCPacket::Done)?;
    Ok(call!("unserialize", raw_res)?)
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
