use crate::rdataframe::DataFrame as RDF;
use crate::rpolarserr::{rdbg, RResult, Rctx};
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
        lambda: String,
        arg: String,
        collector: ipc_channel::ipc::IpcSender<RResult<String>>,
    },
    Done,
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
            .arg("-q")
            .arg("-e")
            // Remove rextendr::document() if possible
            .arg(format!(
                "rextendr::document(); polars::pl$handle_background_request(\"{server_name}\")"
            ))
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

    fn test(&self) -> RResult<()> {
        use extendr_api::prelude::*;
        use ipc_channel::ipc;
        let (tx, rx) = ipc::channel::<RResult<String>>()?;
        self.chan.send(RIPCPacket::Reval {
            lambda: "<A function>".to_string(),
            arg: "<An argument>".to_string(),
            collector: tx,
        })?;
        rprintln!("Got: {:?}", rx.recv()?);
        self.chan.send(RIPCPacket::Done)?;
        Ok(())
    }
}

#[extendr]
pub fn handle_background_request(server_name: String) -> RResult<()> {
    use ipc_channel::ipc;
    let rtx = ipc::IpcSender::connect(server_name)?;
    let (tx, rx) = ipc::channel::<RIPCPacket>()?;
    rtx.send(tx)?;

    // Handle jobs
    loop {
        use RIPCPacket::*;
        match rx.recv()? {
            Reval {
                lambda,
                arg,
                collector,
            } => collector.send(Ok(format!("{lambda}({arg})=><The result>")))?,
            Done => break,
        };
    }

    // Finished handling
    Ok(())
}

#[extendr]
pub fn test_rthreadhandle() {
    // use extendr_api::*;
    RBackgroundHandler::new()
        .and_then(|handle| handle.test())
        .unwrap();

    // RThreadHandle::new(move || {
    //     rprintln!("Intense sleeping in Rust for 10 seconds!");
    //     let duration = std::time::Duration::from_millis(10000);
    //     thread::sleep(duration);
    //     rprintln!("Wake up!");
    //     let plf = {
    //         use polars::prelude::*;
    //         df!("Fruit" => &["Apple", "Banana", "Pear"],
    //         "Color" => &["Red", "Yellow", "Green"],
    //         "Cost" => &[2, 4, 6])
    //         .unwrap()
    //         .lazy()
    //         .with_column(
    //             col("Cost")
    //                 .apply(|c| Ok(Some(c + 1)), GetOutput::default())
    //                 .alias("Price"),
    //         )
    //     };
    //     let rlf = crate::lazy::dataframe::LazyFrame::from(plf)
    //         .collect()
    //         .unwrap();
    //     Ok(rlf)
    // })
}

extendr_module! {
    mod rthreadhandle;
    impl RThreadHandle;
    fn handle_background_request;
    fn test_rthreadhandle;
}
