use crate::conversion::Wrap;
use crate::expr::ToExprs;
use crate::{PlRDataFrame, PlRExpr, PlRSeries, RPolarsErr};
use polars::lazy::dsl;
use polars::prelude::*;
use savvy::{savvy, StringSexp};

#[savvy]
pub fn col(name: &str) -> savvy::Result<PlRExpr> {
    Ok(dsl::col(name).into())
}

#[savvy]
pub fn cols(names: StringSexp) -> savvy::Result<PlRExpr> {
    let names = names.iter().collect::<Vec<_>>();
    Ok(dsl::cols(&names).into())
}
