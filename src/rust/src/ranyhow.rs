use anyhow::Error;
pub use anyhow::{anyhow as ranyhow, Context};
use extendr_api::{extendr, extendr_module, symbol::class_symbol, Attributes, Rinternals, Robj};

#[derive(Debug)]
pub struct Rerr(Error);
pub type Result<T, E = Rerr> = core::result::Result<T, E>;

#[extendr]
impl Rerr {
    fn info(&self) -> String {
        format!("{:#}", self.0)
    }

    fn debug(&self) -> String {
        format!("{:?}", self.0)
    }

    fn chain(&self) -> Vec<String> {
        self.0.chain().map(|cause| format!("{:#}", cause)).collect()
    }
}

impl From<Error> for Rerr {
    fn from(err: Error) -> Self {
        Rerr(err)
    }
}

impl std::fmt::Display for Rerr {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:#}", self.0)
    }
}

impl std::error::Error for Rerr {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        self.0.source()
    }
}

extendr_module! {
    mod ranyhow;
    impl Rerr;
}
