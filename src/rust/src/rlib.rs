use crate::lazy::dsl::Expr;
use crate::lazy::dsl::ProtoExprArray;
use crate::rdataframe::DataFrame;
use crate::robj_to;
use crate::utils::extendr_concurrent::{ParRObj, ThreadCom};
use crate::RFnSignature;
use crate::CONFIG;
use crate::rpolarserr::{rdbg, RResult};
use crate::series::Series;
use extendr_api::prelude::*;
use polars::prelude as pl;
use polars_core::functions as pl_functions;

use std::result::Result;

#[extendr]
fn min_exprs(exprs: &ProtoExprArray) -> Expr {
    let exprs = exprs.to_vec("select");
    polars::lazy::dsl::min_horizontal(exprs).into()
}

#[extendr]
fn max_exprs(exprs: &ProtoExprArray) -> Expr {
    let exprs = exprs.to_vec("select");
    polars::lazy::dsl::max_horizontal(exprs).into()
}

#[extendr]
fn coalesce_exprs(exprs: &ProtoExprArray) -> Expr {
    let exprs: Vec<pl::Expr> = exprs.to_vec("select");
    pl::coalesce(exprs.as_slice()).into()
}

#[extendr]
fn sum_exprs(exprs: &ProtoExprArray) -> Expr {
    let exprs = exprs.to_vec("select");
    polars::lazy::dsl::sum_horizontal(exprs).into()
}

#[extendr]
fn concat_list(exprs: &ProtoExprArray) -> Result<Expr, String> {
    let exprs = exprs.to_vec("select");
    Ok(Expr(pl::concat_list(exprs).map_err(|err| err.to_string())?))
}

#[extendr]
fn concat_str(dotdotdot: Robj, separator: Robj) -> RResult<Expr> {
    Ok(pl::concat_str(
        robj_to!(VecPLExprCol, dotdotdot)?,
        robj_to!(str, separator)?,
    )
    .into())
}

#[extendr]
fn r_date_range_lazy(
    start: Robj,
    end: Robj,
    every: Robj,
    closed: Robj,
    time_unit: Robj,
    time_zone: Robj,
    explode: Robj,
) -> RResult<Expr> {
    let expr = polars::lazy::dsl::functions::date_range(
        robj_to!(PLExprCol, start)?,
        robj_to!(PLExprCol, end)?,
        robj_to!(pl_duration, every)?,
        robj_to!(new_closed_window, closed)?,
        robj_to!(Option, timeunit, time_unit)?,
        robj_to!(Option, String, time_zone)?,
    );
    if robj_to!(bool, explode)? {
        Ok(Expr(expr.explode()))
    } else {
        Ok(Expr(expr))
    }
}

//TODO py-polars have some fancy transmute conversions TOExprs trait, maybe imple that too
//for now just use inner directly
#[extendr]
fn as_struct(exprs: Robj) -> Result<Expr, String> {
    Ok(pl::as_struct(crate::utils::list_expr_to_vec_pl_expr(exprs, true, true)?.as_slice()).into())
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

#[extendr]
fn new_arrow_stream() -> Robj {
    crate::arrow_interop::to_rust::new_arrow_stream_internal()
}
use crate::rpolarserr::*;
#[extendr]
fn arrow_stream_to_df(robj_str: Robj) -> RResult<Robj> {
    let s = crate::arrow_interop::to_rust::arrow_stream_to_series_internal(robj_str)?;
    let ca = s
        .struct_()
        .map_err(polars_to_rpolars_err)
        .when("unpack struct from producer")
        .hint("producer exported a plain Series not a Struct series")?;
    let df: pl::DataFrame = ca.clone().into();
    Ok(DataFrame(df).into_robj())
}

#[extendr]
fn arrow_stream_to_series(robj_str: Robj) -> RResult<Robj> {
    let s = crate::arrow_interop::to_rust::arrow_stream_to_series_internal(robj_str)?;
    Ok(Series(s).into_robj())
}

#[extendr]
unsafe fn export_df_to_arrow_stream(robj_df: Robj, robj_str: Robj) -> RResult<Robj> {
    let res: ExternalPtr<DataFrame> = robj_df.try_into()?;
    let pl_df = DataFrame(res.0.clone()).0;
    //safety robj_str must be ptr to a arrow2 stream ready to export into
    unsafe {
        crate::arrow_interop::to_rust::export_df_as_stream(pl_df, &robj_str)?;
    }
    Ok(robj_str)
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

// setting functions

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

#[extendr]
fn test_robj_to_expr(robj: Robj) -> RResult<Expr> {
    robj_to!(Expr, robj)
}

#[extendr]
fn test_wrong_call_pl_lit(robj: Robj) -> RResult<Robj> {
    Ok(R!("pl$lit({{robj}})")?) // this call should have been polars::pl$lit(...
}

#[extendr]
fn polars_features() -> List {
    list!(
        full_features = cfg!(feature = "full_features"),
        default = cfg!(feature = "default"),
        simd = cfg!(feature = "simd"),
        rpolars_debug_print = cfg!(feature = "rpolars_debug_print")
    )
}

#[extendr]
fn fold(acc: Robj, lambda: Robj, exprs: Robj) -> RResult<Expr> {
    let par_fn = ParRObj(lambda);
    let f = move |acc: pl::Series, x: pl::Series| {
        let thread_com = ThreadCom::try_from_global(&CONFIG)
            .map_err(|err| pl::polars_err!(ComputeError: err))?;
        thread_com.send(RFnSignature::FnTwoSeriesToSeries(par_fn.clone(), acc, x));
        let s = thread_com.recv().unwrap_series();
        Ok(Some(s))
    };
    Ok(pl::fold_exprs(robj_to!(PLExpr, acc)?, f, robj_to!(Vec, PLExpr, exprs)?).into())
}

#[extendr]
fn reduce(lambda: Robj, exprs: Robj) -> RResult<Expr> {
    let par_fn = ParRObj(lambda);
    let f = move |acc: pl::Series, x: pl::Series| {
        let thread_com = ThreadCom::try_from_global(&CONFIG)
            .map_err(|err| pl::polars_err!(ComputeError: err))?;
        thread_com.send(RFnSignature::FnTwoSeriesToSeries(par_fn.clone(), acc, x));
        let s = thread_com.recv().unwrap_series();
        Ok(Some(s))
    };
    Ok(pl::reduce_exprs(f, robj_to!(Vec, PLExpr, exprs)?).into())
}

extendr_module! {
    mod rlib;

    fn min_exprs;
    fn max_exprs;
    fn coalesce_exprs;
    fn sum_exprs;

    fn concat_list;
    fn concat_str;

    fn fold;
    fn reduce;

    //fn r_date_range;
    fn r_date_range_lazy;
    fn as_struct;
    fn struct_;
    //fn field_to_rust2;
    //fn series_from_arrow;
    //fn rb_to_df;
    fn rb_list_to_df;

    fn dtype_str_repr;

    // arrow conversions
    fn new_arrow_stream;
    fn arrow_stream_to_df;
    fn arrow_stream_to_series;
    fn export_df_to_arrow_stream;

    //robj meta
    fn mem_address;
    fn clone_robj;

    //for testing
    fn test_robj_to_usize;
    fn test_robj_to_f64;
    fn test_robj_to_i64;
    fn test_robj_to_u32;
    fn test_robj_to_i32;
    fn test_print_string;
    fn test_robj_to_expr;
    fn test_wrong_call_pl_lit;

    //feature flags
    fn polars_features;
}
