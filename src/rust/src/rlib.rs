use crate::rdataframe::DataFrame;
use crate::{rdataframe::VecDataFrame, utils::r_result_list};
use extendr_api::prelude::*;
use polars::prelude as pl;

use polars_core::functions as pl_functions;

#[extendr]
fn concat_df(vdf: &VecDataFrame) -> List {
    //-> PyResult<PyDataFrame> {

    use polars_core::error::PolarsResult;
    use polars_core::utils::rayon::prelude::*;

    let first = (*vdf.0.iter().peekable().peek().unwrap()).clone();
    let iter = vdf.0.clone().into_iter().map(|df| df);
    let identity_df = first.clone().slice(0, 0);
    let rdfs: Vec<pl::PolarsResult<pl::DataFrame>> = iter.map(|df| Ok(df)).collect();
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
        .map(|ok| DataFrame(ok));

    r_result_list(result)
}
//ping

#[extendr]
fn diag_concat_df(dfs: &VecDataFrame) -> List {
    let df = pl_functions::diag_concat_df(&dfs.0[..]).map(|ok| DataFrame(ok));
    r_result_list(df)
}

#[extendr]
pub fn hor_concat_df(dfs: &VecDataFrame) -> List {
    let df = pl_functions::hor_concat_df(&dfs.0[..]).map(|ok| DataFrame(ok));
    r_result_list(df)
}

extendr_module! {
    mod rlib;
    fn concat_df;
    fn hor_concat_df;
    fn diag_concat_df;
}
