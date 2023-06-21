use std::collections::VecDeque;

use extendr_api::{
    extendr, extendr_module, symbol::class_symbol, Attributes, Pairlist, Rinternals, Robj,
    Operators, eval_string, call, Types,
};
use thiserror::Error;

#[derive(Clone, Debug, Error)]
pub enum Rctx {
    #[error("The argument [{0}] cause an error")]
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
    #[error("In {0}")]
    Wherein(String),
}

#[derive(Clone, Debug)]
pub struct RPolarsErr(VecDeque<Rctx>);
pub type RResult<T> = core::result::Result<T, RPolarsErr>;

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
    fn wherein<S: Into<String>>(self, env: S) -> RResult<T>;
}

impl<T, E: Into<RPolarsErr>> WithRctx<T> for core::result::Result<T, E> {
    fn ctx(self, rctx: Rctx) -> RResult<T> {
        self.map_err(|e| {
            let mut rerr = e.into();
            rerr.0.push_back(rctx);
            rerr
        })
    }

    fn bad_arg<S: Into<String>>(self, arg: S) -> RResult<T> {
        self.ctx(Rctx::BadArg(arg.into()))
    }

    fn bad_val<S: Into<String>>(self, val: S) -> RResult<T> {
        self.ctx(Rctx::BadVal(val.into()))
    }

    fn bad_robj(self, robj: &Robj) -> RResult<T> {
        self.bad_val(robj_dbg(robj))
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

    fn wherein<S: Into<String>>(self, env: S) -> RResult<T> {
        self.ctx(Rctx::Wherein(env.into()))
    }
}

#[extendr]
impl RPolarsErr {
    pub fn new() -> Self {
        RPolarsErr(VecDeque::new())
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
            Rctx::Wherein(target) => ("Wherein", target),
        }))
    }

    pub fn bad_arg(&self, x: String) -> Self {
        self.push_back_rctx(Rctx::BadArg(x))
    }
    pub fn bad_val(&self, x: String) -> Self {
        self.push_back_rctx(Rctx::BadVal(x))
    }
    pub fn bad_robj(&self, x: Robj) -> Self {
        self.bad_val(robj_dbg(&x))
    }
    pub fn hint(&self, x: String) -> Self {
        self.push_back_rctx(Rctx::Hint(x))
    }
    pub fn mistyped(&self, x: String) -> Self {
        self.push_back_rctx(Rctx::Mistyped(x))
    }
    pub fn misvalued(&self, x: String) -> Self {
        self.push_back_rctx(Rctx::Misvalued(x))
    }
    pub fn plain(&self, x: String) -> Self {
        self.push_back_rctx(Rctx::Plain(x))
    }
    pub fn when(&self, x: String) -> Self {
        self.push_back_rctx(Rctx::When(x))
    }
    pub fn when_last(&self, x: String) -> Self {
        self.push_front_rctx(Rctx::When(x))
    }
    pub fn wherein(&self, x: String) -> Self {
        self.push_back_rctx(Rctx::Wherein(x))
    }
}
//methods not to export with extendr
impl RPolarsErr {
    pub fn push_front_rctx(&self, rctx: Rctx) -> Self {
        let mut rerr = self.clone();
        rerr.0.push_front(rctx);
        rerr
    }
    pub fn push_back_rctx(&self, rctx: Rctx) -> Self {
        let mut rerr = self.clone();
        rerr.0.push_back(rctx);
        rerr
    }
}

impl std::fmt::Display for RPolarsErr {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{}",
            self.0
                .iter()
                .rev()
                .map(|rerr| format!("{}", rerr))
                .reduce(|msg, rerr| { format!("{}: {}", msg, rerr) })
                .unwrap_or(String::from("Missing contexts from the Rust side"))
        )
    }
}

impl From<RPolarsErr> for String {
    fn from(rerr: RPolarsErr) -> Self {
        rerr.info()
    }
}

impl<E: std::error::Error> From<E> for RPolarsErr {
    default fn from(err: E) -> Self {
        RPolarsErr(VecDeque::from([Rctx::Plain(rdbg(err))]))
    }
}

impl From<extendr_api::Error> for RPolarsErr {
    fn from(extendr_err: extendr_api::Error) -> Self {
        RPolarsErr(VecDeque::from([Rctx::Extendr(rdbg(extendr_err))]))
    }
}

impl From<polars::error::PolarsError> for RPolarsErr {
    fn from(polars_err: polars::error::PolarsError) -> Self {
        let mut rerr = RPolarsErr::new();
        rerr.0.push_back(Rctx::Polars(rdbg(&polars_err)));
        match polars_err {
            polars::prelude::PolarsError::InvalidOperation(x) => {
                rerr.0.push_back(Rctx::Hint(format!(
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
    Err(RPolarsErr::new())
}

//any rust impl Debug to string
pub fn rdbg<T: std::fmt::Debug>(o: T) -> String {
    format!("{:?}", o)
}

//detailed debug of Robj to string
pub fn robj_dbg(robj: &Robj) -> String {
    let s = rdbg(robj);
    format!(
        "Rvalue: {}{}, Rsexp: {:?}, Rclass: {:?}",
        &s[0..(s.len().min(128))],
        if s.len()>128 {"...]  "} else {""},
        robj.rtype(),
        call!("base::class", robj).expect("internal error: could not use base::class(robj)")
    )
}

#[extendr]
pub fn test_rerr() -> RResult<String> {
    rerr().bad_val("-1").mistyped("usize").bad_arg("path")
}

extendr_module! {
    mod rerr;
    impl RPolarsErr;
    fn test_rerr;
}
