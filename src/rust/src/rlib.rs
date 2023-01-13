use crate::rdataframe::rexpr::Expr;
use crate::rdataframe::DataFrame;
use crate::{rdataframe::VecDataFrame, utils::r_result_list};

use crate::rdataframe::rexpr::ProtoExprArray;
use extendr_api::prelude::*;
use polars::prelude as pl;

use crate::rdataframe::rseries::Series;
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

#[extendr]
pub fn mem_address(robj: Robj) -> String {
    let ptr_raw = unsafe { robj.external_ptr_addr::<usize>() };
    let ptr_val = ptr_raw as usize;
    format!("{:#012x}", ptr_val)
}

#[extendr]
fn min_exprs(exprs: &ProtoExprArray) -> Expr {
    let exprs = exprs.to_vec("select");
    polars::lazy::dsl::min_exprs(exprs).into()
}

#[extendr]
fn max_exprs(exprs: &ProtoExprArray) -> Expr {
    let exprs = exprs.to_vec("select");
    polars::lazy::dsl::max_exprs(exprs).into()
}

#[extendr]
fn coalesce_exprs(exprs: &ProtoExprArray) -> Expr {
    let exprs = exprs.to_vec("select");
    polars::lazy::dsl::coalesce(&exprs).into()
}

#[extendr]
fn sum_exprs(exprs: &ProtoExprArray) -> Expr {
    let exprs = exprs.to_vec("select");
    polars::lazy::dsl::sum_exprs(exprs).into()
}

#[extendr]
fn concat_lst(exprs: &ProtoExprArray) -> Expr {
    let exprs = exprs.to_vec("select");
    polars::lazy::dsl::concat_lst(exprs).into()
}

use crate::rdatatype::RPolarsTimeUnit;

#[extendr]
fn r_date_range(
    start: f64,
    stop: f64,
    every: &str,
    closed: &str, //Wap<ClosedWindow>
    name: &str,
    tu: &str,
    tz: Nullable<String>,
) -> List {
    use crate::rdatatype::new_closed_window;
    use crate::rdatatype::str_to_timeunit;
    use crate::utils::try_f64_into_i64;
    use crate::utils::wrappers::null_to_opt;
    use pl::IntoSeries;
    let res = || -> std::result::Result<Series, String> {
        Ok(Series(
            polars::time::date_range_impl(
                name,
                try_f64_into_i64(start)?,
                try_f64_into_i64(stop)?,
                pl::Duration::parse(every),
                new_closed_window(closed)?,
                str_to_timeunit(tu)?,
                null_to_opt(tz).as_ref(),
            )
            .into_series(),
        ))
    }()
    .map_err(|err| format!("in r_date_range: {}", err));
    r_result_list(res)
}

extendr_module! {
    mod rlib;
    fn concat_df;
    fn hor_concat_df;
    fn diag_concat_df;
    fn min_exprs;
    fn max_exprs;
    fn coalesce_exprs;
    fn sum_exprs;
    fn mem_address;
    fn concat_lst;
    fn r_date_range;
}
