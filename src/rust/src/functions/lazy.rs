use crate::conversion::Wrap;
use crate::expr::ToExprs;
use crate::{PlRDataFrame, PlRExpr, PlRSeries, RPolarsErr};
use polars::lazy::dsl;
use polars::prelude::*;
use savvy::{savvy, ListSexp, StringSexp};

#[savvy]
pub fn col(name: &str) -> savvy::Result<PlRExpr> {
    Ok(dsl::col(name).into())
}

#[savvy]
pub fn cols(names: StringSexp) -> savvy::Result<PlRExpr> {
    let names = names.iter().collect::<Vec<_>>();
    Ok(dsl::cols(&names).into())
}

#[savvy]
pub fn dtype_cols(dtypes: ListSexp) -> savvy::Result<PlRExpr> {
    let dtypes = <Wrap<Vec<DataType>>>::try_from(dtypes)?.0;
    Ok(dsl::dtype_cols(&dtypes).into())
}

#[savvy]
pub fn lit_from_bool(value: bool) -> savvy::Result<PlRExpr> {
    Ok(dsl::lit(value).into())
}

#[savvy]
pub fn lit_from_i32(value: i32) -> savvy::Result<PlRExpr> {
    Ok(dsl::lit(value).into())
}

#[savvy]
pub fn lit_from_f64(value: f64) -> savvy::Result<PlRExpr> {
    Ok(dsl::lit(value).into())
}

#[savvy]
pub fn lit_from_str(value: &str) -> savvy::Result<PlRExpr> {
    Ok(dsl::lit(value).into())
}

#[savvy]
pub fn lit_null() -> savvy::Result<PlRExpr> {
    Ok(dsl::lit(Null {}).into())
}

#[savvy]
pub fn lit_from_series(value: PlRSeries) -> savvy::Result<PlRExpr> {
    Ok(dsl::lit(value.series).into())
}

// TODO: Raw type support <https://github.com/yutannihilation/savvy/issues/30>
