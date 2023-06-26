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
impl RThreadHandle<RDF> {
    fn join(&mut self) -> RResult<RDF> {
        self.join_generic()
    }

    fn is_finished(&self) -> RResult<bool> {
        self.is_finished_generic()
    }
}

#[extendr]
pub fn test_rthreadhandle() -> RThreadHandle<RDF> {
    RThreadHandle::new(move || {
        use crate::lazy::*;
        use extendr_api::{print_r_output, rprintln};
        rprintln!("Intense sleeping in Rust for 1 seconds!");
        let duration = std::time::Duration::from_millis(1000);
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
        dataframe::LazyFrame::from(plf).collect().unwrap()
    })
}

extendr_module! {
    mod rthreadhandle;
    impl RThreadHandle;
    fn test_rthreadhandle;
}
