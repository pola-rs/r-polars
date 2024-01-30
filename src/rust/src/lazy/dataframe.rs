use crate::concurrent::{
    collect_with_r_func_support, fetch_with_r_func_support, profile_with_r_func_support,
};
use crate::conversion::strings_to_smartstrings;

use crate::lazy::dsl::RPolarsExpr;
use crate::lazy::dsl::*;

use crate::rdataframe::RPolarsDataFrame as RDF;
use crate::rdatatype::{new_ipc_compression, new_parquet_compression, RPolarsDataType};
use crate::robj_to;
use crate::rpolarserr::{polars_to_rpolars_err, RPolarsErr, RResult, WithRctx};
use crate::utils::{r_result_list, try_f64_into_usize};
use extendr_api::prelude::*;
use pl::{AsOfOptions, Duration, RollingGroupOptions};
use polars::frame::explode::MeltArgs;
use polars::prelude as pl;

use polars::io::csv::SerializeOptions;
use polars_lazy::prelude::CsvWriterOptions;

#[allow(unused_imports)]
use std::result::Result;

#[derive(Clone)]
pub struct RPolarsLazyFrame(pub pl::LazyFrame);

impl std::fmt::Debug for RPolarsLazyFrame {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "LazyFrame:")
    }
}

impl From<pl::LazyFrame> for RPolarsLazyFrame {
    fn from(item: pl::LazyFrame) -> Self {
        RPolarsLazyFrame(item)
    }
}

#[extendr]
impl RPolarsLazyFrame {
    fn print(&self) -> Self {
        rprintln!("{}", self.0.describe_plan());
        self.clone()
    }

    pub fn describe_plan(&self) {
        rprintln!("{}", self.0.describe_plan());
    }

    //low level version of describe_plan, mainly for arg testing
    pub fn debug_plan(&self) -> Result<String, String> {
        use polars_core::export::serde::Serialize;
        use serde_json::value::Serializer;
        Serialize::serialize(&self.0.logical_plan.clone(), Serializer)
            .map_err(|err| err.to_string())
            .map(|val| format!("{:?}", val))
    }

    pub fn describe_optimized_plan(&self) -> List {
        let result = self.0.describe_optimized_plan().map(|opt_plan| {
            rprintln!("{}", opt_plan);
        });
        r_result_list(result.map_err(|err| format!("{:?}", err)))
    }

    pub fn collect(&self) -> RResult<RDF> {
        collect_with_r_func_support(self.clone().0)
    }

    pub fn collect_in_background(&self) -> crate::rbackground::RPolarsRThreadHandle<RResult<RDF>> {
        use crate::rbackground::*;
        let dup = self.clone();
        RPolarsRThreadHandle::new(move || {
            Ok(RDF::from(
                dup.0
                    .collect()
                    .map_err(crate::rpolarserr::polars_to_rpolars_err)?,
            ))
        })
    }

    #[allow(clippy::too_many_arguments)]
    pub fn sink_parquet(
        &self,
        path: Robj,
        compression_method: Robj,
        compression_level: Robj,
        statistics: Robj,
        row_group_size: Robj,
        data_pagesize_limit: Robj,
        maintain_order: Robj,
    ) -> RResult<()> {
        let pqwo = polars::prelude::ParquetWriteOptions {
            compression: new_parquet_compression(compression_method, compression_level)?,
            statistics: robj_to!(bool, statistics)?,
            row_group_size: robj_to!(Option, usize, row_group_size)?,
            data_pagesize_limit: robj_to!(Option, usize, data_pagesize_limit)?,
            maintain_order: robj_to!(bool, maintain_order)?,
        };
        self.0
            .clone()
            .sink_parquet(robj_to!(String, path)?.into(), pqwo)
            .map_err(polars_to_rpolars_err)
    }

    fn sink_ipc(&self, path: Robj, compression_method: Robj, maintain_order: Robj) -> RResult<()> {
        let ipcwo = polars::prelude::IpcWriterOptions {
            compression: new_ipc_compression(compression_method)?,
            maintain_order: robj_to!(bool, maintain_order)?,
        };
        self.0
            .clone()
            .sink_ipc(robj_to!(String, path)?.into(), ipcwo)
            .map_err(polars_to_rpolars_err)
    }

