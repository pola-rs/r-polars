use crate::{error::RPolarsErr, prelude::*, PlRSeries};
use polars_core::prelude::*;
use savvy::{
    savvy, OwnedIntegerSexp, OwnedListSexp, OwnedLogicalSexp, OwnedRealSexp, OwnedStringSexp, Sexp,
};

#[savvy]
impl PlRSeries {
    // TODO: check i32::MIN etc.?
    // TODO: export int64 as string, bit64::integer64
    pub fn to_r_vector(&self) -> savvy::Result<Sexp> {
        let series = &self.series;
        match series.dtype() {
            DataType::Boolean => Ok(<Sexp>::from(Wrap(series.bool().unwrap()))),
            DataType::UInt8 | DataType::UInt16 | DataType::Int8 | DataType::Int16 => Ok(
                <Sexp>::from(Wrap(series.cast(&DataType::Int32).unwrap().i32().unwrap())),
            ),
            DataType::Int32 => Ok(<Sexp>::from(Wrap(series.i32().unwrap()))),
            DataType::UInt64 | DataType::Int64 => Ok(<Sexp>::from(Wrap(
                series.cast(&DataType::Float64).unwrap().f64().unwrap(),
            ))),
            DataType::Float64 => Ok(<Sexp>::from(Wrap(series.f64().unwrap()))),
            DataType::String => Ok(<Sexp>::from(Wrap(series.str().unwrap()))),
            DataType::Categorical(_, _) | DataType::Enum(_, _) => Ok(<Sexp>::from(Wrap(
                series.cast(&DataType::String).unwrap().str().unwrap(),
            ))),
            _ => todo!(),
        }
    }
}
