use extendr_api::{extendr, extendr_module, symbol::class_symbol, Attributes, Rinternals, Robj};
use thiserror::Error;

#[derive(Clone, Debug, Error)]
pub enum Rctx {
    #[error("The argument [{0}] casuse an error because")]
    BadArgument(String),
    #[error("Encountered the following error in Extendr:\n{0}")]
    Extendr(String),
    #[error("Possibly {0}")]
    Hint(String),
    #[error("{0}")]
    Plain(String),
    #[error("Encountered the following error in Polars:\n{0}")]
    Polars(String),
    #[error("When {0}")]
    When(String),
    #[error("Expected a value of type [{0}], but got [{1}] instead")]
    TypeMismatch(String, String),
}

#[derive(Clone, Debug)]
pub struct Rerr(Vec<Rctx>);
pub type RResult<T> = core::result::Result<T, Rerr>;

pub trait WithRctx<T> {
    fn ctx(self, rctx: Rctx) -> RResult<T>;
    fn on_arg<S: Into<String>>(self, arg: S) -> RResult<T>;
    fn type_mismatch<R: Into<String>, S: Into<String>>(self, ty: R, val: S) -> RResult<T>;
    fn hint<S: Into<String>>(self, cause: S) -> RResult<T>;
    fn when<S: Into<String>>(self, env: S) -> RResult<T>;
}

impl<T, E: Into<Rerr>> WithRctx<T> for core::result::Result<T, E> {
    fn ctx(self, rctx: Rctx) -> RResult<T> {
        self.map_err(|e| {
            let mut rerr = e.into();
            rerr.0.push(rctx);
            rerr
        })
    }

    fn on_arg<S: Into<String>>(self, arg: S) -> RResult<T> {
        self.ctx(Rctx::BadArgument(arg.into()))
    }

    fn type_mismatch<R: Into<String>, S: Into<String>>(self, ty: R, val: S) -> RResult<T> {
        self.ctx(Rctx::TypeMismatch(ty.into(), val.into()))
    }

    fn hint<S: Into<String>>(self, cause: S) -> RResult<T> {
        self.ctx(Rctx::Hint(cause.into()))
    }

    fn when<S: Into<String>>(self, env: S) -> RResult<T> {
        self.ctx(Rctx::When(env.into()))
    }
}

#[extendr]
impl Rerr {
    pub fn new() -> Self {
        Rerr(Vec::new())
    }

    pub fn info(&self) -> String {
        self.0
            .iter()
            .rev()
            .map(|rerr| format!("{}", rerr))
            .fold(String::from("Error"), |msg, rerr| {
                format!("{}: {}", msg, rerr)
            })
    }

    pub fn contexts(&self) -> Vec<String> {
        self.0
            .iter()
            .rev()
            .map(|rerr| format!("{:?}", rerr))
            .collect()
    }
}

// Implementation for transition
impl From<String> for Rerr {
    fn from(err_msg: String) -> Self {
        Rerr(vec![Rctx::Plain(err_msg)])
    }
}

impl From<extendr_api::Error> for Rerr {
    fn from(extendr_err: extendr_api::Error) -> Self {
        Rerr(vec![Rctx::Extendr(format!("{:?}", extendr_err))])
    }
}

impl From<polars::error::PolarsError> for Rerr {
    fn from(polars_err: polars::error::PolarsError) -> Self {
        let mut rerr = Rerr::new();
        rerr.0.push(Rctx::Polars(format!("{:?}", polars_err)));
        match polars_err {
            polars::prelude::PolarsError::InvalidOperation(x) => {
                rerr.0.push(Rctx::Hint(format!(
                    "something (likely a column) with name {:?} is not found",
                    x
                )));
            }
            _ => {}
        };
        rerr
    }
}

#[extendr]
pub fn test_rerr() -> RResult<String> {
    Err(Rerr::new())
        .type_mismatch("usize", "-1")
        .on_arg("<an imaginary argument>")
        .when("calling test function")
}

extendr_module! {
    mod rerr;
    impl Rerr;
    fn test_rerr;
}