    #[allow(clippy::too_many_arguments)]
    fn sink_csv(
        &self,
        path: Robj,
        include_bom: Robj,
        include_header: Robj,
        separator: Robj,
        line_terminator: Robj,
        quote: Robj,
        batch_size: Robj,
        datetime_format: Robj,
        date_format: Robj,
        time_format: Robj,
        float_precision: Robj,
        null_value: Robj,
        quote_style: Robj,
        maintain_order: Robj,
    ) -> RResult<()> {
        // using robj_to!() directly in SerializeOptions doesn't work
        let date_format = robj_to!(Option, String, date_format)?;
        let time_format = robj_to!(Option, String, time_format)?;
        let datetime_format = robj_to!(Option, String, datetime_format)?;
        let float_precision = robj_to!(Option, usize, float_precision)?;
        let separator = robj_to!(Utf8Byte, separator)?;
        let quote = robj_to!(Utf8Byte, quote)?;
        let null_value = robj_to!(String, null_value)?;
        let line_terminator = robj_to!(String, line_terminator)?;
        let quote_style = robj_to!(QuoteStyle, quote_style)?;
        let include_header = robj_to!(bool, include_header)?;
        let include_bom = robj_to!(bool, include_bom)?;
        let maintain_order = robj_to!(bool, maintain_order)?;
        let batch_size = robj_to!(usize, batch_size)?;

        let serialize_options = SerializeOptions {
            date_format,
            time_format,
            datetime_format,
            float_precision,
            separator,
            quote_char: quote,
            null: null_value,
            line_terminator,
            quote_style,
        };

        let options = CsvWriterOptions {
            include_bom,
            include_header,
            batch_size,
            maintain_order,
            serialize_options,
        };

        self.0
            .clone()
            .sink_csv(robj_to!(String, path)?.into(), options)
            .map_err(polars_to_rpolars_err)
    }

    fn sink_json(&self, path: Robj, maintain_order: Robj) -> RResult<()> {
        let maintain_order = robj_to!(bool, maintain_order)?;
        let options = pl::JsonWriterOptions { maintain_order };
        self.0
            .clone()
            .sink_json(robj_to!(String, path)?.into(), options)
            .map_err(polars_to_rpolars_err)
    }

    fn first(&self) -> Self {
        self.0.clone().first().into()
    }

    fn last(&self) -> Self {
        self.0.clone().last().into()
    }

    fn max(&self) -> RResult<Self> {
        let ldf = self.0.clone();
        let out = ldf.max().map_err(polars_to_rpolars_err)?;
        Ok(out.into())
    }

    fn min(&self) -> RResult<Self> {
        let ldf = self.0.clone();
        let out = ldf.min().map_err(polars_to_rpolars_err)?;
        Ok(out.into())
    }

    fn mean(&self) -> RResult<Self> {
        let ldf = self.0.clone();
        let out = ldf.mean().map_err(polars_to_rpolars_err)?;
        Ok(out.into())
    }

    fn median(&self) -> RResult<Self> {
        let ldf = self.0.clone();
        let out = ldf.median().map_err(polars_to_rpolars_err)?;
        Ok(out.into())
    }

    fn sum(&self) -> RResult<Self> {
        let ldf = self.0.clone();
        let out = ldf.sum().map_err(polars_to_rpolars_err)?;
        Ok(out.into())
    }

    fn std(&self, ddof: Robj) -> RResult<Self> {
        let ldf = self.0.clone();
        let out = ldf
            .std(robj_to!(u8, ddof)?)
            .map_err(polars_to_rpolars_err)?;
        Ok(out.into())
    }

    fn var(&self, ddof: Robj) -> RResult<Self> {
        let ldf = self.0.clone();
        let out = ldf
            .var(robj_to!(u8, ddof)?)
            .map_err(polars_to_rpolars_err)?;
        Ok(out.into())
    }

    fn quantile(&self, quantile: Robj, interpolation: Robj) -> RResult<Self> {
        let ldf = self.0.clone();
        let out = ldf
            .quantile(
                robj_to!(PLExpr, quantile)?,
                robj_to!(new_quantile_interpolation_option, interpolation)?,
            )
            .map_err(polars_to_rpolars_err)?;
        Ok(out.into())
    }

    fn shift(&self, periods: Robj) -> Result<Self, String> {
        Ok(self.clone().0.shift(robj_to!(i64, periods)?).into())
    }

