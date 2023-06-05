use anyhow::Error;
pub use anyhow::{anyhow as ranyhow, Context};
use extendr_api::{
    extendr, extendr_module, print_r_output, rprintln, symbol::class_symbol, Attributes,
    Rinternals, Robj,
};

#[derive(Debug)]
pub struct Rerr(Error);
pub type Result<T, E = Rerr> = core::result::Result<T, E>;

#[extendr]
impl Rerr {
    fn print(&self) {
        rprintln!("{}", self);
    }
}

impl From<Error> for Rerr {
    fn from(err: Error) -> Self {
        Rerr(err)
    }
}

impl std::fmt::Display for Rerr {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl std::error::Error for Rerr {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        self.0.source()
    }
}

// unsafe impl Send for Rerr {}
// unsafe impl Sync for Rerr {}

extendr_module! {
    mod ranyhow;
    impl Rerr;
}
