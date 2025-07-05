use polars::prelude::PolarsError;
use std::fmt::{Debug, Formatter};
use strum::ParseError;
use thiserror::Error;

// TODO: better error handling
#[derive(Error)]
pub enum RPolarsErr {
    #[error(transparent)]
    Polars(#[from] PolarsError),
    #[error("{0}")]
    Other(String),
}

impl From<std::io::Error> for RPolarsErr {
    fn from(value: std::io::Error) -> Self {
        RPolarsErr::Other(format!("{value:?}"))
    }
}

impl From<ParseError> for RPolarsErr {
    fn from(value: ParseError) -> Self {
        RPolarsErr::Other(format!("{value:?}"))
    }
}

impl From<RPolarsErr> for savvy::Error {
    fn from(err: RPolarsErr) -> Self {
        use RPolarsErr::*;
        let default = || savvy::Error::new(format!("{}", &err).as_str());

        match err {
            Polars(PolarsError::ColumnNotFound(x)) => {
                savvy::Error::new(format!("Column(s) not found: {x}").as_str())
            }
            Polars(PolarsError::Duplicate(x)) => {
                savvy::Error::new(format!("Duplicated column(s): {x}").as_str())
            }
            Polars(PolarsError::InvalidOperation(x)) => {
                savvy::Error::new(format!("Invalid operation: {x}").as_str())
            }
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
