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
}

#[extendr]
impl RThreadHandle<RDF> {
    pub fn join(&mut self) -> RResult<RDF> {
        use Rctx::*;
        self.handle
            .take()
            .ok_or(Handled.into())
            .and_then(|handle| handle.join().map_err(|err| BadJoin(rdbg(err)).into()))
    }
}

#[extendr]
pub fn test_rthreadhandle() -> RThreadHandle<RDF> {
    RThreadHandle::new(|| {
        use extendr_api::{print_r_output, rprintln};
        use polars_core::prelude::*;
        rprintln!("Intense sleeping in Rust for 10 seconds!");
        let duration = std::time::Duration::from_millis(10000);
        thread::sleep(duration);
        rprintln!("Wake up!");
        df!("Fruit" => &["Apple", "Banana", "Pear"],
            "Color" => &["Red", "Yellow", "Green"])
        .unwrap()
        .into()
    })
}

extendr_module! {
    mod rthreadhandle;
    impl RThreadHandle;
    fn test_rthreadhandle;
}
