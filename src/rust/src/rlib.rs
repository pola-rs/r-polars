use crate::lazy::dsl::{RPolarsExpr, RPolarsProtoExprArray};
use crate::rdataframe::RPolarsDataFrame;
use crate::robj_to;
use crate::series::RPolarsSeries;
use crate::utils::extendr_concurrent::{ParRObj, ThreadCom};
use crate::utils::robj_to_rchoice;
use crate::RFnSignature;
use crate::CONFIG;
use extendr_api::prelude::*;
use polars::prelude as pl;
use std::result::Result;

#[extendr]
fn min_horizontal(dotdotdot: Robj) -> RResult<RPolarsExpr> {
    Ok(
        polars::lazy::dsl::min_horizontal(robj_to!(VecPLExprCol, dotdotdot)?)
            .map_err(polars_to_rpolars_err)?
            .into(),
    )
}

#[extendr]
fn max_horizontal(dotdotdot: Robj) -> RResult<RPolarsExpr> {
    Ok(
        polars::lazy::dsl::max_horizontal(robj_to!(VecPLExprCol, dotdotdot)?)
            .map_err(polars_to_rpolars_err)?
            .into(),
    )
}

#[extendr]
fn sum_horizontal(dotdotdot: Robj) -> RResult<RPolarsExpr> {
    Ok(
        polars::lazy::dsl::sum_horizontal(robj_to!(VecPLExprCol, dotdotdot)?)
            .map_err(polars_to_rpolars_err)?
            .into(),
    )
}

#[extendr]
fn all_horizontal(dotdotdot: Robj) -> RResult<RPolarsExpr> {
    Ok(
        polars::lazy::dsl::all_horizontal(robj_to!(VecPLExprCol, dotdotdot)?)
            .map_err(polars_to_rpolars_err)?
            .into(),
    )
}

#[extendr]
fn any_horizontal(dotdotdot: Robj) -> RResult<RPolarsExpr> {
    Ok(
        polars::lazy::dsl::any_horizontal(robj_to!(VecPLExprCol, dotdotdot)?)
            .map_err(polars_to_rpolars_err)?
            .into(),
    )
}

#[extendr]
fn coalesce_exprs(exprs: &RPolarsProtoExprArray) -> RPolarsExpr {
    let exprs: Vec<pl::Expr> = exprs.to_vec("select");
    pl::coalesce(exprs.as_slice()).into()
}

#[extendr]
fn concat_list(exprs: Robj) -> RResult<RPolarsExpr> {
    pl::concat_list(robj_to!(VecPLExprCol, exprs)?)
        .map_err(polars_to_rpolars_err)
        .map(RPolarsExpr)
}

#[extendr]
fn concat_str(dotdotdot: Robj, separator: Robj, ignore_nulls: Robj) -> RResult<RPolarsExpr> {
    Ok(pl::concat_str(
        robj_to!(VecPLExprCol, dotdotdot)?,
        robj_to!(str, separator)?,
        robj_to!(bool, ignore_nulls)?,
    )
    .into())
}

#[extendr]
fn date_range(
    start: Robj,
    end: Robj,
    interval: Robj,
    closed: Robj,
    time_unit: Robj,
    time_zone: Robj,
) -> RResult<RPolarsExpr> {
    Ok(RPolarsExpr(polars::lazy::prelude::date_range(
        robj_to!(PLExprCol, start)?,
        robj_to!(PLExprCol, end)?,
        robj_to!(pl_duration, interval)?,
        robj_to!(ClosedWindow, closed)?,
        robj_to!(Option, timeunit, time_unit)?,
        robj_to!(Option, String, time_zone)?,
    )))
}

#[extendr]
fn as_struct(exprs: Robj) -> RResult<RPolarsExpr> {
    Ok(pl::as_struct(robj_to!(VecPLExprNamed, exprs)?).into())
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
        Ok(crate::rdataframe::RPolarsDataFrame(df).into())
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
    Ok(RPolarsDataFrame(df).into_robj())
}

#[extendr]
fn arrow_stream_to_series(robj_str: Robj) -> RResult<Robj> {
    let s = crate::arrow_interop::to_rust::arrow_stream_to_series_internal(robj_str)?;
    Ok(RPolarsSeries(s).into_robj())
}

