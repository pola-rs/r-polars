use crate::{PlRDataFrame, PlRDataType, PlRExpr, PlRLazyFrame, PlRSeries, RPolarsErr, prelude::*};
use polars::functions;
use polars::lazy::dsl;
use savvy::{ListSexp, LogicalSexp, NumericSexp, RawSexp, Result, StringSexp, savvy};

macro_rules! set_unwrapped_or_0 {
    ($($var:ident),+ $(,)?) => {
        $(let $var = $var.map(|e| e.inner.clone()).unwrap_or(dsl::lit(0));)+
    };
}

#[savvy]
pub fn as_struct(exprs: ListSexp) -> Result<PlRExpr> {
    let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
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
    let time_zone = time_zone.map(|x| x.into());
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
    let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
    Ok(dsl::coalesce(&exprs).into())
}

#[savvy]
pub fn col(name: &str) -> Result<PlRExpr> {
    Ok(dsl::col(name).into())
}

#[savvy]
pub fn cols(names: StringSexp) -> Result<PlRExpr> {
    let names = names.iter().collect::<Vec<_>>();
    Ok(dsl::cols(names).into())
}

#[savvy]
pub fn dtype_cols(dtypes: ListSexp) -> Result<PlRExpr> {
    let dtypes = <Wrap<Vec<DataType>>>::try_from(dtypes)?.0;
    Ok(dsl::dtype_cols(&dtypes).into())
}

#[savvy]
pub fn index_cols(indices: NumericSexp) -> Result<PlRExpr> {
    let n = <Wrap<Vec<i64>>>::try_from(indices)?.0;
    let out = if n.len() == 1 {
        dsl::nth(n[0])
    } else {
        dsl::index_cols(n)
    }
    .into();
    Ok(out)
}

#[savvy]
pub fn first() -> Result<PlRExpr> {
    Ok(dsl::first().into())
}

#[savvy]
pub fn last() -> Result<PlRExpr> {
    Ok(dsl::last().into())
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
pub fn lit_from_series(value: &PlRSeries) -> Result<PlRExpr> {
    Ok(dsl::lit(value.series.clone()).into())
}

#[savvy]
pub fn lit_from_series_first(value: &PlRSeries) -> Result<PlRExpr> {
    let s = value.series.clone();
    let av = s.get(0).map_err(RPolarsErr::from)?.into_static();
    Ok(dsl::lit(Scalar::new(s.dtype().clone(), av)).into())
}

#[savvy]
pub fn concat_list(s: ListSexp) -> Result<PlRExpr> {
    let s = <Wrap<Vec<Expr>>>::from(s).0;
    let expr = dsl::concat_list(s).map_err(RPolarsErr::from)?;
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
    let s = <Wrap<Vec<Expr>>>::from(s).0;
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
    let by = <Wrap<Vec<Expr>>>::from(by).0;
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
