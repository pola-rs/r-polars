use crate::{PlRExpr, RPolarsErr, prelude::*};
use savvy::{RawSexp, Result, Sexp, savvy};
use std::io::{BufReader, BufWriter};

#[savvy]
impl PlRExpr {
    fn serialize_binary(&self) -> Result<Sexp> {
        let mut dump = Vec::new();
        let writer = BufWriter::new(&mut dump);
        ciborium::into_writer(&self.inner, writer)
            .map_err(|err| RPolarsErr::Other(err.to_string()))?;
        dump.try_into()
    }

    fn serialize_json(&self) -> Result<Sexp> {
        let dump =
            serde_json::to_string(&self.inner).map_err(|err| RPolarsErr::Other(err.to_string()))?;
        dump.try_into()
    }

    fn deserialize_binary(data: RawSexp) -> Result<PlRExpr> {
        let data = data.as_slice();
        let reader = BufReader::new(data);
        let expr = ciborium::from_reader::<Expr, _>(reader)
            .map_err(|err| RPolarsErr::Other(err.to_string()))?;
        Ok(expr.into())
    }

    fn deserialize_json(data: &str) -> Result<PlRExpr> {
        let inner: Expr = serde_json::from_str(data).map_err(|_| {
            let msg = "could not deserialize input into an expression";
            RPolarsErr::Other(msg.to_string())
        })?;
        Ok(inner.into())
    }
}
