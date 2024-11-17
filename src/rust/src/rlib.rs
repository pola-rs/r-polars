use crate::lazy::dsl::RPolarsExpr;
use crate::robj_to;
use crate::utils::extendr_concurrent::{ParRObj, ThreadCom};
use crate::utils::robj_to_rchoice;
use crate::RFnSignature;
use crate::CONFIG;
use extendr_api::prelude::*;
use polars::chunked_array::ops::SortMultipleOptions;
use polars::lazy::dsl;
use polars::prelude as pl;
use polars::prelude::IntoColumn;
use std::result::Result;

#[extendr]
fn min_horizontal(dotdotdot: Robj) -> RResult<RPolarsExpr> {
    Ok(dsl::min_horizontal(robj_to!(VecPLExprCol, dotdotdot)?)
        .map_err(polars_to_rpolars_err)?
        .into())
}

#[extendr]
fn max_horizontal(dotdotdot: Robj) -> RResult<RPolarsExpr> {
    Ok(dsl::max_horizontal(robj_to!(VecPLExprCol, dotdotdot)?)
        .map_err(polars_to_rpolars_err)?
        .into())
}

#[extendr]
fn sum_horizontal(dotdotdot: Robj) -> RResult<RPolarsExpr> {
    Ok(dsl::sum_horizontal(robj_to!(VecPLExprCol, dotdotdot)?)
        .map_err(polars_to_rpolars_err)?
        .into())
}

#[extendr]
fn mean_horizontal(dotdotdot: Robj) -> RResult<RPolarsExpr> {
    Ok(dsl::mean_horizontal(robj_to!(VecPLExprCol, dotdotdot)?)
        .map_err(polars_to_rpolars_err)?
        .into())
}

#[extendr]
fn all_horizontal(dotdotdot: Robj) -> RResult<RPolarsExpr> {
    Ok(dsl::all_horizontal(robj_to!(VecPLExprCol, dotdotdot)?)
        .map_err(polars_to_rpolars_err)?
        .into())
}

#[extendr]
fn any_horizontal(dotdotdot: Robj) -> RResult<RPolarsExpr> {
    Ok(dsl::any_horizontal(robj_to!(VecPLExprCol, dotdotdot)?)
        .map_err(polars_to_rpolars_err)?
        .into())
}

