use crate::{PlRLazyFrame, RPolarsErr, prelude::*};
use savvy::{RawSexp, Result, Sexp, savvy};
use std::io::{BufReader, BufWriter};

#[savvy]
impl PlRLazyFrame {
    fn serialize_binary(&self) -> Result<Sexp> {
        let mut dump = Vec::new();
        let writer = BufWriter::new(&mut dump);
        self.ldf
            .logical_plan
            .serialize_versioned(writer, Default::default())
            .map_err(RPolarsErr::from)?;
        dump.try_into()
    }

    fn serialize_json(&self) -> Result<Sexp> {
        let dump = serde_json::to_string(&self.ldf.logical_plan)
            .map_err(|err| RPolarsErr::Other(err.to_string()))?;
        dump.try_into()
    }

    fn deserialize_binary(data: RawSexp) -> Result<Self> {
        let reader = BufReader::new(data.as_slice());
        let lp = DslPlan::deserialize_versioned(reader).map_err(RPolarsErr::from)?;
        Ok(LazyFrame::from(lp).into())
    }
}