    fn shift_and_fill(&self, fill_value: Robj, periods: Robj) -> RResult<Self> {
        Ok(self
            .clone()
            .0
            .shift_and_fill(robj_to!(PLExpr, periods)?, robj_to!(PLExpr, fill_value)?)
            .into())
    }

    fn reverse(&self) -> Self {
        self.0.clone().reverse().into()
    }

    fn drop(&self, columns: Robj) -> Result<RPolarsLazyFrame, String> {
        Ok(self
            .0
            .clone()
            .drop_columns(robj_to!(Vec, String, columns)?)
            .into())
    }

    fn fill_nan(&self, fill_value: Robj) -> Result<Self, String> {
        Ok(self
            .0
            .clone()
            .fill_nan(robj_to!(Expr, fill_value)?.0)
            .into())
    }

    fn fill_null(&self, fill_value: Robj) -> Result<Self, String> {
        Ok(self
            .0
            .clone()
            .fill_null(robj_to!(Expr, fill_value)?.0)
            .into())
    }

    fn slice(&self, offset: Robj, length: Robj) -> Result<RPolarsLazyFrame, String> {
        Ok(RPolarsLazyFrame(self.0.clone().slice(
            robj_to!(i64, offset)?,
            robj_to!(Option, u32, length)?.unwrap_or(u32::MAX),
        )))
    }

    pub fn with_columns(&self, exprs: Robj) -> RResult<Self> {
        let exprs =
            robj_to!(VecPLExprColNamed, exprs).when("preparing expressions for $with_columns()")?;
        Ok(RPolarsLazyFrame(self.clone().0.with_columns(exprs)))
    }

    pub fn unnest(&self, names: Vec<String>) -> RResult<Self> {
        Ok(RPolarsLazyFrame(self.clone().0.unnest(names)))
    }

    pub fn select(&self, exprs: Robj) -> RResult<Self> {
        let exprs =
            robj_to!(VecPLExprColNamed, exprs).when("preparing expressions for $select()")?;
        Ok(RPolarsLazyFrame(self.clone().0.select(exprs)))
    }

    pub fn select_str_as_lit(&self, exprs: Robj) -> RResult<Self> {
        let exprs = robj_to!(VecPLExprNamed, exprs).when("preparing columns for DataFrame")?;
        Ok(RPolarsLazyFrame(self.clone().0.select(exprs)))
    }

    fn limit(&self, n: Robj) -> Result<Self, String> {
        Ok(self.0.clone().limit(robj_to!(u32, n)?).into())
    }

    fn tail(&self, n: Robj) -> Result<RPolarsLazyFrame, String> {
        Ok(RPolarsLazyFrame(self.0.clone().tail(robj_to!(u32, n)?)))
    }

    fn filter(&self, expr: &RPolarsExpr) -> RPolarsLazyFrame {
        let new_df = self.clone().0.filter(expr.0.clone());
        RPolarsLazyFrame(new_df)
    }

    fn drop_nulls(&self, subset: &RPolarsProtoExprArray) -> RPolarsLazyFrame {
        if subset.0.is_empty() {
            RPolarsLazyFrame(self.0.clone().drop_nulls(None))
        } else {
            let vec = pra_to_vec(subset, "select");
            RPolarsLazyFrame(self.0.clone().drop_nulls(Some(vec)))
        }
    }

    fn unique(&self, subset: Robj, keep: Robj, maintain_order: Robj) -> RResult<RPolarsLazyFrame> {
        let ke = robj_to!(UniqueKeepStrategy, keep)?;
        let maintain_order = robj_to!(bool, maintain_order)?;
        let subset = robj_to!(Option, Vec, String, subset)?;
        let lf = if maintain_order {
            self.0.clone().unique_stable(subset, ke)
        } else {
            self.0.clone().unique(subset, ke)
        };
        Ok(lf.into())
    }

    fn group_by(&self, exprs: Robj, maintain_order: Robj) -> RResult<RPolarsLazyGroupBy> {
        let expr_vec = robj_to!(VecPLExprCol, exprs)?;
        let maintain_order = robj_to!(Option, bool, maintain_order)?.unwrap_or(false);
        if maintain_order {
            Ok(RPolarsLazyGroupBy {
                lgb: self.0.clone().group_by_stable(expr_vec),
                opt_state: self.0.get_current_optimizations(),
            })
        } else {
            Ok(RPolarsLazyGroupBy {
                lgb: self.0.clone().group_by(expr_vec),
                opt_state: self.0.get_current_optimizations(),
            })
        }
    }

