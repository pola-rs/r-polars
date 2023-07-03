use std::collections::VecDeque;

use extendr_api::{
    call, eval_string, eval_string_with_params, extendr, extendr_module, symbol::class_symbol,
    Attributes, Nullable, Operators, Pairlist, Rinternals, Robj, Types, R,
};
use thiserror::Error;

#[derive(Clone, Debug, Error)]
pub enum Rctx {
    #[error("The argument [{0}] cause an error")]
    BadArg(String),
    #[error("Got value [{0}]")]
    BadVal(String),
    #[error("Encountered the following error in Rust-Extendr\n\t{0}")]
    Extendr(String),
    #[error("Possibly because {0}")]
    Hint(String),
    #[error("Expected a value of type [{0}]")]
    Mistyped(String),
    #[error("Expected a value that {0}")]
    Misvalued(String),
    #[error("{0}")]
    Plain(String),
    #[error("Encountered the following error in Rust-Polars:\n\t{0}")]
    Polars(String),
    #[error("When {0}")]
    When(String),
}

#[derive(Clone, Debug)]
pub struct RPolarsErr {
    contexts: VecDeque<Rctx>,
    rcall: Option<String>,
    rinfo: Option<String>,
}
pub type RResult<T> = core::result::Result<T, RPolarsErr>;

pub trait WithRctx<T> {
    fn ctx(self, rctx: Rctx) -> RResult<T>;
    fn bad_arg(self, arg: impl Into<String>) -> RResult<T>;
    fn bad_robj(self, robj: &Robj) -> RResult<T>;
    fn bad_val(self, val: impl Into<String>) -> RResult<T>;
    fn hint(self, cause: impl Into<String>) -> RResult<T>;
    fn mistyped(self, ty: impl Into<String>) -> RResult<T>;
    fn misvalued(self, scope: impl Into<String>) -> RResult<T>;
    fn plain(self, msg: impl Into<String>) -> RResult<T>;
    fn when(self, env: impl Into<String>) -> RResult<T>;
}

impl<T, E: Into<RPolarsErr>> WithRctx<T> for core::result::Result<T, E> {
    fn ctx(self, rctx: Rctx) -> RResult<T> {
        self.map_err(|e| {
            let mut rerr = e.into();
            rerr.contexts.push_back(rctx);
            rerr
        })
    }

    fn bad_arg(self, arg: impl Into<String>) -> RResult<T> {
        self.ctx(Rctx::BadArg(arg.into()))
    }

    fn bad_val(self, val: impl Into<String>) -> RResult<T> {
        self.ctx(Rctx::BadVal(val.into()))
    }

    fn bad_robj(self, robj: &Robj) -> RResult<T> {
        self.bad_val(robj_dbg(robj))
    }

    fn hint(self, cause: impl Into<String>) -> RResult<T> {
        self.ctx(Rctx::Hint(cause.into()))
    }

    fn mistyped(self, ty: impl Into<String>) -> RResult<T> {
        self.ctx(Rctx::Mistyped(ty.into()))
    }

    fn misvalued(self, scope: impl Into<String>) -> RResult<T> {
        self.ctx(Rctx::Misvalued(scope.into()))
    }

    fn plain(self, msg: impl Into<String>) -> RResult<T> {
        self.ctx(Rctx::Plain(msg.into()))
    }

    fn when(self, env: impl Into<String>) -> RResult<T> {
        self.ctx(Rctx::When(env.into()))
    }
}

#[extendr]
impl RPolarsErr {
    pub fn new() -> Self {
        RPolarsErr::new_from_ctxs(VecDeque::new())
    }

    pub fn contexts(&self) -> Robj {
        let plist = Pairlist::from_pairs(self.contexts.iter().rev().map(|rctx| match rctx {
            Rctx::BadArg(arg) => ("BadArgument", arg),
            Rctx::BadVal(val) => ("BadValue", val),
            Rctx::Extendr(err) => ("ExtendrError", err),
            Rctx::Hint(msg) => ("Hint", msg),
            Rctx::Mistyped(ty) => ("TypeMismatch", ty),
            Rctx::Misvalued(scope) => ("ValueOutOfScope", scope),
            Rctx::Plain(msg) => ("PlainErrorMessage", msg),
            Rctx::Polars(err) => ("PolarsError", err),
            Rctx::When(target) => ("When", target),
        }));
        R!("as.list({{plist}})").expect("internal error: failed to return contexts")
    }

    pub fn pretty_msg(&self) -> String {
        format!("{}", self)
    }

    pub fn bad_arg(&self, s: String) -> Self {
        self.push_back_rctx(Rctx::BadArg(s))
    }

    pub fn bad_robj(&self, r: Robj) -> Self {
        self.bad_val(robj_dbg(&r))
    }

