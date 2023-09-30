use crate::rdataframe::DataFrame;
use crate::robj_to;

use crate::rdataframe::LazyFrame;
use crate::rpolarserr::*;
use crate::series::Series;
use crate::{rdataframe::VecDataFrame, utils::r_result_list};
use extendr_api::prelude::*;
use polars::lazy::dsl;
use polars::prelude as pl;
use polars_core;
use polars_core::functions as pl_functions;
use std::result::Result;

#[extendr]
fn concat_df(vdf: &VecDataFrame) -> List {
    //-> PyResult<PyDataFrame> {

    use polars_core::error::PolarsResult;
    use polars_core::utils::rayon::prelude::*;

    let identity_df = (*vdf.0.iter().peekable().peek().unwrap())
        .clone()
        .slice(0, 0);
    let rdfs: Vec<pl::PolarsResult<pl::DataFrame>> =
        vdf.0.iter().map(|df| Ok(df.clone())).collect();
    let identity = || Ok(identity_df.clone());

    let result = polars_core::POOL
        .install(|| {
            rdfs.into_par_iter()
                .fold(identity, |acc: PolarsResult<pl::DataFrame>, df| {
                    let mut acc = acc?;
                    acc.vstack_mut(&df?)?;
                    Ok(acc)
                })
                .reduce(identity, |acc, df| {
                    let mut acc = acc?;
                    acc.vstack_mut(&df?)?;
                    Ok(acc)
                })
        })
        .map(DataFrame);

    r_result_list(result.map_err(|err| format!("{:?}", err)))
}

#[extendr]
fn concat_lf(l: Robj, rechunk: bool, parallel: bool, to_supertypes: bool) -> RResult<LazyFrame> {
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
    .map(LazyFrame)
}

#[extendr]
fn diag_concat_df(dfs: Robj) -> RResult<DataFrame> {
    let df_vec = robj_to!(Vec, PLDataFrame, dfs)?;
    pl_functions::diag_concat_df(&df_vec)
        .map_err(polars_to_rpolars_err)
        .map(DataFrame)
}

#[extendr]
fn diag_concat_lf(l: Robj, rechunk: bool, parallel: bool) -> RResult<LazyFrame> {
    let vlf = robj_to!(Vec, PLLazyFrame, l)?;
    dsl::diag_concat_lf(vlf, rechunk, parallel)
        .map_err(polars_to_rpolars_err)
        .map(LazyFrame)
}

#[extendr]
pub fn hor_concat_df(l: Robj) -> RResult<DataFrame> {
    let df_vec = robj_to!(Vec, PLDataFrame, l)?;
    pl_functions::hor_concat_df(&df_vec)
        .map_err(polars_to_rpolars_err)
        .map(DataFrame)
}

#[extendr]
pub fn concat_series(l: Robj, rechunk: Robj, to_supertypes: Robj) -> RResult<Series> {
    let to_supertypes = robj_to!(bool, to_supertypes)?;
    let mut s_vec = robj_to!(Vec, PLSeries, l)?;

    // find any common supertype and cast to it
    if to_supertypes {
        let shared_supertype: RResult<Option<pl::DataType>> = s_vec
            .iter()
            .map(|s| s.dtype().clone())
            .fold(Ok(None), |acc, x| match acc {
                Err(err) => Err(err),
                Ok(None) => Ok(Some(x)),
                Ok(Some(acc)) => polars_core::utils::get_supertype(&acc, &x)
                    .ok_or(RPolarsErr::new().plain("Series' have no common supertype".to_string()))
                    .map(|dt| Some(dt)),
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

    fn concat_df;
    fn concat_lf;
    fn diag_concat_df;
    fn diag_concat_lf;
    fn hor_concat_df;
    fn concat_series;
}
