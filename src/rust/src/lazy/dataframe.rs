use crate::concurrent::{
    collect_with_r_func_support, fetch_with_r_func_support, profile_with_r_func_support,
};
use crate::lazy::dsl::*;

use crate::rdataframe::RPolarsDataFrame as RDF;
use crate::rdatatype::{new_ipc_compression, new_parquet_compression, RPolarsDataType};
use crate::robj_to;
use crate::rpolarserr::{polars_to_rpolars_err, RPolarsErr, RResult};
use crate::utils::try_f64_into_usize;
use extendr_api::prelude::*;
use pl::{AsOfOptions, Duration, RollingGroupOptions};
use polars::chunked_array::ops::SortMultipleOptions;
use polars::prelude::{self as pl};

use polars::prelude::{JoinCoalesce, SerializeOptions, UnpivotArgsDSL};
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
    fn print(&self) -> RResult<Self> {
        let plan = self.0.describe_plan().map_err(polars_to_rpolars_err)?;
        rprintln!("{}", plan);
        Ok(self.0.clone().into())
    }

    pub fn describe_plan(&self) -> RResult<String> {
        Ok(self.0.describe_plan().map_err(polars_to_rpolars_err)?)
    }

    fn describe_plan_tree(&self) -> RResult<String> {
        Ok(self.0.describe_plan_tree().map_err(polars_to_rpolars_err)?)
    }

    pub fn describe_optimized_plan(&self) -> RResult<String> {
        Ok(self
            .0
            .describe_optimized_plan()
            .map_err(polars_to_rpolars_err)?)
    }

    fn describe_optimized_plan_tree(&self) -> RResult<String> {
        Ok(self
            .0
            .describe_optimized_plan_tree()
            .map_err(polars_to_rpolars_err)?)
    }

    //low level version of describe_plan, mainly for arg testing
    pub fn debug_plan(&self) -> Result<String, String> {
        use polars_core::export::serde::Serialize;
        use serde_json::value::Serializer;
        Serialize::serialize(&self.0.logical_plan.clone(), Serializer)
            .map_err(|err| err.to_string())
            .map(|val| format!("{:?}", val))
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

    fn serialize(&self) -> RResult<String> {
        serde_json::to_string(&self.0.logical_plan)
            .map_err(|err| RPolarsErr::new().plain(format!("{err:?}")))
    }

    fn deserialize(json: Robj) -> RResult<Self> {
        let json = robj_to!(str, json)?;
        let lp = serde_json::from_str::<pl::DslPlan>(json)
            .map_err(|err| RPolarsErr::new().plain(format!("{err:?}")))?;
        Ok(RPolarsLazyFrame(pl::LazyFrame::from(lp)))
    }

    #[allow(clippy::too_many_arguments)]
    pub fn sink_parquet(
        &self,
        path: Robj,
        compression_method: Robj,
        compression_level: Robj,
        statistics: Robj,
        row_group_size: Robj,
        data_page_size: Robj,
        maintain_order: Robj,
    ) -> RResult<()> {
        let pqwo = polars::prelude::ParquetWriteOptions {
            compression: new_parquet_compression(compression_method, compression_level)?,
            statistics: robj_to!(StatisticsOptions, statistics)?,
            row_group_size: robj_to!(Option, usize, row_group_size)?,
            data_page_size: robj_to!(Option, usize, data_page_size)?,
            maintain_order: robj_to!(bool, maintain_order)?,
        };
        self.0
            .clone()
            .sink_parquet(&robj_to!(String, path)?, pqwo, None)
            .map_err(polars_to_rpolars_err)
    }

    fn sink_ipc(&self, path: Robj, compression: Robj, maintain_order: Robj) -> RResult<()> {
        let ipcwo = polars::prelude::IpcWriterOptions {
            compression: new_ipc_compression(compression)?,
            maintain_order: robj_to!(bool, maintain_order)?,
        };
        self.0
            .clone()
            .sink_ipc(robj_to!(String, path)?, ipcwo, None)
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
        quote_char: Robj,
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
        let quote_char = robj_to!(Utf8Byte, quote_char)?;
        let null_value = robj_to!(String, null_value)?;
        let line_terminator = robj_to!(String, line_terminator)?;
        let quote_style = robj_to!(QuoteStyle, quote_style)?;
        let include_header = robj_to!(bool, include_header)?;
        let include_bom = robj_to!(bool, include_bom)?;
        let maintain_order = robj_to!(bool, maintain_order)?;
        let batch_size = robj_to!(nonzero_usize, batch_size)?;

        let serialize_options = SerializeOptions {
            date_format,
            time_format,
            datetime_format,
            float_scientific: None,
            float_precision,
            separator,
            quote_char: quote_char,
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
            .sink_csv(robj_to!(String, path)?, options, None)
            .map_err(polars_to_rpolars_err)
    }

    fn sink_json(&self, path: Robj, maintain_order: Robj) -> RResult<()> {
        let maintain_order = robj_to!(bool, maintain_order)?;
        let options = pl::JsonWriterOptions { maintain_order };
        self.0
            .clone()
            .sink_json(robj_to!(String, path)?, options, None)
            .map_err(polars_to_rpolars_err)
    }

    fn first(&self) -> Self {
        self.0.clone().first().into()
    }

    fn last(&self) -> Self {
        self.0.clone().last().into()
    }

    fn max(&self) -> Self {
        self.0.clone().max().into()
    }

    fn min(&self) -> Self {
        self.0.clone().min().into()
    }

    fn mean(&self) -> Self {
        self.0.clone().mean().into()
    }

    fn median(&self) -> Self {
        self.0.clone().median().into()
    }

    fn sum(&self) -> Self {
        self.0.clone().sum().into()
    }

    fn std(&self, ddof: Robj) -> RResult<Self> {
        let ldf = self.0.clone();
        let out = ldf.std(robj_to!(u8, ddof)?);
        Ok(out.into())
    }

    fn var(&self, ddof: Robj) -> RResult<Self> {
        let ldf = self.0.clone();
        let out = ldf.var(robj_to!(u8, ddof)?);
        Ok(out.into())
    }

    fn quantile(&self, quantile: Robj, interpolation: Robj) -> RResult<Self> {
        let ldf = self.0.clone();
        let out = ldf.quantile(
            robj_to!(PLExpr, quantile)?,
            robj_to!(quantile_interpolation_option, interpolation)?,
        );
        Ok(out.into())
    }

    fn shift(&self, n: Robj, fill_value: Robj) -> RResult<Self> {
        let lf = self.0.clone();
        let n = robj_to!(PLExpr, n)?;
        let fill_value = robj_to!(Option, PLExpr, fill_value)?;
        let out = match fill_value {
            Some(v) => lf.shift_and_fill(n, v),
            None => lf.shift(n),
        };
        Ok(out.into())
    }

    fn reverse(&self) -> Self {
        self.0.clone().reverse().into()
    }

    fn drop(&self, columns: Vec<String>, strict: Robj) -> RResult<Self> {
        let strict = robj_to!(bool, strict)?;
        let out = if strict {
            self.0.clone().drop(columns)
        } else {
            self.0.clone().drop_no_validate(columns)
        };
        Ok(out.into())
    }

    fn fill_nan(&self, value: Robj) -> RResult<Self> {
        Ok(self.0.clone().fill_nan(robj_to!(PLExpr, value)?).into())
    }

    fn fill_null(&self, value: Robj) -> RResult<Self> {
        Ok(self.0.clone().fill_null(robj_to!(Expr, value)?.0).into())
    }

    fn slice(&self, offset: Robj, length: Robj) -> RResult<Self> {
        Ok(RPolarsLazyFrame(self.0.clone().slice(
            robj_to!(i64, offset)?,
            robj_to!(Option, u32, length)?.unwrap_or(u32::MAX),
        )))
    }

    pub fn with_columns(&self, exprs: Robj) -> RResult<Self> {
        let exprs = robj_to!(VecPLExprColNamed, exprs)?;
        Ok(RPolarsLazyFrame(self.clone().0.with_columns(exprs)))
    }

    pub fn with_columns_seq(&self, exprs: Robj) -> RResult<Self> {
        let exprs = robj_to!(VecPLExprColNamed, exprs)?;
        Ok(RPolarsLazyFrame(self.clone().0.with_columns_seq(exprs)))
    }

    pub fn unnest(&self, columns: Vec<String>) -> RResult<Self> {
        Ok(RPolarsLazyFrame(self.clone().0.unnest(columns)))
    }

    pub fn select(&self, exprs: Robj) -> RResult<Self> {
        let exprs = robj_to!(VecPLExprColNamed, exprs)?;
        Ok(RPolarsLazyFrame(self.clone().0.select(exprs)))
    }

    pub fn select_seq(&self, exprs: Robj) -> RResult<Self> {
        let exprs = robj_to!(VecPLExprColNamed, exprs)?;
        Ok(RPolarsLazyFrame(self.clone().0.select_seq(exprs)))
    }

    fn tail(&self, n: Robj) -> RResult<Self> {
        Ok(RPolarsLazyFrame(self.0.clone().tail(robj_to!(u32, n)?)))
    }

    fn filter(&self, expr: &RPolarsExpr) -> RPolarsLazyFrame {
        let new_df = self.clone().0.filter(expr.0.clone());
        RPolarsLazyFrame(new_df)
    }

    fn drop_nulls(&self, subset: Robj) -> RResult<Self> {
        let subset = robj_to!(Option, VecPLExprCol, subset)?;
        let out = if subset.is_some() {
            RPolarsLazyFrame(self.0.clone().drop_nulls(subset))
        } else {
            RPolarsLazyFrame(self.0.clone().drop_nulls(None))
        };
        Ok(out)
    }

    fn unique(&self, subset: Robj, keep: Robj, maintain_order: Robj) -> RResult<Self> {
        let ke = robj_to!(UniqueKeepStrategy, keep)?;
        let maintain_order = robj_to!(bool, maintain_order)?;
        let subset = robj_to!(Option, Vec, String, subset)?;
        let lf = if maintain_order {
            self.0.clone().unique_stable(
                subset.map(|x| x.into_iter().map(|y| y.into()).collect()),
                ke,
            )
        } else {
            self.0.clone().unique(subset, ke)
        };
        Ok(lf.into())
    }

    fn group_by(&self, exprs: Robj, maintain_order: Robj) -> RResult<RPolarsLazyGroupBy> {
        let expr_vec = robj_to!(VecPLExprColNamed, exprs)?;
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

    fn with_row_index(&self, name: Robj, offset: Robj) -> RResult<Self> {
        Ok(self
            .0
            .clone()
            .with_row_index(
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
        coalesce: Robj,
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

        let coalesce = robj_to!(bool, coalesce)?;
        let coalesce = if coalesce {
            JoinCoalesce::CoalesceColumns
        } else {
            JoinCoalesce::KeepColumns
        };

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
            .coalesce(coalesce)
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
        coalesce: Robj,
    ) -> RResult<Self> {
        let coalesce = match robj_to!(Option, bool, coalesce)? {
            None => JoinCoalesce::JoinSpecific,
            Some(true) => JoinCoalesce::CoalesceColumns,
            Some(false) => JoinCoalesce::KeepColumns,
        };
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
                .coalesce(coalesce)
                .suffix(robj_to!(str, suffix)?)
                .join_nulls(robj_to!(bool, join_nulls)?)
                .validate(robj_to!(JoinValidation, validate)?)
                .finish(),
        ))
    }

    fn join_where(&self, other: Robj, predicates: Robj, suffix: Robj) -> RResult<Self> {
        let ldf = self.0.clone();
        let other = robj_to!(PLLazyFrame, other)?;
        let predicates = robj_to!(VecPLExprColNamed, predicates)?;
        let suffix = robj_to!(str, suffix)?;

        let out = ldf
            .join_builder()
            .with(other)
            .suffix(suffix)
            .join_where(predicates)
            .into();

        Ok(out)
    }

    pub fn sort_by_exprs(
        &self,
        by: Robj,
        dotdotdot: Robj,
        descending: Robj,
        nulls_last: Robj,
        maintain_order: Robj,
        multithreaded: Robj,
    ) -> RResult<Self> {
        let mut exprs = robj_to!(VecPLExprCol, by)?;
        let mut ddd = robj_to!(VecPLExprCol, dotdotdot)?;
        exprs.append(&mut ddd);
        let descending = robj_to!(Vec, bool, descending)?;

        if descending.is_empty() {
            return Err(RPolarsErr::new()
                .plain("`descending` must be of length 1 or of the same length as `by`".into()));
        };

        let nulls_last = robj_to!(Vec, bool, nulls_last)?;
        let maintain_order = robj_to!(bool, maintain_order)?;
        let multithreaded = robj_to!(bool, multithreaded)?;
        Ok(self
            .0
            .clone()
            .sort_by_exprs(
                exprs,
                SortMultipleOptions {
                    descending,
                    nulls_last,
                    maintain_order,
                    multithreaded,
                    limit: None,
                },
            )
            .into())
    }

    fn unpivot(
        &self,
        on: Robj,
        index: Robj,
        value_name: Robj,
        variable_name: Robj,
    ) -> RResult<Self> {
        let args = UnpivotArgsDSL {
            on: robj_to!(Vec, PLExprCol, on)?
                .into_iter()
                .map(|e| e.into())
                .collect(),
            index: robj_to!(Vec, PLExprCol, index)?
                .into_iter()
                .map(|e| e.into())
                .collect(),
            value_name: robj_to!(Option, String, value_name)?.map(|s| s.into()),
            variable_name: robj_to!(Option, String, variable_name)?.map(|s| s.into()),
        };
        Ok(self.0.clone().unpivot(args).into())
    }

    fn rename(&self, existing: Robj, new: Robj) -> RResult<Self> {
        Ok(self
            .0
            .clone()
            .rename(
                robj_to!(Vec, String, existing)?,
                robj_to!(Vec, String, new)?,
                true,
            )
            .into())
    }

    fn schema(&mut self) -> RResult<Pairlist> {
        let schema = self
            .0
            .collect_schema()
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
    fn optimization_toggle(
        &self,
        type_coercion: Robj,
        predicate_pushdown: Robj,
        projection_pushdown: Robj,
        simplify_expression: Robj,
        slice_pushdown: Robj,
        comm_subplan_elim: Robj,
        comm_subexpr_elim: Robj,
        cluster_with_columns: Robj,
        streaming: Robj,
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
            .with_comm_subexpr_elim(robj_to!(bool, comm_subexpr_elim)?)
            .with_cluster_with_columns(robj_to!(bool, cluster_with_columns)?);

        Ok(ldf.into())
    }

    fn profile(&self) -> RResult<List> {
        profile_with_r_func_support(self.0.clone()).map(|(r, p)| list!(result = r, profile = p))
    }

    fn explode(&self, dotdotdot: Robj) -> RResult<Self> {
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
        group_by: Robj,
    ) -> RResult<RPolarsLazyGroupBy> {
        let index_column = robj_to!(PLExprCol, index_column)?;
        let period = Duration::parse(robj_to!(str, period)?);
        let offset = Duration::parse(robj_to!(str, offset)?);
        let closed_window = robj_to!(ClosedWindow, closed)?;
        let group_by = robj_to!(VecPLExprCol, group_by)?;

        let lazy_gb = self.0.clone().rolling(
            index_column,
            group_by,
            RollingGroupOptions {
                index_column: "".into(),
                period,
                offset,
                closed_window,
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
        every: &str,
        period: &str,
        offset: &str,
        label: Robj,
        include_boundaries: Robj,
        closed: Robj,
        by: Robj,
        start_by: Robj,
    ) -> RResult<RPolarsLazyGroupBy> {
        let closed_window = robj_to!(ClosedWindow, closed)?;
        let by = robj_to!(VecPLExprCol, by)?;
        let ldf = self.0.clone();
        let lazy_gb = ldf.group_by_dynamic(
            robj_to!(PLExprCol, index_column)?,
            by,
            pl::DynamicGroupOptions {
                every: pl::Duration::parse(every),
                period: pl::Duration::parse(period),
                offset: pl::Duration::parse(offset),
                label: robj_to!(Label, label)?,
                include_boundaries: robj_to!(bool, include_boundaries)?,
                closed_window,
                start_by: robj_to!(StartBy, start_by)?,
                ..Default::default()
            },
        );

        Ok(RPolarsLazyGroupBy {
            lgb: lazy_gb,
            opt_state: self.0.get_current_optimizations(),
        })
    }

    pub fn to_dot(&self, optimized: Robj) -> RResult<String> {
        let result = self
            .0
            .to_dot(robj_to!(bool, optimized)?)
            .map_err(polars_to_rpolars_err)?;
        Ok(result)
    }

    fn cast(&self, dtypes: List, strict: bool) -> RResult<Self> {
        use polars_core::prelude::InitHashMaps;
        use polars_core::prelude::PlHashMap;

        let dtypes = dtypes
            .iter()
            .map(|(k, v)| {
                let data_type = robj_to!(RPolarsDataType, v)?;
                Ok(pl::Field::new(k.into(), data_type.0))
            })
            .collect::<RResult<Vec<_>>>()?;
        let mut cast_map = PlHashMap::with_capacity(dtypes.len());
        cast_map.extend(
            dtypes
                .iter()
                .map(|f| (f.name().as_ref(), f.dtype().clone())),
        );
        Ok(self.0.clone().cast(cast_map, strict).into())
    }

    fn cast_all(&self, dtype: Robj, strict: Robj) -> RResult<Self> {
        let dtype = robj_to!(RPolarsDataType, dtype)?.0;
        let strict = robj_to!(bool, strict)?;
        Ok(self.0.clone().cast_all(dtype, strict).into())
    }
}

#[derive(Clone)]
pub struct RPolarsLazyGroupBy {
    pub lgb: pl::LazyGroupBy,
    opt_state: pl::OptFlags,
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

    fn agg(&self, exprs: Robj) -> RResult<RPolarsLazyFrame> {
        Ok(RPolarsLazyFrame(
            self.lgb.clone().agg(robj_to!(VecPLExprColNamed, exprs)?),
        ))
    }

    fn head(&self, n: f64) -> RResult<RPolarsLazyFrame> {
        Ok(RPolarsLazyFrame(
            self.lgb.clone().head(Some(try_f64_into_usize(n)?)),
        ))
    }

    fn tail(&self, n: f64) -> RResult<RPolarsLazyFrame> {
        Ok(RPolarsLazyFrame(
            self.lgb.clone().tail(Some(try_f64_into_usize(n)?)),
        ))
    }
}

extendr_module! {
    mod dataframe;
    impl RPolarsLazyFrame;
    impl RPolarsLazyGroupBy;
}
