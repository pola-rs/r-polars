use crate::{prelude::*, PlRExpr, RPolarsErr};
use polars::lazy::dsl;
use savvy::{savvy, ListSexp, Result};

#[savvy]
pub fn all_horizontal(exprs: ListSexp) -> Result<PlRExpr> {
    let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
    let e = dsl::all_horizontal(exprs).map_err(RPolarsErr::from)?;
    Ok(e.into())
}

#[savvy]
pub fn any_horizontal(exprs: ListSexp) -> Result<PlRExpr> {
    let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
    let e = dsl::any_horizontal(exprs).map_err(RPolarsErr::from)?;
    Ok(e.into())
}

#[savvy]
pub fn max_horizontal(exprs: ListSexp) -> Result<PlRExpr> {
    let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
    let e = dsl::max_horizontal(exprs).map_err(RPolarsErr::from)?;
    Ok(e.into())
}

#[savvy]
pub fn min_horizontal(exprs: ListSexp) -> Result<PlRExpr> {
    let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
    let e = dsl::min_horizontal(exprs).map_err(RPolarsErr::from)?;
    Ok(e.into())
}

#[savvy]
pub fn sum_horizontal(exprs: ListSexp) -> Result<PlRExpr> {
    let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
    let e = dsl::sum_horizontal(exprs).map_err(RPolarsErr::from)?;
    Ok(e.into())
}

#[savvy]
pub fn mean_horizontal(exprs: ListSexp) -> Result<PlRExpr> {
    let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
    let e = dsl::mean_horizontal(exprs).map_err(RPolarsErr::from)?;
    Ok(e.into())
}
