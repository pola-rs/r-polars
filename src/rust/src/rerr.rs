use extendr_api::{
    extendr, extendr_module, symbol::class_symbol, Attributes, Pairlist, Rinternals, Robj,
};
use thiserror::Error;

#[derive(Clone, Debug, Error)]
pub enum Rctx {
    #[error("The argument [{0}] casuse an error")]
    BadArg(String),
    #[error("Got value [{0}]")]
    BadVal(String),
    #[error("Encountered the following error in Extendr:\n{0}")]
    Extendr(String),
    #[error("Possibly because {0}")]
    Hint(String),
    #[error("Expected a value of type [{0}]")]
    Mistyped(String),
    #[error("Expected a value that {0}")]
    Misvalued(String),
    #[error("{0}")]
    Plain(String),
    #[error("Encountered the following error in Polars:\n{0}")]
    Polars(String),
    #[error("When {0}")]
    When(String),
}

#[derive(Clone, Debug)]
pub struct Rerr(Vec<Rctx>);
pub type RResult<T> = core::result::Result<T, Rerr>;

pub trait WithRctx<T> {
    fn ctx(self, rctx: Rctx) -> RResult<T>;
    fn bad_arg<S: Into<String>>(self, arg: S) -> RResult<T>;
    fn bad_robj(self, robj: &Robj) -> RResult<T>;
    fn bad_val<S: Into<String>>(self, val: S) -> RResult<T>;
    fn hint<S: Into<String>>(self, cause: S) -> RResult<T>;
    fn mistyped<S: Into<String>>(self, ty: S) -> RResult<T>;
    fn misvalued<S: Into<String>>(self, scope: S) -> RResult<T>;
    fn plain<S: Into<String>>(self, msg: S) -> RResult<T>;
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

    fn bad_arg<S: Into<String>>(self, arg: S) -> RResult<T> {
        self.ctx(Rctx::BadArg(arg.into()))
    }

    fn bad_robj(self, robj: &Robj) -> RResult<T> {
        self.bad_val(rdbg(robj))
    }

    fn bad_val<S: Into<String>>(self, val: S) -> RResult<T> {
        self.ctx(Rctx::BadVal(val.into()))
    }

    fn hint<S: Into<String>>(self, cause: S) -> RResult<T> {
        self.ctx(Rctx::Hint(cause.into()))
    }

    fn mistyped<S: Into<String>>(self, ty: S) -> RResult<T> {
        self.ctx(Rctx::Mistyped(ty.into()))
    }

    fn misvalued<S: Into<String>>(self, scope: S) -> RResult<T> {
        self.ctx(Rctx::Misvalued(scope.into()))
    }

    fn plain<S: Into<String>>(self, msg: S) -> RResult<T> {
        self.ctx(Rctx::Plain(msg.into()))
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
        format!("{}", self)
    }

    pub fn contexts(&self) -> Pairlist {
        Pairlist::from_pairs(self.0.iter().rev().map(|rctx| match rctx {
            Rctx::BadArg(arg) => ("BadArgument", arg),
            Rctx::BadVal(val) => ("BadValue", val),
            Rctx::Extendr(err) => ("ExtendrError", err),
            Rctx::Hint(msg) => ("Hint", msg),
            Rctx::Mistyped(ty) => ("TypeMismatch", ty),
            Rctx::Misvalued(scope) => ("ValueOutOfScope", scope),
            Rctx::Plain(msg) => ("PlainErrorMessage", msg),
            Rctx::Polars(err) => ("PolarsError", err),
            Rctx::When(target) => ("When", target),
        }))
    }
}

impl std::fmt::Display for Rerr {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{}",
            self.0
                .iter()
                .rev()
                .map(|rerr| format!("{}", rerr))
                .reduce(|msg, rerr| { format!("{}: {}", msg, rerr) })
                .unwrap_or(String::new())
        )
    }
}

impl From<Rerr> for String {
    fn from(rerr: Rerr) -> Self {
        rerr.info()
    }
}

impl<E: std::error::Error> From<E> for Rerr {
    default fn from(err: E) -> Self {
        Rerr(vec![Rctx::Plain(rdbg(err))])
    }
}

impl From<extendr_api::Error> for Rerr {
    fn from(extendr_err: extendr_api::Error) -> Self {
        Rerr(vec![Rctx::Extendr(rdbg(extendr_err))])
    }
}

impl From<polars::error::PolarsError> for Rerr {
    fn from(polars_err: polars::error::PolarsError) -> Self {
        let mut rerr = Rerr::new();
        rerr.0.push(Rctx::Polars(rdbg(&polars_err)));
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

pub fn rerr<T>() -> RResult<T> {
    Err(Rerr::new())
}

pub fn rdbg<T: std::fmt::Debug>(o: T) -> String {
    format!("{:?}", o)
}

#[extendr]
pub fn test_rerr() -> RResult<String> {
    rerr()
        .bad_val("-1")
        .mistyped("usize")
        .bad_arg("path")
        .when("calling test function")
}

extendr_module! {
    mod rerr;
    impl Rerr;
    fn test_rerr;
}