    pub fn bad_val(&self, s: String) -> Self {
        self.push_back_rctx(Rctx::BadVal(s))
    }

    pub fn hint(&self, s: String) -> Self {
        self.push_back_rctx(Rctx::Hint(s))
    }

    pub fn mistyped(&self, s: String) -> Self {
        self.push_back_rctx(Rctx::Mistyped(s))
    }

    pub fn misvalued(&self, s: String) -> Self {
        self.push_back_rctx(Rctx::Misvalued(s))
    }

    pub fn plain(&self, s: String) -> Self {
        self.push_back_rctx(Rctx::Plain(s))
    }

    pub fn rcall(&self, c: String) -> Self {
        let mut err = self.clone();
        err.rcall = Some(c);
        err
    }

    pub fn get_rcall(&self) -> Nullable<String> {
        self.rcall.clone().into()
    }

    pub fn rinfo(&self, i: String) -> Self {
        let mut err = self.clone();
        err.rinfo = Some(i);
        err
    }

    pub fn get_rinfo(&self) -> Nullable<String> {
        self.rinfo.clone().into()
    }

    pub fn when(&self, s: String) -> Self {
        self.push_back_rctx(Rctx::When(s))
    }
}

impl RPolarsErr {
    fn new_from_ctxs(ctxs: VecDeque<Rctx>) -> Self {
        RPolarsErr {
            contexts: ctxs,
            rcall: None,
            rinfo: None,
        }
    }

    fn push_back_rctx(&self, rctx: Rctx) -> Self {
        let mut err = self.clone();
        err.contexts.push_back(rctx);
        err
    }
}

impl std::fmt::Display for RPolarsErr {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        use core::fmt::Write;
        use indenter::indented;
        writeln!(f, "Execution halted with the following contexts")?;
        if let Some(i) = &self.rinfo {
            writeln!(indented(f).ind(0), "In R: {}", i)?
        }
        if let Some(c) = &self.rcall {
            writeln!(indented(f).ind(0), "During function call [{}]", c)?
        }
        Ok(self
            .contexts
            .iter()
            .rev()
            .enumerate()
            .try_for_each(|(idx, ctx)| writeln!(indented(f).ind(idx + 1), "{}", ctx))?)
    }
}

impl From<RPolarsErr> for String {
    fn from(rerr: RPolarsErr) -> Self {
        rerr.pretty_msg()
    }
}

impl<E: std::error::Error> From<E> for RPolarsErr {
    fn from(err: E) -> Self {
        RPolarsErr::new_from_ctxs(VecDeque::from([Rctx::Plain(rdbg(err))]))
    }
}

pub fn extendr_to_rpolars_err(extendr_err: extendr_api::Error) -> RPolarsErr {
    RPolarsErr::new_from_ctxs(VecDeque::from([Rctx::Extendr(rdbg(extendr_err))]))
}

// impl From<extendr_api::Error> for RPolarsErr {
//     fn from(extendr_err: extendr_api::Error) -> Self {
//         RPolarsErr::new_from_ctxs(VecDeque::from([Rctx::Extendr(rdbg(extendr_err))]))
//     }
// }

pub fn polars_to_rpolars_err(polars_err: polars::error::PolarsError) -> RPolarsErr {
    let mut rerr = RPolarsErr::new();
    rerr.contexts.push_back(Rctx::Polars(rdbg(&polars_err)));
    match polars_err {
        polars::prelude::PolarsError::InvalidOperation(x) => {
            rerr.contexts.push_back(Rctx::Hint(format!(
                "something (likely a column) with name {:?} is not found",
                x
            )));
        }
        _ => {}
    };
    rerr
}

// impl From<polars::error::PolarsError> for RPolarsErr {
//     fn from(polars_err: polars::error::PolarsError) -> Self {
//         let mut rerr = RPolarsErr::new();
//         rerr.contexts.push_back(Rctx::Polars(rdbg(&polars_err)));
//         match polars_err {
//             polars::prelude::PolarsError::InvalidOperation(x) => {
//                 rerr.contexts.push_back(Rctx::Hint(format!(
//                     "something (likely a column) with name {:?} is not found",
//                     x
//                 )));
//             }
//             _ => {}
//         };
//         rerr
//     }
// }

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
        if s.len() > 128 { "...]  " } else { "" },
        robj.rtype(),
        call!("base::class", robj).expect("internal error: could not use base::class(robj)")
    )
}

#[extendr]
pub fn test_rpolarserr() -> RResult<String> {
    rerr().bad_val("-1").mistyped("usize").bad_arg("path")
}

extendr_module! {
    mod rpolarserr;
    impl RPolarsErr;
    fn test_rpolarserr;
}
