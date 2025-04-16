use crate::{PlRDataFrame, RPolarsErr, prelude::*};
use savvy::{OwnedRawSexp, RawSexp, Result, Sexp, savvy};
use std::io::BufReader;

#[savvy]
impl PlRDataFrame {
    fn serialize_binary(&mut self) -> Result<Sexp> {
        let buf = self.df.serialize_to_bytes().map_err(RPolarsErr::from)?;
        OwnedRawSexp::try_from_iter(buf).map(Into::into)
    }

    fn deserialize_binary(data: RawSexp) -> Result<Self> {
        let mut reader = BufReader::new(data.as_slice());
        DataFrame::deserialize_from_reader(&mut reader)
            .map(PlRDataFrame::from)
            .map_err(|_| "The input value is not a valid serialized DataFrame.".into())
    }
}