    fn with_row_count(&self, name: Robj, offset: Robj) -> RResult<Self> {
        Ok(self
            .0
            .clone()
            .with_row_count(
                robj_to!(String, name)?.as_str(),
                robj_to!(Option, u32, offset)?,
            )
            .into())
    }

    #[allow(clippy::too_many_arguments)]
    pub fn join_asof(
        &self,
        other: Robj,
        left_on: Robj,
        right_on: Robj,
        left_by: Robj,
        right_by: Robj,
        allow_parallel: Robj,
        force_parallel: Robj,
        suffix: Robj,
        strategy: Robj,
        tolerance: Robj,
        tolerance_str: Robj,
    ) -> RResult<Self> {
        let left_by = robj_to!(Option, Vec, String, left_by)?;
        let right_by = robj_to!(Option, Vec, String, right_by)?;

        // polars AnyValue<&str> is not self owned, therefore rust-polars
        // chose to handle tolerance_str isolated as a String. Only one, if any,
        // of tolerance and tolerance_str is ecpected to be Some<T> and not None.
        // R might lack types to express any AnyValue. Using Expr allows for casting
        // like tolerance = pl$lit(42)$cast(pl$UInt64).

        let tolerance = robj_to!(Option, Expr, tolerance)?
            //TODO expr_to_any_value should return RResult
            .map(|e| crate::rdatatype::expr_to_any_value(e.0))
            .transpose()
            .map_err(|err| RPolarsErr::new().plain(err))?;
        let tolerance_str = robj_to!(Option, String, tolerance_str)?;

        Ok(self
            .0
            .clone()
            .join_builder()
            .with(robj_to!(LazyFrame, other)?.0)
            .left_on([robj_to!(ExprCol, left_on)?.0])
            .right_on([robj_to!(ExprCol, right_on)?.0])
            .allow_parallel(robj_to!(bool, allow_parallel)?)
            .force_parallel(robj_to!(bool, force_parallel)?)
            .how(pl::JoinType::AsOf(AsOfOptions {
                strategy: robj_to!(AsOfStrategy, strategy)?,
                left_by: left_by.map(|opt_vec_s| opt_vec_s.into_iter().map(|s| s.into()).collect()),
                right_by: right_by
                    .map(|opt_vec_s| opt_vec_s.into_iter().map(|s| s.into()).collect()),
                tolerance,
                tolerance_str: tolerance_str.map(|s| s.into()),
            }))
            .suffix(robj_to!(str, suffix)?)
            .finish()
            .into())
    }

    #[allow(clippy::too_many_arguments)]
    fn join(
        &self,
        other: Robj,
        left_on: Robj,
        right_on: Robj,
        how: Robj,
        validate: Robj,
        join_nulls: Robj,
        suffix: Robj,
        allow_parallel: Robj,
        force_parallel: Robj,
    ) -> RResult<RPolarsLazyFrame> {
        Ok(RPolarsLazyFrame(
            self.0
                .clone()
                .join_builder()
                .with(robj_to!(PLLazyFrame, other)?)
                .left_on(robj_to!(VecPLExprCol, left_on)?)
                .right_on(robj_to!(VecPLExprCol, right_on)?)
                .allow_parallel(robj_to!(bool, allow_parallel)?)
                .force_parallel(robj_to!(bool, force_parallel)?)
                .how(robj_to!(JoinType, how)?)
                .suffix(robj_to!(str, suffix)?)
                .join_nulls(robj_to!(bool, join_nulls)?)
                .validate(robj_to!(JoinValidation, validate)?)
                .finish(),
        ))
    }

    pub fn sort_by_exprs(
        &self,
        by: Robj,
        dotdotdot: Robj,
        descending: Robj,
        nulls_last: Robj,
        maintain_order: Robj,
    ) -> RResult<Self> {
        let mut exprs = robj_to!(VecPLExprCol, by)?;
        let mut ddd = robj_to!(VecPLExprCol, dotdotdot)?;
        exprs.append(&mut ddd);
        let descending = robj_to!(Vec, bool, descending)?;

        if descending.is_empty() {
            return Err(RPolarsErr::new()
                .plain("`descending` must be of length 1 or of the same length as `by`".into()));
        };

        let nulls_last = robj_to!(bool, nulls_last)?;
        let maintain_order = robj_to!(bool, maintain_order)?;
        Ok(self
            .0
            .clone()
            .sort_by_exprs(exprs, descending, nulls_last, maintain_order)
            .into())
    }

