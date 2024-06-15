use polars::prelude::PolarsError;
use std::fmt::{Debug, Formatter};
use std::io::Error;
use thiserror::Error;

#[derive(Error)]
pub enum RPolarsErr {
    #[error(transparent)]
    Polars(#[from] PolarsError),
    #[error("{0}")]
    Other(String),
}

impl std::convert::From<std::io::Error> for RPolarsErr {
    fn from(value: Error) -> Self {
        RPolarsErr::Other(format!("{value:?}"))
    }
}

impl std::convert::From<RPolarsErr> for savvy::Error {
    fn from(err: RPolarsErr) -> Self {
        let default = || savvy::Error::new(format!("{:?}", &err).as_str());

        match err {
            _ => default(),
        }
    }
}

impl Debug for RPolarsErr {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        use RPolarsErr::*;
        match self {
            Polars(err) => write!(f, "{err:?}"),
            Other(err) => write!(f, "BindingsError: {err:?}"),
        }
    }
}
