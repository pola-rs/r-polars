use crate::rdataframe::{RPolarsDataFrame, RPolarsLazyFrame};
use crate::robj_to;
use crate::rpolarserr::*;
use crate::series::RPolarsSeries;
use extendr_api::prelude::*;
use polars::lazy::dsl;
use polars::prelude as pl;
use polars_core::functions as pl_functions;
use std::result::Result;

#[extendr]
fn concat_lf(
    l: Robj,
    rechunk: bool,
    parallel: bool,
    to_supertypes: bool,
) -> RResult<RPolarsLazyFrame> {
    let vlf = robj_to!(Vec, PLLazyFrame, l)?;
    dsl::concat(
        vlf,
        pl::UnionArgs {
            parallel,
            rechunk,
            to_supertypes,
        },
    )
    .map_err(polars_to_rpolars_err)
    .map(RPolarsLazyFrame)
}

#[extendr]
fn concat_lf_diagonal(
    l: Robj,
    rechunk: bool,
    parallel: bool,
    to_supertypes: bool,
) -> RResult<RPolarsLazyFrame> {
    let vlf = robj_to!(Vec, PLLazyFrame, l)?;
    dsl::concat_lf_diagonal(
        vlf,
        pl::UnionArgs {
            rechunk,
            parallel,
            to_supertypes,
        },
    )
    .map_err(polars_to_rpolars_err)
    .map(RPolarsLazyFrame)
}

#[extendr]
pub fn concat_df_horizontal(l: Robj) -> RResult<RPolarsDataFrame> {
    let df_vec = robj_to!(Vec, PLDataFrame, l)?;
    pl_functions::concat_df_horizontal(&df_vec)
        .map_err(polars_to_rpolars_err)
        .map(RPolarsDataFrame)
}

#[extendr]
pub fn concat_series(l: Robj, rechunk: Robj, to_supertypes: Robj) -> RResult<RPolarsSeries> {
    let to_supertypes = robj_to!(bool, to_supertypes)?;
    let mut s_vec = robj_to!(Vec, PLSeries, l)?;

    // find any common supertype and cast to it
    if to_supertypes {
        let shared_supertype: RResult<Option<pl::DataType>> = s_vec
            .iter()
            .map(|s| s.dtype().clone())
            .fold(Ok(None), |acc, x| match acc {
                Err(err) => Err(err),
                Ok(None) => Ok(Some(x)), // first fold, acc is None, just us x,
                Ok(Some(acc)) => polars_core::utils::get_supertype(&acc, &x)
                    .ok_or(RPolarsErr::new().plain("Series' have no common supertype".to_string()))
                    .map(Some),
            });
        let shared_supertype = shared_supertype?.expect("cannot be None, unless empty s_vec");

        for i in 0..s_vec.len() {
            if *s_vec[i].dtype() != shared_supertype {
                s_vec[i] = s_vec[i]
                    .cast(&shared_supertype)
                    .map_err(polars_to_rpolars_err)?;
            };
        }
    }

    let mut iter = s_vec.into_iter();
    let mut first_s = iter
        .next()
        .ok_or(RPolarsErr::new().plain("no series found to concatenate".into()))?;
    for next_s in iter {
        first_s.append(&next_s).map_err(polars_to_rpolars_err)?;
    }

    if robj_to!(bool, rechunk)? {
        Ok(first_s.rechunk().into())
    } else {
        Ok(first_s.into())
    }
}

extendr_module! {
    mod concat;
    fn concat_lf;
    fn concat_lf_diagonal;
    fn concat_df_horizontal;
    fn concat_series;
}
