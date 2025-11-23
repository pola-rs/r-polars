use crate::{
    PlRDataFrame, PlRDataType, PlRExpr, PlRLazyFrame, PlRSeries, RPolarsErr,
    lazyframe::PlROptFlags, prelude::*,
};
use polars::functions;
use polars::lazy::dsl;
use savvy::{ListSexp, LogicalSexp, OwnedListSexp, RawSexp, Result, Sexp, StringSexp, savvy};

macro_rules! set_unwrapped_or_0 {
    ($($var:ident),+ $(,)?) => {
        $(let $var = $var.map(|e| e.inner.clone()).unwrap_or(dsl::lit(0));)+
    };
}

#[savvy]
pub fn as_struct(exprs: ListSexp) -> Result<PlRExpr> {
    let exprs = <Wrap<Vec<Expr>>>::try_from(exprs).unwrap().0;
    if exprs.is_empty() {
        return Err(savvy::Error::from(
            "expected at least 1 expression in `as_struct`",
        ));
    }
    Ok(dsl::as_struct(exprs).into())
}

#[savvy]
pub fn datetime(
    year: &PlRExpr,
    month: &PlRExpr,
    day: &PlRExpr,
    time_unit: &str,
    ambiguous: &PlRExpr,
    hour: Option<&PlRExpr>,
    minute: Option<&PlRExpr>,
    second: Option<&PlRExpr>,
    microsecond: Option<&PlRExpr>,
    time_zone: Option<&str>,
) -> Result<PlRExpr> {
    let year = year.inner.clone();
    let month = month.inner.clone();
    let day = day.inner.clone();
    set_unwrapped_or_0!(hour, minute, second, microsecond);
    let ambiguous = ambiguous.inner.clone();
    let time_unit = <Wrap<TimeUnit>>::try_from(time_unit)?.0;
    let time_zone = <Wrap<Option<TimeZone>>>::try_from(time_zone)?.0;
    let args = DatetimeArgs {
        year,
        month,
        day,
        hour,
        minute,
        second,
        microsecond,
        time_unit,
        time_zone,
        ambiguous,
    };
    Ok(dsl::datetime(args).into())
}

#[savvy]
pub fn duration(
    time_unit: &str,
    weeks: Option<&PlRExpr>,
    days: Option<&PlRExpr>,
    hours: Option<&PlRExpr>,
    minutes: Option<&PlRExpr>,
    seconds: Option<&PlRExpr>,
    milliseconds: Option<&PlRExpr>,
    microseconds: Option<&PlRExpr>,
    nanoseconds: Option<&PlRExpr>,
) -> Result<PlRExpr> {
    set_unwrapped_or_0!(
        weeks,
        days,
        hours,
        minutes,
        seconds,
        milliseconds,
        microseconds,
        nanoseconds,
    );
    let time_unit = <Wrap<TimeUnit>>::try_from(time_unit)?.0;
    let args = DurationArgs {
        weeks,
        days,
        hours,
        minutes,
        seconds,
        milliseconds,
        microseconds,
        nanoseconds,
        time_unit,
    };
    Ok(dsl::duration(args).into())
}

#[savvy]
pub fn field(names: StringSexp) -> Result<PlRExpr> {
    Ok(dsl::Expr::Field(names.iter().map(|name| name.into()).collect()).into())
}

#[savvy]
pub fn coalesce(exprs: ListSexp) -> Result<PlRExpr> {
    let exprs = <Wrap<Vec<Expr>>>::try_from(exprs).unwrap().0;
    Ok(dsl::coalesce(&exprs).into())
}

#[savvy]
pub fn col(name: &str) -> Result<PlRExpr> {
    Ok(dsl::col(name).into())
}

#[savvy]
pub fn cols(names: StringSexp) -> Result<PlRExpr> {
    let names = names.iter().collect::<Vec<_>>();
    Ok(dsl::cols(names).as_expr().into())
}

#[savvy]
pub fn lit_bin_from_raw(value: RawSexp) -> Result<PlRExpr> {
    Ok(dsl::lit(value.as_slice()).into())
}

#[savvy]
pub fn lit_null() -> Result<PlRExpr> {
    Ok(dsl::lit(Null {}).into())
}

#[savvy]
pub fn lit_from_series(value: &PlRSeries, keep_series: bool, keep_name: bool) -> Result<PlRExpr> {
    let s = value.series.clone();
    if keep_series || s.len() != 1 {
        Ok(dsl::lit(s).into())
    } else {
        // Safety: only called on length 1 series
        let av = unsafe { s.get_unchecked(0).into_static() };
        let lit = dsl::lit(Scalar::new(s.dtype().clone(), av));
        if keep_name {
            Ok(lit.alias(&**s.name()).into())
        } else {
            Ok(lit.into())
        }
    }
}

#[savvy]
pub fn concat_list(s: ListSexp) -> Result<PlRExpr> {
    let s = <Wrap<Vec<Expr>>>::try_from(s).unwrap().0;
    let expr = dsl::concat_list(s).map_err(RPolarsErr::from)?;
    Ok(expr.into())
}

#[savvy]
pub fn concat_arr(s: ListSexp) -> Result<PlRExpr> {
    let s = <Wrap<Vec<Expr>>>::try_from(s).unwrap().0;
    let expr = dsl::concat_arr(s).map_err(RPolarsErr::from)?;
    Ok(expr.into())
}

