use crate::lazy::dsl::Expr;
use crate::rdataframe::DataFrame;
use crate::rpolarserr::{rdbg, RResult};
use crate::{rdataframe::VecDataFrame, utils::r_result_list};

use crate::lazy::dsl::ProtoExprArray;
use crate::rdatatype::robj_to_timeunit;
use crate::robj_to;
use crate::series::Series;
use extendr_api::prelude::*;
use polars::prelude as pl;
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
fn diag_concat_df(dfs: &VecDataFrame) -> List {
    let df = pl_functions::diag_concat_df(&dfs.0[..]).map(DataFrame);
    r_result_list(df.map_err(|err| format!("{:?}", err)))
}

#[extendr]
pub fn hor_concat_df(dfs: &VecDataFrame) -> List {
    let df = pl_functions::hor_concat_df(&dfs.0[..]).map(DataFrame);
    r_result_list(df.map_err(|err| format!("{:?}", err)))
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
    let exprs: Vec<pl::Expr> = exprs.to_vec("select");
    polars::lazy::dsl::coalesce(exprs.as_slice()).into()
}

#[extendr]
fn sum_exprs(exprs: &ProtoExprArray) -> Expr {
    let exprs = exprs.to_vec("select");
    polars::lazy::dsl::sum_exprs(exprs).into()
}

#[extendr]
fn concat_list(exprs: &ProtoExprArray) -> Result<Expr, String> {
    let exprs = exprs.to_vec("select");
    Ok(Expr(
        polars::lazy::dsl::concat_list(exprs).map_err(|err| err.to_string())?,
    ))
}

#[extendr]
fn r_date_range(
    start: f64,
    stop: f64,
    every: &str,
    closed: &str, //Wap<ClosedWindow>
    name: &str,
    tu: Robj,
    tz: Nullable<String>,
) -> List {
    use crate::rdatatype::new_closed_window;
    use crate::utils::try_f64_into_i64;

    use pl::IntoSeries;

    let res = || -> std::result::Result<Series, String> {
        Ok(Series(
            polars::time::date_range_impl(
                name,
                try_f64_into_i64(start)?,
                try_f64_into_i64(stop)?,
                pl::Duration::parse(every),
                new_closed_window(closed)?,
                robj_to_timeunit(tu)?,
                tz.into_option().as_ref(),
            )
            .map_err(|err| format!("in r_date_range: {}", err))?
            .into_series(),
        ))
    }();
    r_result_list(res)
}

#[extendr]
fn r_date_range_lazy(
    start: &Expr,
    end: &Expr,
    every: &str,
    closed: &str,
    tz: Nullable<String>,
) -> List {
    use crate::rdatatype::new_closed_window;
    let res = || -> std::result::Result<Expr, String> {
        Ok(Expr(
            polars::lazy::dsl::functions::date_range(
                start.0.clone(),
                end.0.clone(),
                pl::Duration::parse(every),
                new_closed_window(closed)?,
                tz.into_option(),
            )
            .explode(),
        ))
    }();
    r_result_list(res)
}

//TODO py-polars have some fancy transmute conversions TOExprs trait, maybe imple that too
//for now just use inner directly
#[extendr]
fn as_struct(exprs: Robj) -> Result<Expr, String> {
    Ok(polars::lazy::dsl::as_struct(
        crate::utils::list_expr_to_vec_pl_expr(exprs, true)?.as_slice(),
    )
    .into())
}

#[extendr]
fn struct_(exprs: Robj, eager: Robj, schema: Robj) -> Result<Robj, String> {
    use crate::rdatatype::RPolarsDataType;
    let struct_expr = as_struct(exprs)?;
    let eager = robj_to!(bool, eager)?;

    let struct_expr = if !schema.is_null() {
        let schema: Vec<RPolarsDataType> = robj_to!(Vec, RPolarsDataType, schema)?;
        dbg!(&schema);
        todo!()
    } else {
        struct_expr
    };

    if eager {
        use pl::*;
        let df = pl::DataFrame::empty()
            .lazy()
            .select(&[struct_expr.0])
            .collect()
            .map_err(|err| format!("during eager evaluation of struct: {}", err))?;
        Ok(crate::rdataframe::DataFrame(df).into())
    } else {
        Ok(struct_expr.into())
    }
}

// #[extendr]
// fn field_to_rust2(arrow_array: Robj) -> Result<Robj, String> {
//     let x = crate::arrow_interop::to_rust::arrow_array_to_rust(arrow_array)?;

//     rprintln!("hurray we read an arrow field {:?}", x);
//     Ok(extendr_api::NULL.into())
// }

#[extendr]
fn arrow_stream_to_rust(rbr: Robj) {
    let x = crate::arrow_interop::to_rust::arrow_array_stream_to_rust(rbr, None).unwrap();
    dbg!(x);
}

#[extendr]
fn rb_list_to_df(r_batches: List, names: Vec<String>) -> Result<DataFrame, String> {
    let mut iter = r_batches.into_iter().map(|(_, robj)| {
        let robj = call!(r"\(x) x$columns", robj)?;
        let l = robj.as_list().ok_or_else(|| "not a list!?".to_string())?;
        crate::arrow_interop::to_rust::rb_to_rust_df(l, &names)
    });
    let mut df_acc = iter
        .next()
        .unwrap_or_else(|| Ok(pl::DataFrame::default()))?;
    for df in iter {
        df_acc.vstack_mut(&df?).map_err(|err| err.to_string())?;
    }
    Ok(DataFrame(df_acc))
}

#[extendr]
pub fn dtype_str_repr(dtype: Robj) -> RResult<String> {
    let dtype = robj_to!(RPolarsDataType, dtype)?.0;
    Ok(dtype.to_string())
}

// -- Meta Robj functions
#[extendr]
pub fn mem_address(robj: Robj) -> String {
    let ptr_raw = unsafe { robj.external_ptr_addr::<usize>() };
    let ptr_val = ptr_raw as usize;
    format!("{:#012x}", ptr_val)
}

#[extendr] //could be used to check copying/cloning behavior of R objects
pub fn clone_robj(robj: Robj) -> Robj {
    robj.clone()
}

// -- Special functions just for unit testing
#[extendr]
fn test_robj_to_usize(robj: Robj) -> RResult<String> {
    robj_to!(usize, robj).map(rdbg)
}

#[extendr]
fn test_robj_to_f64(robj: Robj) -> RResult<String> {
    robj_to!(f64, robj).map(rdbg)
}

#[extendr]
fn test_robj_to_i64(robj: Robj) -> RResult<String> {
    robj_to!(i64, robj).map(rdbg)
}

#[extendr]
fn test_robj_to_u32(robj: Robj) -> RResult<String> {
    robj_to!(u32, robj).map(rdbg)
}

#[extendr]
fn test_robj_to_i32(robj: Robj) -> RResult<String> {
    robj_to!(i32, robj).map(rdbg)
}

#[extendr]
fn test_print_string(s: String) {
    rprintln!("{}", s);
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

    fn concat_list;
    fn r_date_range;
    fn r_date_range_lazy;
    fn as_struct;
    fn struct_;
    //fn field_to_rust2;
    //fn series_from_arrow;
    //fn rb_to_df;
    fn rb_list_to_df;
    fn arrow_stream_to_rust;
    fn dtype_str_repr;

    fn mem_address;
    fn clone_robj;

    fn test_robj_to_usize;
    fn test_robj_to_f64;
    fn test_robj_to_i64;
    fn test_robj_to_u32;
    fn test_robj_to_i32;
    fn test_print_string;
}