    fn melt(
        &self,
        id_vars: Robj,
        value_vars: Robj,
        value_name: Robj,
        variable_name: Robj,
        streamable: Robj,
    ) -> Result<Self, String> {
        let args = MeltArgs {
            id_vars: strings_to_smartstrings(robj_to!(Vec, String, id_vars)?),
            value_vars: strings_to_smartstrings(robj_to!(Vec, String, value_vars)?),
            value_name: robj_to!(Option, String, value_name)?.map(|s| s.into()),
            variable_name: robj_to!(Option, String, variable_name)?.map(|s| s.into()),
            streamable: robj_to!(bool, streamable)?,
        };
        Ok(self.0.clone().melt(args).into())
    }

    fn rename(&self, existing: Robj, new: Robj) -> Result<RPolarsLazyFrame, String> {
        Ok(self
            .0
            .clone()
            .rename(
                robj_to!(Vec, String, existing)?,
                robj_to!(Vec, String, new)?,
            )
            .into())
    }

    fn schema(&self) -> RResult<Pairlist> {
        let schema = self
            .0
            .schema()
            .map_err(crate::rpolarserr::polars_to_rpolars_err)?;
        let pairs = schema.iter().collect::<Vec<_>>().into_iter();
        Ok(Pairlist::from_pairs(
            pairs.map(|(name, ty)| (name, RPolarsDataType(ty.clone()))),
        ))
    }

    fn fetch(&self, n_rows: Robj) -> RResult<RDF> {
        fetch_with_r_func_support(self.0.clone(), robj_to!(usize, n_rows)?)
    }

    #[allow(clippy::too_many_arguments)]
    fn set_optimization_toggle(
        &self,
        type_coercion: Robj,
        predicate_pushdown: Robj,
        projection_pushdown: Robj,
        simplify_expression: Robj,
        slice_pushdown: Robj,
        comm_subplan_elim: Robj,
        comm_subexpr_elim: Robj,
        streaming: Robj,
        // fast_projection: Robj, // There is no method like with_fast_projection
        eager: Robj,
    ) -> RResult<Self> {
        let ldf = self
            .0
            .clone()
            .with_type_coercion(robj_to!(bool, type_coercion)?)
            .with_predicate_pushdown(robj_to!(bool, predicate_pushdown)?)
            .with_simplify_expr(robj_to!(bool, simplify_expression)?)
            .with_slice_pushdown(robj_to!(bool, slice_pushdown)?)
            .with_streaming(robj_to!(bool, streaming)?)
            ._with_eager(robj_to!(bool, eager)?)
            .with_projection_pushdown(robj_to!(bool, projection_pushdown)?)
            .with_comm_subplan_elim(robj_to!(bool, comm_subplan_elim)?)
            .with_comm_subexpr_elim(robj_to!(bool, comm_subexpr_elim)?);

        Ok(ldf.into())
    }

    fn get_optimization_toggle(&self) -> List {
        let pl::OptState {
            projection_pushdown,
            predicate_pushdown,
            type_coercion,
            simplify_expr,
            slice_pushdown,
            file_caching: _,
            comm_subplan_elim,
            comm_subexpr_elim,
            streaming,
            fast_projection: _,
            eager,
        } = self.0.get_current_optimizations();
        list!(
            type_coercion = type_coercion,
            predicate_pushdown = predicate_pushdown,
            projection_pushdown = projection_pushdown,
            simplify_expression = simplify_expr,
            slice_pushdown = slice_pushdown,
            comm_subplan_elim = comm_subplan_elim,
            comm_subexpr_elim = comm_subexpr_elim,
            streaming = streaming,
            eager = eager,
        )
    }

    fn profile(&self) -> RResult<List> {
        profile_with_r_func_support(self.0.clone()).map(|(r, p)| list!(result = r, profile = p))
    }

    fn explode(&self, dotdotdot: Robj) -> RResult<RPolarsLazyFrame> {
        Ok(self
            .0
            .clone()
            .explode(robj_to!(VecPLExprColNamed, dotdotdot)?)
            .into())
    }