#[extendr]
fn coalesce_exprs(exprs: Robj) -> RResult<RPolarsExpr> {
    Ok(pl::coalesce(&robj_to!(VecPLExprCol, exprs)?).into())
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
fn date_range(start: Robj, end: Robj, interval: &str, closed: Robj) -> RResult<RPolarsExpr> {
    Ok(RPolarsExpr(dsl::date_range(
        robj_to!(PLExprCol, start)?,
        robj_to!(PLExprCol, end)?,
        pl::Duration::parse(interval),
        robj_to!(ClosedWindow, closed)?,
    )))
}

#[extendr]
fn date_ranges(start: Robj, end: Robj, interval: &str, closed: Robj) -> RResult<RPolarsExpr> {
    Ok(RPolarsExpr(dsl::date_ranges(
        robj_to!(PLExprCol, start)?,
        robj_to!(PLExprCol, end)?,
        pl::Duration::parse(interval),
        robj_to!(ClosedWindow, closed)?,
    )))
}

#[extendr]
fn datetime_range(
    start: Robj,
    end: Robj,
    interval: &str,
    closed: Robj,
    time_unit: Robj,
    time_zone: Robj,
) -> RResult<RPolarsExpr> {
    Ok(RPolarsExpr(dsl::datetime_range(
        robj_to!(PLExprCol, start)?,
        robj_to!(PLExprCol, end)?,
        pl::Duration::parse(interval),
        robj_to!(ClosedWindow, closed)?,
        robj_to!(Option, timeunit, time_unit)?,
        robj_to!(Option, String, time_zone)?.map(|x| x.into()),
    )))
}

#[extendr]
fn datetime_ranges(
    start: Robj,
    end: Robj,
    interval: &str,
    closed: Robj,
    time_unit: Robj,
    time_zone: Robj,
) -> RResult<RPolarsExpr> {
    Ok(RPolarsExpr(dsl::datetime_ranges(
        robj_to!(PLExprCol, start)?,
        robj_to!(PLExprCol, end)?,
        pl::Duration::parse(interval),
        robj_to!(ClosedWindow, closed)?,
        robj_to!(Option, timeunit, time_unit)?,
        robj_to!(Option, String, time_zone)?.map(|x| x.into()),
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

use crate::rpolarserr::*;

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
    let f = move |acc: pl::Column, x: pl::Column| {
        let thread_com = ThreadCom::try_from_global(&CONFIG)
            .map_err(|err| pl::polars_err!(ComputeError: err))?;
        thread_com.send(RFnSignature::FnTwoSeriesToSeries(
            par_fn.clone(),
            acc.as_materialized_series().clone(),
            x.as_materialized_series().clone(),
        ));
        let s = thread_com.recv().unwrap_series();
        Ok(Some(s.into_column()))
    };
    Ok(pl::fold_exprs(robj_to!(PLExpr, acc)?, f, robj_to!(Vec, PLExpr, exprs)?).into())
}

#[extendr]
fn reduce(lambda: Robj, exprs: Robj) -> RResult<RPolarsExpr> {
    let par_fn = ParRObj(lambda);
    let f = move |acc: pl::Column, x: pl::Column| {
        let thread_com = ThreadCom::try_from_global(&CONFIG)
            .map_err(|err| pl::polars_err!(ComputeError: err))?;
        thread_com.send(RFnSignature::FnTwoSeriesToSeries(
            par_fn.clone(),
            acc.take_materialized_series(),
            x.take_materialized_series(),
        ));
        let s = thread_com.recv().unwrap_series();
        Ok(Some(s.into_column()))
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
        weeks: robj_to!(Option, PLExprCol, weeks)?.unwrap_or(dsl::lit(0)),
        days: robj_to!(Option, PLExprCol, days)?.unwrap_or(dsl::lit(0)),
        hours: robj_to!(Option, PLExprCol, hours)?.unwrap_or(dsl::lit(0)),
        minutes: robj_to!(Option, PLExprCol, minutes)?.unwrap_or(dsl::lit(0)),
        seconds: robj_to!(Option, PLExprCol, seconds)?.unwrap_or(dsl::lit(0)),
        milliseconds: robj_to!(Option, PLExprCol, milliseconds)?.unwrap_or(dsl::lit(0)),
        microseconds: robj_to!(Option, PLExprCol, microseconds)?.unwrap_or(dsl::lit(0)),
        nanoseconds: robj_to!(Option, PLExprCol, nanoseconds)?.unwrap_or(dsl::lit(0)),
        time_unit: robj_to!(timeunit, time_unit)?,
    };
    Ok(dsl::duration(args).into())
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
        hour: robj_to!(Option, PLExprCol, hour)?.unwrap_or(dsl::lit(0)),
        minute: robj_to!(Option, PLExprCol, minute)?.unwrap_or(dsl::lit(0)),
        second: robj_to!(Option, PLExprCol, second)?.unwrap_or(dsl::lit(0)),
        microsecond: robj_to!(Option, PLExprCol, microsecond)?.unwrap_or(dsl::lit(0)),
        time_unit: robj_to!(timeunit, time_unit)?,
        time_zone: robj_to!(Option, String, time_zone)?.map(|x| x.into()),
        ambiguous: robj_to!(PLExpr, ambiguous)?,
    };
    Ok(dsl::datetime(args).into())
}

#[extendr]
fn arg_where(condition: Robj) -> RResult<RPolarsExpr> {
    Ok(pl::arg_where(robj_to!(PLExpr, condition)?).into())
}

#[extendr]
fn arg_sort_by(
    exprs: Robj,
    descending: Robj,
    nulls_last: Robj,
    multithreaded: Robj,
    maintain_order: Robj,
) -> RResult<RPolarsExpr> {
    let descending = robj_to!(Vec, bool, descending)?;
    let nulls_last = robj_to!(Vec, bool, nulls_last)?;
    let multithreaded = robj_to!(bool, multithreaded)?;
    let maintain_order = robj_to!(bool, maintain_order)?;
    Ok(pl::arg_sort_by(
        robj_to!(VecPLExprCol, exprs)?,
        SortMultipleOptions {
            descending,
            nulls_last,
            multithreaded,
            maintain_order,
        },
    )
    .into())
}

#[extendr]
pub fn int_range(start: Robj, end: Robj, step: i64, dtype: Robj) -> RResult<RPolarsExpr> {
    let start = robj_to!(PLExprCol, start)?;
    let end = robj_to!(PLExprCol, end)?;
    // let step = robj_to!(PLExprCol, step)?;
    let dtype = robj_to!(RPolarsDataType, dtype)?.into();
    Ok(dsl::int_range(start, end, step, dtype).into())
}

#[extendr]
pub fn int_ranges(start: Robj, end: Robj, step: Robj, dtype: Robj) -> RResult<RPolarsExpr> {
    let start = robj_to!(PLExprCol, start)?;
    let end = robj_to!(PLExprCol, end)?;
    let step = robj_to!(PLExprCol, step)?;
    let dtype: pl::DataType = robj_to!(RPolarsDataType, dtype)?.into();
    if !dtype.is_integer() {
        return Err(pl::PolarsError::ComputeError(
            format!("non-integer `dtype` passed to `int_ranges`: {:?}", dtype,).into(),
        )
        .into());
    }
    let mut result = dsl::int_ranges(start, end, step);
    if dtype != pl::DataType::Int64 {
        result = result.cast(pl::DataType::List(Box::new(dtype)))
    }

    Ok(result.into())
}

#[extendr]
pub fn field(names: Robj) -> RResult<RPolarsExpr> {
    let names = robj_to!(Vec, String, names)?;
    Ok(pl::Expr::Field(names.into_iter().map(|name| name.into()).collect()).into())
}

extendr_module! {
    mod rlib;

    fn all_horizontal;
    fn any_horizontal;
    fn arg_sort_by;
    fn arg_where;
    fn coalesce_exprs;
    fn datetime;
    fn duration;
    fn int_range;
    fn int_ranges;
    fn min_horizontal;
    fn max_horizontal;
    fn sum_horizontal;
    fn mean_horizontal;

    fn field;

    fn concat_list;
    fn concat_str;

    fn fold;
    fn reduce;

    fn date_range;
    fn date_ranges;
    fn datetime_range;
    fn datetime_ranges;
    fn as_struct;
    fn struct_;

    fn dtype_str_repr;

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