#[extendr]
unsafe fn export_df_to_arrow_stream(robj_df: Robj, robj_str: Robj) -> RResult<Robj> {
    let res: ExternalPtr<RPolarsDataFrame> = robj_df.try_into()?;
    let pl_df = RPolarsDataFrame(res.0.clone()).0;
    //safety robj_str must be ptr to a arrow2 stream ready to export into
    unsafe {
        crate::arrow_interop::to_rust::export_df_as_stream(pl_df, &robj_str)?;
    }
    Ok(robj_str)
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
fn test_robj_to_expr(robj: Robj) -> RResult<RPolarsExpr> {
    robj_to!(Expr, robj)
}

#[extendr]
fn test_wrong_call_pl_lit(robj: Robj) -> RResult<Robj> {
    Ok(R!("pl$lit({{robj}})")?) // this call should have been polars::pl$lit(...
}

#[extendr]
fn test_robj_to_rchoice(robj: Robj) -> RResult<String> {
    // robj can be any non-zero length char vec, will return first string.
    robj_to_rchoice(robj)
}

#[extendr]
fn fold(acc: Robj, lambda: Robj, exprs: Robj) -> RResult<RPolarsExpr> {
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
fn reduce(lambda: Robj, exprs: Robj) -> RResult<RPolarsExpr> {
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

#[extendr]
#[allow(clippy::too_many_arguments)]
pub fn duration(
    weeks: Robj,
    days: Robj,
    hours: Robj,
    minutes: Robj,
    seconds: Robj,
    milliseconds: Robj,
    microseconds: Robj,
    nanoseconds: Robj,
    time_unit: Robj,
) -> RResult<RPolarsExpr> {
    let args = pl::DurationArgs {
        weeks: robj_to!(Option, PLExprCol, weeks)?.unwrap_or(polars::lazy::dsl::lit(0)),
        days: robj_to!(Option, PLExprCol, days)?.unwrap_or(polars::lazy::dsl::lit(0)),
        hours: robj_to!(Option, PLExprCol, hours)?.unwrap_or(polars::lazy::dsl::lit(0)),
        minutes: robj_to!(Option, PLExprCol, minutes)?.unwrap_or(polars::lazy::dsl::lit(0)),
        seconds: robj_to!(Option, PLExprCol, seconds)?.unwrap_or(polars::lazy::dsl::lit(0)),
        milliseconds: robj_to!(Option, PLExprCol, milliseconds)?
            .unwrap_or(polars::lazy::dsl::lit(0)),
        microseconds: robj_to!(Option, PLExprCol, microseconds)?
            .unwrap_or(polars::lazy::dsl::lit(0)),
        nanoseconds: robj_to!(Option, PLExprCol, nanoseconds)?.unwrap_or(polars::lazy::dsl::lit(0)),
        time_unit: robj_to!(timeunit, time_unit)?,
    };
    Ok(polars::lazy::dsl::duration(args).into())
}

#[extendr]
#[allow(clippy::too_many_arguments)]
pub fn datetime(
    year: Robj,
    month: Robj,
    day: Robj,
    hour: Robj,
    minute: Robj,
    second: Robj,
    microsecond: Robj,
    time_unit: Robj,
    time_zone: Robj,
    ambiguous: Robj,
) -> RResult<RPolarsExpr> {
    let args = pl::DatetimeArgs {
        year: robj_to!(PLExprCol, year)?,
        month: robj_to!(PLExprCol, month)?,
        day: robj_to!(PLExprCol, day)?,
        hour: robj_to!(Option, PLExprCol, hour)?.unwrap_or(polars::lazy::dsl::lit(0)),
        minute: robj_to!(Option, PLExprCol, minute)?.unwrap_or(polars::lazy::dsl::lit(0)),
        second: robj_to!(Option, PLExprCol, second)?.unwrap_or(polars::lazy::dsl::lit(0)),
        microsecond: robj_to!(Option, PLExprCol, microsecond)?.unwrap_or(polars::lazy::dsl::lit(0)),
        time_unit: robj_to!(timeunit, time_unit)?,
        time_zone: robj_to!(Option, String, time_zone)?,
        ambiguous: robj_to!(PLExpr, ambiguous)?,
    };
    Ok(polars::lazy::dsl::datetime(args).into())
}

#[extendr]
fn arg_where(condition: Robj) -> RResult<RPolarsExpr> {
    Ok(pl::arg_where(robj_to!(PLExpr, condition)?).into())
}

extendr_module! {
    mod rlib;

    fn all_horizontal;
    fn any_horizontal;
    fn arg_where;
    fn coalesce_exprs;
    fn datetime;
    fn duration;
    fn min_horizontal;
    fn max_horizontal;
    fn sum_horizontal;

    fn concat_list;
    fn concat_str;

    fn fold;
    fn reduce;

    //fn r_date_range;
    fn date_range;
    fn as_struct;
    fn struct_;

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
    fn test_robj_to_rchoice;
}