    pub fn clone_in_rust(&self) -> RPolarsLazyFrame {
        self.clone()
    }

    pub fn with_context(&self, contexts: Robj) -> RResult<Self> {
        let contexts = robj_to!(Vec, LazyFrame, contexts)?
            .into_iter()
            .map(|ldf| ldf.0)
            .collect::<Vec<_>>();
        Ok(self.0.clone().with_context(contexts).into())
    }

    pub fn rolling(
        &self,
        index_column: Robj,
        period: Robj,
        offset: Robj,
        closed: Robj,
        by: Robj,
        check_sorted: Robj,
    ) -> RResult<RPolarsLazyGroupBy> {
        let index_column = robj_to!(PLExprCol, index_column)?;
        let period = Duration::parse(robj_to!(str, period)?);
        let offset = Duration::parse(robj_to!(str, offset)?);
        let closed_window = robj_to!(ClosedWindow, closed)?;
        let by = robj_to!(VecPLExprCol, by)?;
        let check_sorted = robj_to!(bool, check_sorted)?;

        let lazy_gb = self.0.clone().group_by_rolling(
            index_column,
            by,
            RollingGroupOptions {
                index_column: "".into(),
                period,
                offset,
                closed_window,
                check_sorted,
            },
        );

        Ok(RPolarsLazyGroupBy {
            lgb: lazy_gb,
            opt_state: self.0.get_current_optimizations(),
        })
    }

    #[allow(clippy::too_many_arguments)]
    pub fn group_by_dynamic(
        &self,
        index_column: Robj,
        every: Robj,
        period: Robj,
        offset: Robj,
        label: Robj,
        include_boundaries: Robj,
        closed: Robj,
        by: Robj,
        start_by: Robj,
        check_sorted: Robj,
    ) -> RResult<RPolarsLazyGroupBy> {
        let closed_window = robj_to!(ClosedWindow, closed)?;
        let by = robj_to!(VecPLExprCol, by)?;
        let ldf = self.0.clone();
        let lazy_gb = ldf.group_by_dynamic(
            robj_to!(PLExprCol, index_column)?,
            by,
            pl::DynamicGroupOptions {
                every: robj_to!(pl_duration, every)?,
                period: robj_to!(pl_duration, period)?,
                offset: robj_to!(pl_duration, offset)?,
                label: robj_to!(Label, label)?,
                include_boundaries: robj_to!(bool, include_boundaries)?,
                closed_window,
                start_by: robj_to!(StartBy, start_by)?,
                check_sorted: robj_to!(bool, check_sorted)?,
                ..Default::default()
            },
        );

        Ok(RPolarsLazyGroupBy {
            lgb: lazy_gb,
            opt_state: self.0.get_current_optimizations(),
        })
    }
}

#[derive(Clone)]
pub struct RPolarsLazyGroupBy {
    pub lgb: pl::LazyGroupBy,
    opt_state: pl::OptState,
}

#[extendr]
impl RPolarsLazyGroupBy {
    fn print(&self) {
        rprintln!("LazyGroupBy (internals are opaque)");
    }

    fn clone_in_rust(&self) -> Self {
        self.clone()
    }

    fn ungroup(&self) -> RPolarsLazyFrame {
        RPolarsLazyFrame(
            pl::LazyFrame::from(self.lgb.logical_plan.clone()).with_optimizations(self.opt_state),
        )
    }

    fn agg(&self, exprs: Robj) -> Result<RPolarsLazyFrame, String> {
        Ok(RPolarsLazyFrame(
            self.lgb.clone().agg(robj_to!(VecPLExprColNamed, exprs)?),
        ))
    }

    fn head(&self, n: f64) -> List {
        r_result_list(
            try_f64_into_usize(n)
                .map(|n| RPolarsLazyFrame(self.lgb.clone().head(Some(n))))
                .map_err(|err| format!("head: {}", err)),
        )
    }

    fn tail(&self, n: f64) -> List {
        r_result_list(
            try_f64_into_usize(n)
                .map(|n| RPolarsLazyFrame(self.lgb.clone().tail(Some(n))))
                .map_err(|err| format!("tail: {}", err)),
        )
    }
}

extendr_module! {
    mod dataframe;
    impl RPolarsLazyFrame;
    impl RPolarsLazyGroupBy;
}