#[savvy]
pub fn concat_df_diagonal(dfs: ListSexp) -> Result<PlRDataFrame> {
    let dfs = <Wrap<Vec<DataFrame>>>::try_from(dfs)?.0;

    let df = functions::concat_df_diagonal(&dfs).map_err(RPolarsErr::from)?;
    Ok(df.into())
}

#[savvy]
pub fn concat_df_horizontal(dfs: ListSexp) -> Result<PlRDataFrame> {
    let dfs = <Wrap<Vec<DataFrame>>>::try_from(dfs)?.0;

    let df = functions::concat_df_horizontal(&dfs, true).map_err(RPolarsErr::from)?;
    Ok(df.into())
}

#[savvy]
pub fn concat_lf(
    lfs: ListSexp,
    rechunk: bool,
    parallel: bool,
    to_supertypes: bool,
) -> Result<PlRLazyFrame> {
    let lfs = <Wrap<Vec<LazyFrame>>>::try_from(lfs)?.0;

    let lf = dsl::concat(
        lfs,
        UnionArgs {
            rechunk,
            parallel,
            to_supertypes,
            ..Default::default()
        },
    )
    .map_err(RPolarsErr::from)?;
    Ok(lf.into())
}

#[savvy]
pub fn concat_lf_horizontal(lfs: ListSexp, parallel: bool) -> Result<PlRLazyFrame> {
    let lfs = <Wrap<Vec<LazyFrame>>>::try_from(lfs)?.0;

    let args = UnionArgs {
        rechunk: false, // No need to rechunk with horizontal concatenation
        parallel,
        to_supertypes: false,
        ..Default::default()
    };
    let lf = dsl::functions::concat_lf_horizontal(lfs, args).map_err(RPolarsErr::from)?;
    Ok(lf.into())
}

#[savvy]
pub fn concat_lf_diagonal(
    lfs: ListSexp,
    rechunk: bool,
    parallel: bool,
    to_supertypes: bool,
) -> Result<PlRLazyFrame> {
    let lfs = <Wrap<Vec<LazyFrame>>>::try_from(lfs)?.0;

    let lf = dsl::functions::concat_lf_diagonal(
        lfs,
        UnionArgs {
            rechunk,
            parallel,
            to_supertypes,
            ..Default::default()
        },
    )
    .map_err(RPolarsErr::from)?;
    Ok(lf.into())
}

#[savvy]
pub fn concat_str(s: ListSexp, separator: &str, ignore_nulls: bool) -> Result<PlRExpr> {
    let s = <Wrap<Vec<Expr>>>::try_from(s).unwrap().0;
    Ok(dsl::concat_str(s, separator, ignore_nulls).into())
}

#[savvy]
pub fn arg_where(condition: &PlRExpr) -> Result<PlRExpr> {
    Ok(dsl::arg_where(condition.inner.clone()).into())
}

#[savvy]
pub fn arg_sort_by(
    by: ListSexp,
    descending: LogicalSexp,
    nulls_last: LogicalSexp,
    maintain_order: bool,
    multithreaded: bool,
) -> Result<PlRExpr> {
    let by = <Wrap<Vec<Expr>>>::try_from(by).unwrap().0;
    Ok(dsl::arg_sort_by(
        by,
        SortMultipleOptions {
            descending: descending.to_vec(),
            nulls_last: nulls_last.to_vec(),
            maintain_order,
            multithreaded,
            limit: None,
        },
    )
    .into())
}

#[savvy]
#[allow(non_snake_case)]
pub fn repeat_(value: &PlRExpr, n: &PlRExpr, dtype: Option<&PlRDataType>) -> Result<PlRExpr> {
    let mut value = value.inner.clone();
    let n = n.inner.clone();
    if let Some(dtype) = dtype {
        value = value.cast(dtype.dt.clone());
    }
    Ok(dsl::repeat(value, n).into())
}

#[savvy]
pub fn len() -> Result<PlRExpr> {
    Ok(dsl::len().into())
}

fn lfs_to_plans(lfs: Vec<LazyFrame>) -> Result<Vec<DslPlan>> {
    Ok(lfs.into_iter().map(|lf| lf.logical_plan).collect())
}

#[savvy]
pub fn collect_all(lfs: ListSexp, engine: &str, optimizations: Sexp) -> Result<Sexp> {
    let lfs = <Wrap<Vec<LazyFrame>>>::try_from(lfs)?.0;
    let engine = <Wrap<Engine>>::try_from(engine)?.0;
    let plans = lfs_to_plans(lfs)?;
    let optimizations = <PlROptFlags>::try_from(optimizations)?;
    let dfs = LazyFrame::collect_all_with_engine(plans, engine, optimizations.inner.into_inner())
        .map_err(RPolarsErr::from)?;

    let mut out = OwnedListSexp::new(dfs.len(), false)?;
    for (i, df) in dfs.iter().enumerate() {
        let _ = out.set_value(i, Sexp::try_from(PlRDataFrame::from(df.clone()))?);
    }
    Ok(out.into())
}

#[savvy]
pub fn explain_all(lfs: ListSexp, optimizations: Sexp) -> Result<Sexp> {
    let lfs = <Wrap<Vec<LazyFrame>>>::try_from(lfs)?.0;
    let optimizations = <PlROptFlags>::try_from(optimizations)?;
    let plans = lfs_to_plans(lfs)?;
    let explained = LazyFrame::explain_all(plans, optimizations.inner.into_inner())
        .map_err(RPolarsErr::from)?;
    explained.try_into()
}
