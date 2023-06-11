use extendr_api::{extendr, extendr_module, symbol::class_symbol, Attributes, Rinternals, Robj};

#[derive(Clone, Debug)]
pub enum Rctx {
    Extendr(String),
    Hint(String),
    Plain(String),
    Polars(String),
    When(String),
    TypeMismatch(String, String, String),
}

#[derive(Clone, Debug)]
pub struct Rerr(Vec<Rctx>);
pub type RResult<T> = core::result::Result<T, Rerr>;

pub trait WithRctx<T> {
    fn ctx(self, rctx: Rctx) -> RResult<T>;
    fn hint<S: Into<String>>(self, msg: S) -> RResult<T>;
    fn when<S: Into<String>>(self, msg: S) -> RResult<T>;
}

impl<T: Clone, E: Into<Rerr>> WithRctx<T> for core::result::Result<T, E> {
    fn ctx(self, rctx: Rctx) -> RResult<T> {
        self.map_err(|e| {
            let mut rerr = e.into();
            rerr.0.push(rctx);
            rerr
        })
    }

    fn hint<S: Into<String>>(self, msg: S) -> RResult<T> {
        self.ctx(Rctx::Hint(msg.into()))
    }

    fn when<S: Into<String>>(self, msg: S) -> RResult<T> {
        self.ctx(Rctx::When(msg.into()))
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
            .map(|rctx| match rctx {
                Rctx::Extendr(e) => format!("Encountered the following error in Extendr:\n{}", e),
                Rctx::Hint(e) => format!("An error occured likely because {}", e),
                Rctx::Plain(e) => e.clone(),
                Rctx::Polars(e) => format!("Encountered the following error in Polars:\n{}", e),
                Rctx::TypeMismatch(name, expected, received) => {
                    format!(
                        "The argument [{}] should be a [{}] value, but got [{}] instead",
                        name, expected, received
                    )
                }
                Rctx::When(e) => format!("When {}", e),
            })
            .fold(String::from("Error"), |msg, ctx| {
                format!("{}: {}", msg, ctx)
            })
    }

    pub fn contexts(&self) -> Vec<&str> {
        self.0
            .iter()
            .rev()
            .map(|rctx| match rctx {
                Rctx::Extendr(_) => "Extendr",
                Rctx::Hint(_) => "Hint",
                Rctx::Plain(_) => "Plain",
                Rctx::Polars(_) => "Polars",
                Rctx::TypeMismatch(_, _, _) => "TypeMismatch",
                Rctx::When(_) => "When",
            })
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
        .ctx(Rctx::TypeMismatch(
            "path".to_string(),
            "String".to_string(),
            "2.0".to_string(),
        ))
        .when("calling test function")
}

extendr_module! {
    mod rerr;
    impl Rerr;
    fn test_rerr;
}
