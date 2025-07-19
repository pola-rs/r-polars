use super::sink::RSinkTarget;
use crate::{
    PlRDataFrame, PlRDataType, PlRExpr, PlRLazyFrame, PlRLazyGroupBy, PlRSeries, RPolarsErr,
    prelude::{sync_on_close::SyncOnCloseType, *},
};
use polars::io::{HiveOptions, RowIndex};
use savvy::{
    ListSexp, LogicalSexp, NumericScalar, OwnedListSexp, OwnedStringSexp, Result, Sexp, StringSexp,
    savvy,
};
use std::{num::NonZeroUsize, path::PathBuf};

#[savvy]
impl PlRLazyFrame {
    fn describe_plan(&self) -> Result<Sexp> {
        let string = self.ldf.describe_plan().map_err(RPolarsErr::from)?;
        let sexp = OwnedStringSexp::try_from_scalar(string)?;
        Ok(sexp.into())
    }

    fn describe_optimized_plan(&self) -> Result<Sexp> {
        let string = self
            .ldf
            .describe_optimized_plan()
            .map_err(RPolarsErr::from)?;
        let sexp = OwnedStringSexp::try_from_scalar(string)?;
        Ok(sexp.into())
    }

    fn describe_plan_tree(&self) -> Result<Sexp> {
        let string = self.ldf.describe_plan_tree().map_err(RPolarsErr::from)?;
        let sexp = OwnedStringSexp::try_from_scalar(string)?;
        Ok(sexp.into())
    }

    fn describe_optimized_plan_tree(&self) -> Result<Sexp> {
        let string = self
            .ldf
            .describe_optimized_plan_tree()
            .map_err(RPolarsErr::from)?;
        let sexp = OwnedStringSexp::try_from_scalar(string)?;
        Ok(sexp.into())
    }

    fn optimization_toggle(
        &self,
        type_coercion: bool,
        _type_check: bool,
        predicate_pushdown: bool,
        projection_pushdown: bool,
        simplify_expression: bool,
        slice_pushdown: bool,
        comm_subplan_elim: bool,
        comm_subexpr_elim: bool,
        cluster_with_columns: bool,
        collapse_joins: bool,
        _eager: bool,
        _check_order: bool,
    ) -> Result<Self> {
        let ldf = self
            .ldf
            .clone()
            .with_type_coercion(type_coercion)
            .with_type_check(_type_check)
            .with_predicate_pushdown(predicate_pushdown)
            .with_simplify_expr(simplify_expression)
            .with_slice_pushdown(slice_pushdown)
            .with_collapse_joins(collapse_joins)
            .with_check_order(_check_order)
            .with_comm_subplan_elim(comm_subplan_elim)
            .with_comm_subexpr_elim(comm_subexpr_elim)
            .with_cluster_with_columns(cluster_with_columns)
            ._with_eager(_eager)
            .with_projection_pushdown(projection_pushdown);

        Ok(ldf.into())
    }

    fn filter(&mut self, predicate: &PlRExpr) -> Result<Self> {
        let ldf = self.ldf.clone();
        Ok(ldf.filter(predicate.inner.clone()).into())
    }

    fn select(&mut self, exprs: ListSexp) -> Result<Self> {
        let ldf = self.ldf.clone();
        let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
        Ok(ldf.select(exprs).into())
    }

    fn group_by(&mut self, by: ListSexp, maintain_order: bool) -> Result<PlRLazyGroupBy> {
        let ldf = self.ldf.clone();
        let by = <Wrap<Vec<Expr>>>::from(by).0;
        let lazy_gb = if maintain_order {
            ldf.group_by_stable(by)
        } else {
            ldf.group_by(by)
        };

        Ok(lazy_gb.into())
    }

    fn collect(&self, engine: &str) -> Result<PlRDataFrame> {
        use crate::{
            r_threads::{ThreadCom, concurrent_handler},
            r_udf::{CONFIG, RUdfReturn, RUdfSignature},
        };
        fn serve_r(
            udf_sig: RUdfSignature,
        ) -> std::result::Result<RUdfReturn, Box<dyn std::error::Error>> {
            udf_sig.eval()
        }

        let ldf = self.ldf.clone();
        let engine = <Wrap<Engine>>::try_from(engine)?.0;

        #[cfg(not(target_arch = "wasm32"))]
        let df = if ThreadCom::try_from_global(&CONFIG).is_ok() {
            ldf.collect_with_engine(engine).map_err(RPolarsErr::from)?
        } else {
            concurrent_handler(
                // closure 1: spawned by main thread
                // tc is a ThreadCom which any child thread can use to submit R jobs to main thread
                move |tc| {
                    // get return value
                    let retval = ldf.collect_with_engine(engine);

                    // drop the last two ThreadCom clones, signals to main/R-serving thread to shut down.
                    ThreadCom::kill_global(&CONFIG);
                    drop(tc);

                    retval
                },
                // closure 2: how to serve polars worker R job request in main thread
                serve_r,
                // CONFIG is "global variable" where any new thread can request a clone of ThreadCom to establish contact with main thread
                &CONFIG,
            )
            .map_err(|e| e.to_string())?
            .map_err(RPolarsErr::from)?
        };

        #[cfg(target_arch = "wasm32")]
        let df = ldf.collect().map_err(RPolarsErr::from)?;

        Ok(df.into())
    }

    fn slice(&self, offset: NumericScalar, len: Option<NumericScalar>) -> Result<Self> {
        let ldf = self.ldf.clone();
        let offset = <Wrap<i64>>::try_from(offset)?.0;
        let len = len.map(<Wrap<u32>>::try_from).transpose()?.map(|l| l.0);
        Ok(ldf.slice(offset, len.unwrap_or(u32::MAX)).into())
    }

    fn tail(&self, n: NumericScalar) -> Result<Self> {
        let ldf = self.ldf.clone();
        let n = <Wrap<u32>>::try_from(n)?.0;
        Ok(ldf.tail(n).into())
    }

    fn drop(&self, columns: ListSexp, strict: bool) -> Result<Self> {
        let ldf = self.ldf.clone();
        let columns = <Wrap<Vec<Expr>>>::from(columns).0;
        if strict {
            Ok(ldf.drop(columns).into())
        } else {
            Ok(ldf.drop_no_validate(columns).into())
        }
    }

    fn cast(&self, dtypes: ListSexp, strict: bool) -> Result<Self> {
        let dtypes = <Wrap<Vec<Field>>>::try_from(dtypes)?.0;
        let mut cast_map = PlHashMap::with_capacity(dtypes.len());
        cast_map.extend(dtypes.iter().map(|f| (f.name.as_ref(), f.dtype.clone())));
        Ok(self.ldf.clone().cast(cast_map, strict).into())
    }

    fn cast_all(&self, dtype: &PlRDataType, strict: bool) -> Result<Self> {
        Ok(self.ldf.clone().cast_all(dtype.dt.clone(), strict).into())
    }

    fn collect_schema(&mut self) -> Result<Sexp> {
        let schema = self.ldf.collect_schema().map_err(RPolarsErr::from)?;
        let mut out = OwnedListSexp::new(schema.len(), true)?;
        for (i, (name, dtype)) in schema.iter().enumerate() {
            let value: Sexp = PlRDataType::from(dtype.clone()).try_into()?;
            let _ = out.set_name_and_value(i, name.as_str(), value);
        }
        Ok(out.into())
    }

    fn sort_by_exprs(
        &self,
        by: ListSexp,
        descending: LogicalSexp,
        nulls_last: LogicalSexp,
        maintain_order: bool,
        multithreaded: bool,
    ) -> Result<Self> {
        let ldf = self.ldf.clone();
        let by = <Wrap<Vec<Expr>>>::from(by).0;
        Ok(ldf
            .sort_by_exprs(
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

    fn with_columns(&mut self, exprs: ListSexp) -> Result<Self> {
        let ldf = self.ldf.clone();
        let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
        Ok(ldf.with_columns(exprs).into())
    }

    fn to_dot(&self, optimized: bool) -> Result<Sexp> {
        let result: OwnedStringSexp = self
            .ldf
            .to_dot(optimized)
            .map_err(RPolarsErr::from)?
            .try_into()?;
        Ok(result.into())
    }

    fn sort(
        &self,
        by_column: &str,
        descending: bool,
        nulls_last: bool,
        maintain_order: bool,
        multithreaded: bool,
    ) -> Result<Self> {
        let ldf = self.ldf.clone();
        Ok(ldf
            .sort(
                [by_column],
                SortMultipleOptions {
                    descending: vec![descending],
                    nulls_last: vec![nulls_last],
                    multithreaded,
                    maintain_order,
                    limit: None,
                },
            )
            .into())
    }

    fn top_k(&self, k: NumericScalar, by: ListSexp, reverse: LogicalSexp) -> Result<Self> {
        let ldf = self.ldf.clone();
        let k = <Wrap<u32>>::try_from(k)?.0;
        let exprs = <Wrap<Vec<Expr>>>::from(by).0;
        let reverse = reverse.to_vec();
        Ok(ldf
            .top_k(
                k,
                exprs,
                SortMultipleOptions::new().with_order_descending_multi(reverse),
            )
            .into())
    }

    fn bottom_k(&self, k: NumericScalar, by: ListSexp, reverse: LogicalSexp) -> Result<Self> {
        let ldf = self.ldf.clone();
        let k = <Wrap<u32>>::try_from(k)?.0;
        let exprs = <Wrap<Vec<Expr>>>::from(by).0;
        let reverse = reverse.to_vec();
        Ok(ldf
            .bottom_k(
                k,
                exprs,
                SortMultipleOptions::new().with_order_descending_multi(reverse),
            )
            .into())
    }

    fn cache(&self) -> Result<Self> {
        let ldf = self.ldf.clone();
        Ok(ldf.cache().into())
    }

    fn profile(&self) -> Result<Sexp> {
        use crate::{
            r_threads::{ThreadCom, concurrent_handler},
            r_udf::{CONFIG, RUdfReturn, RUdfSignature},
        };
        fn serve_r(
            udf_sig: RUdfSignature,
        ) -> std::result::Result<RUdfReturn, Box<dyn std::error::Error>> {
            udf_sig.eval()
        }

        let ldf = self.ldf.clone();
        let (data, timings) = if ThreadCom::try_from_global(&CONFIG).is_ok() {
            let ldf = self.ldf.clone();
            ldf.profile().map_err(RPolarsErr::from)?
        } else {
            concurrent_handler(
                // closure 1: spawned by main thread
                // tc is a ThreadCom which any child thread can use to submit R jobs to main thread
                move |tc| {
                    // get return value
                    let retval = ldf.profile();

                    // drop the last two ThreadCom clones, signals to main/R-serving thread to shut down.
                    ThreadCom::kill_global(&CONFIG);
                    drop(tc);

                    retval
                },
                // closure 2: how to serve polars worker R job request in main thread
                serve_r,
                // CONFIG is "global variable" where any new thread can request a clone of ThreadCom to establish contact with main thread
                &CONFIG,
            )
            .map_err(|e| e.to_string())?
            .map_err(RPolarsErr::from)?
        };

        let data = <PlRDataFrame>::from(data);
        let timings = <PlRDataFrame>::from(timings);

        let mut out = OwnedListSexp::new(2, true)?;
        unsafe {
            out.set_value_unchecked(0, Sexp::try_from(data)?.0);
            out.set_value_unchecked(1, Sexp::try_from(timings)?.0);
        };
        Ok(out.into())
    }

    fn select_seq(&mut self, exprs: ListSexp) -> Result<Self> {
        let ldf = self.ldf.clone();
        let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
        Ok(ldf.select_seq(exprs).into())
    }

    fn rolling(
        &mut self,
        index_column: &PlRExpr,
        period: &str,
        offset: &str,
        closed: &str,
        by: ListSexp,
    ) -> Result<PlRLazyGroupBy> {
        let closed_window = <Wrap<ClosedWindow>>::try_from(closed)?.0;
        let ldf = self.ldf.clone();
        let by = <Wrap<Vec<Expr>>>::from(by).0;
        let lazy_gb = ldf.rolling(
            index_column.inner.clone(),
            by,
            RollingGroupOptions {
                index_column: "".into(),
                period: Duration::try_parse(period).map_err(RPolarsErr::from)?,
                offset: Duration::try_parse(offset).map_err(RPolarsErr::from)?,
                closed_window,
            },
        );

        Ok(PlRLazyGroupBy { lgb: Some(lazy_gb) })
    }

    fn group_by_dynamic(
        &mut self,
        index_column: &PlRExpr,
        every: &str,
        period: &str,
        offset: &str,
        label: &str,
        include_boundaries: bool,
        closed: &str,
        group_by: ListSexp,
        start_by: &str,
    ) -> Result<PlRLazyGroupBy> {
        let closed_window = <Wrap<ClosedWindow>>::try_from(closed)?.0;
        let group_by = <Wrap<Vec<Expr>>>::from(group_by).0;
        let ldf = self.ldf.clone();
        let label = <Wrap<Label>>::try_from(label)?.0;
        let start_by = <Wrap<StartBy>>::try_from(start_by)?.0;
        let lazy_gb = ldf.group_by_dynamic(
            index_column.inner.clone(),
            group_by,
            DynamicGroupOptions {
                every: Duration::try_parse(every).map_err(RPolarsErr::from)?,
                period: Duration::try_parse(period).map_err(RPolarsErr::from)?,
                offset: Duration::try_parse(offset).map_err(RPolarsErr::from)?,
                label,
                include_boundaries,
                closed_window,
                start_by,
                ..Default::default()
            },
        );

        Ok(PlRLazyGroupBy { lgb: Some(lazy_gb) })
    }

    fn join_asof(
        &self,
        other: &PlRLazyFrame,
        left_on: &PlRExpr,
        right_on: &PlRExpr,
        allow_parallel: bool,
        force_parallel: bool,
        suffix: &str,
        coalesce: bool,
        strategy: &str,
        allow_eq: bool,
        check_sortedness: bool,
        left_by: Option<StringSexp>,
        right_by: Option<StringSexp>,
        tolerance: Option<&PlRSeries>,
        tolerance_str: Option<&str>,
    ) -> Result<Self> {
        let coalesce = if coalesce {
            JoinCoalesce::CoalesceColumns
        } else {
            JoinCoalesce::KeepColumns
        };
        let strategy = <Wrap<AsofStrategy>>::try_from(strategy)?.0;
        let ldf = self.ldf.clone();
        let other = other.ldf.clone();
        let left_on = left_on.inner.clone();
        let right_on = right_on.inner.clone();
        let left_by = left_by.map(|x| x.to_vec().into_iter().map(|y| y.into()).collect());
        let right_by = right_by.map(|x| x.to_vec().into_iter().map(|y| y.into()).collect());
        let tolerance = match tolerance {
            Some(x) => Some(
                x.series
                    .clone()
                    .get(0)
                    .map_err(RPolarsErr::from)?
                    .into_static(),
            ),
            None => None,
        };
        Ok(ldf
            .join_builder()
            .with(other)
            .left_on([left_on])
            .right_on([right_on])
            .allow_parallel(allow_parallel)
            .force_parallel(force_parallel)
            .coalesce(coalesce)
            .how(JoinType::AsOf(AsOfOptions {
                strategy,
                left_by,
                right_by,
                tolerance,
                tolerance_str: tolerance_str.map(|s| s.into()),
                allow_eq,
                check_sortedness,
            }))
            .suffix(suffix)
            .finish()
            .into())
    }

    fn join(
        &self,
        other: &PlRLazyFrame,
        left_on: ListSexp,
        right_on: ListSexp,
        allow_parallel: bool,
        force_parallel: bool,
        nulls_equal: bool,
        how: &str,
        suffix: &str,
        validate: &str,
        maintain_order: &str,
        coalesce: Option<bool>,
    ) -> Result<Self> {
        let coalesce = match coalesce {
            None => JoinCoalesce::JoinSpecific,
            Some(true) => JoinCoalesce::CoalesceColumns,
            Some(false) => JoinCoalesce::KeepColumns,
        };
        let ldf = self.ldf.clone();
        let other = other.ldf.clone();
        let left_on = <Wrap<Vec<Expr>>>::from(left_on).0;
        let right_on = <Wrap<Vec<Expr>>>::from(right_on).0;

        let how = <Wrap<JoinType>>::try_from(how)?.0;
        let maintain_order = <Wrap<MaintainOrderJoin>>::try_from(maintain_order)?.0;
        let validate = <Wrap<JoinValidation>>::try_from(validate)?.0;
        Ok(ldf
            .join_builder()
            .with(other)
            .left_on(left_on)
            .right_on(right_on)
            .allow_parallel(allow_parallel)
            .force_parallel(force_parallel)
            .join_nulls(nulls_equal)
            .how(how)
            .coalesce(coalesce)
            .validate(validate)
            .suffix(suffix)
            .maintain_order(maintain_order)
            .finish()
            .into())
    }

    fn join_where(&self, other: &PlRLazyFrame, predicates: ListSexp, suffix: &str) -> Result<Self> {
        let ldf = self.ldf.clone();
        let other = other.ldf.clone();

        let predicates = <Wrap<Vec<Expr>>>::from(predicates).0;

        Ok(ldf
            .join_builder()
            .with(other)
            .suffix(suffix)
            .join_where(predicates)
            .into())
    }

    fn with_columns_seq(&mut self, exprs: ListSexp) -> Result<Self> {
        let ldf = self.ldf.clone();
        let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
        Ok(ldf.with_columns_seq(exprs).into())
    }

    fn rename(&mut self, existing: StringSexp, new: StringSexp, strict: bool) -> Result<Self> {
        let ldf = self.ldf.clone();
        Ok(ldf.rename(existing.to_vec(), new.to_vec(), strict).into())
    }

    fn reverse(&self) -> Result<Self> {
        let ldf = self.ldf.clone();
        Ok(ldf.reverse().into())
    }

    fn shift(&self, n: &PlRExpr, fill_value: Option<&PlRExpr>) -> Result<Self> {
        let lf = self.ldf.clone();
        let out = match fill_value {
            Some(v) => lf.shift_and_fill(n.inner.clone(), v.inner.clone()),
            None => lf.shift(n.inner.clone()),
        };
        Ok(out.into())
    }

    fn fill_nan(&self, fill_value: &PlRExpr) -> Result<Self> {
        let ldf = self.ldf.clone();
        Ok(ldf.fill_nan(fill_value.inner.clone()).into())
    }

    fn min(&self) -> Result<Self> {
        let ldf = self.ldf.clone();
        let out = ldf.min();
        Ok(out.into())
    }

    fn max(&self) -> Result<Self> {
        let ldf = self.ldf.clone();
        let out = ldf.max();
        Ok(out.into())
    }

    fn sum(&self) -> Result<Self> {
        let ldf = self.ldf.clone();
        let out = ldf.sum();
        Ok(out.into())
    }

    fn mean(&self) -> Result<Self> {
        let ldf = self.ldf.clone();
        let out = ldf.mean();
        Ok(out.into())
    }

    fn std(&self, ddof: NumericScalar) -> Result<Self> {
        let ddof = <Wrap<u8>>::try_from(ddof)?.0;
        let ldf = self.ldf.clone();
        let out = ldf.std(ddof);
        Ok(out.into())
    }

    fn var(&self, ddof: NumericScalar) -> Result<Self> {
        let ddof = <Wrap<u8>>::try_from(ddof)?.0;
        let ldf = self.ldf.clone();
        let out = ldf.var(ddof);
        Ok(out.into())
    }

    fn median(&self) -> Result<Self> {
        let ldf = self.ldf.clone();
        let out = ldf.median();
        Ok(out.into())
    }

    fn quantile(&self, quantile: &PlRExpr, interpolation: &str) -> Result<Self> {
        let ldf = self.ldf.clone();
        let interpolation = <Wrap<QuantileMethod>>::try_from(interpolation)?.0;
        let out = ldf.quantile(quantile.inner.clone(), interpolation);
        Ok(out.into())
    }

    fn explode(&self, column: ListSexp) -> Result<Self> {
        let ldf = self.ldf.clone();
        let column = <Wrap<Vec<Expr>>>::from(column).0;
        Ok(ldf.explode(column).into())
    }

    fn null_count(&self) -> Result<Self> {
        let ldf = self.ldf.clone();
        Ok(ldf.null_count().into())
    }

    fn unique(&self, maintain_order: bool, keep: &str, subset: Option<ListSexp>) -> Result<Self> {
        let ldf = self.ldf.clone();
        let keep = <Wrap<UniqueKeepStrategy>>::try_from(keep)?.0;
        let subset = subset.map(|e| <Wrap<Vec<Expr>>>::from(e).0);
        let out = match maintain_order {
            true => ldf.unique_stable_generic(subset, keep),
            false => ldf.unique_generic(subset, keep),
        };
        Ok(out.into())
    }

    fn drop_nulls(&self, subset: Option<ListSexp>) -> Result<Self> {
        let ldf = self.ldf.clone();
        let subset = subset.map(|e| <Wrap<Vec<Expr>>>::from(e).0);
        Ok(ldf.drop_nulls(subset).into())
    }

    fn drop_nans(&self, subset: Option<ListSexp>) -> Result<Self> {
        let ldf = self.ldf.clone();
        let subset = subset.map(|e| <Wrap<Vec<Expr>>>::from(e).0);
        Ok(ldf.drop_nans(subset).into())
    }

    fn unpivot(
        &self,
        on: ListSexp,
        index: ListSexp,
        value_name: Option<&str>,
        variable_name: Option<&str>,
    ) -> Result<Self> {
        let on = <Wrap<Vec<Expr>>>::from(on).0;
        let index = <Wrap<Vec<Expr>>>::from(index).0;
        let args = UnpivotArgsDSL {
            on: on.into_iter().map(|e| e.into()).collect(),
            index: index.into_iter().map(|e| e.into()).collect(),
            value_name: value_name.map(|s| s.into()),
            variable_name: variable_name.map(|s| s.into()),
        };

        let ldf = self.ldf.clone();
        Ok(ldf.unpivot(args).into())
    }

    fn with_row_index(&self, name: &str, offset: Option<NumericScalar>) -> Result<Self> {
        let ldf = self.ldf.clone();
        let offset: Option<u32> = match offset {
            Some(x) => Some(<Wrap<u32>>::try_from(x)?.0),
            None => None,
        };
        Ok(ldf.with_row_index(name, offset).into())
    }

    // fn map_batches(
    //     &self,
    //     lambda: PyObject,
    //     predicate_pushdown: bool,
    //     projection_pushdown: bool,
    //     slice_pushdown: bool,
    //     streamable: bool,
    //     schema: Option<Wrap<Schema>>,
    //     validate_output: bool,
    // ) -> Result<Self> {
    //     let mut opt = OptFlags::default();
    //     opt.set(OptFlags::PREDICATE_PUSHDOWN, predicate_pushdown);
    //     opt.set(OptFlags::PROJECTION_PUSHDOWN, projection_pushdown);
    //     opt.set(OptFlags::SLICE_PUSHDOWN, slice_pushdown);
    //     opt.set(OptFlags::STREAMING, streamable);

    //     self.ldf
    //         .clone()
    //         .map_python(
    //             lambda.into(),
    //             opt,
    //             schema.map(|s| Arc::new(s.0)),
    //             validate_output,
    //         )
    //         .into()
    // }

    fn clone(&self) -> Result<Self> {
        Ok(self.ldf.clone().into())
    }

    fn unnest(&self, columns: ListSexp) -> Result<Self> {
        let columns = <Wrap<Vec<Expr>>>::from(columns).0;
        Ok(self.ldf.clone().unnest(columns).into())
    }

    fn count(&self) -> Result<Self> {
        let ldf = self.ldf.clone();
        Ok(ldf.count().into())
    }

    fn merge_sorted(&self, other: &PlRLazyFrame, key: &str) -> Result<Self> {
        let out = self
            .ldf
            .clone()
            .merge_sorted(other.ldf.clone(), key)
            .map_err(RPolarsErr::from)?;
        Ok(out.into())
    }

    fn new_from_ipc(
        source: StringSexp,
        cache: bool,
        rechunk: bool,
        try_parse_hive_dates: bool,
        retries: NumericScalar,
        row_index_offset: NumericScalar,
        n_rows: Option<NumericScalar>,
        row_index_name: Option<&str>,
        storage_options: Option<StringSexp>,
        hive_partitioning: Option<bool>,
        hive_schema: Option<ListSexp>,
        file_cache_ttl: Option<NumericScalar>,
        include_file_paths: Option<&str>,
    ) -> Result<Self> {
        #[cfg(not(target_arch = "wasm32"))]
        {
            let source = source
                .to_vec()
                .iter()
                .map(PathBuf::from)
                .collect::<Vec<PathBuf>>();
            let row_index_offset = <Wrap<u32>>::try_from(row_index_offset)?.0;
            let retries = <Wrap<usize>>::try_from(retries)?.0;
            let hive_schema = match hive_schema {
                Some(x) => Some(<Wrap<Schema>>::try_from(x)?),
                None => None,
            };
            let n_rows = match n_rows {
                Some(x) => Some(<Wrap<usize>>::try_from(x)?.0),
                None => None,
            };
            let row_index = row_index_name.map(|x| RowIndex {
                name: x.into(),
                offset: row_index_offset,
            });
            let file_cache_ttl = match file_cache_ttl {
                Some(x) => Some(<Wrap<u64>>::try_from(x)?.0),
                None => None,
            };
            let hive_options = HiveOptions {
                enabled: hive_partitioning,
                hive_start_idx: 0,
                schema: hive_schema.map(|x| Arc::new(x.0)),
                try_parse_dates: try_parse_hive_dates,
            };
            // TODO: better error message
            // TODO: Refactor with adding `cloud` feature as like Python Polars
            #[cfg(not(target_arch = "wasm32"))]
            let cloud_options = match storage_options {
                Some(x) => {
                    let out = <Wrap<Vec<(String, String)>>>::try_from(x).map_err(|_| {
                        RPolarsErr::Other(
                            "`storage_options` must be a named character vector".to_string(),
                        )
                    })?;
                    Some(out.0)
                }
                None => None,
            };

            #[cfg(target_arch = "wasm32")]
            let cloud_options: Option<Vec<(String, String)>> = None;

            let mut args = ScanArgsIpc {
                n_rows,
                cache,
                rechunk,
                row_index,
                cloud_options: None,
                hive_options,
                include_file_paths: include_file_paths.map(|x| x.into()),
            };

            let first_path: Option<PathBuf> = source.first().unwrap().clone().into();

            // TODO: Refactor with adding `cloud` feature as like Python Polars
            #[cfg(not(target_arch = "wasm32"))]
            if let Some(first_path) = first_path {
                let first_path_url = first_path.to_string_lossy();
                let mut cloud_options =
                    parse_cloud_options(&first_path_url, cloud_options.unwrap_or_default())?;
                if let Some(file_cache_ttl) = file_cache_ttl {
                    cloud_options.file_cache_ttl = file_cache_ttl;
                }
                args.cloud_options = Some(cloud_options.with_max_retries(retries));
            }
            let lf = LazyFrame::scan_ipc_files(source.into(), args).map_err(RPolarsErr::from)?;
            Ok(lf.into())
        }
        #[cfg(target_arch = "wasm32")]
        {
            Err(RPolarsErr::Other(format!("Not supported in WASM")).into())
        }
    }

    fn new_from_csv(
        source: StringSexp,
        separator: &str,
        has_header: bool,
        ignore_errors: bool,
        skip_rows: NumericScalar,
        cache: bool,
        missing_utf8_is_empty_string: bool,
        low_memory: bool,
        rechunk: bool,
        skip_rows_after_header: NumericScalar,
        encoding: &str,
        try_parse_dates: bool,
        eol_char: &str,
        raise_if_empty: bool,
        truncate_ragged_lines: bool,
        decimal_comma: bool,
        glob: bool,
        retries: NumericScalar,
        row_index_offset: NumericScalar,
        comment_prefix: Option<&str>,
        quote_char: Option<&str>,
        null_values: Option<StringSexp>,
        infer_schema_length: Option<NumericScalar>,
        row_index_name: Option<&str>,
        n_rows: Option<NumericScalar>,
        overwrite_dtype: Option<ListSexp>,
        schema: Option<ListSexp>,
        storage_options: Option<StringSexp>,
        file_cache_ttl: Option<NumericScalar>,
        include_file_paths: Option<&str>,
    ) -> Result<Self> {
        #[cfg(not(target_arch = "wasm32"))]
        {
            let source = source
                .to_vec()
                .iter()
                .map(PathBuf::from)
                .collect::<Vec<PathBuf>>();
            let encoding = <Wrap<CsvEncoding>>::try_from(encoding)?.0;
            let skip_rows = <Wrap<usize>>::try_from(skip_rows)?.0;
            let skip_rows_after_header = <Wrap<usize>>::try_from(skip_rows_after_header)?.0;
            let infer_schema_length = match infer_schema_length {
                Some(x) => Some(<Wrap<usize>>::try_from(x)?.0),
                None => None,
            };
            let row_index_offset = <Wrap<u32>>::try_from(row_index_offset)?.0;
            let n_rows = match n_rows {
                Some(x) => Some(<Wrap<usize>>::try_from(x)?.0),
                None => None,
            };
            let null_values = match null_values {
                Some(x) => Some(<Wrap<NullValues>>::try_from(x)?.0),
                None => None,
            };
            let retries = <Wrap<usize>>::try_from(retries)?.0;
            let file_cache_ttl = match file_cache_ttl {
                Some(x) => Some(<Wrap<u64>>::try_from(x)?.0),
                None => None,
            };

            let quote_char = quote_char
                .map(|s| {
                    s.as_bytes().first().ok_or_else(
                        || polars_err!(InvalidOperation: "`quote_char` cannot be empty"),
                    )
                })
                .transpose()
                .map_err(RPolarsErr::from)?
                .copied();
            let separator = separator
                .as_bytes()
                .first()
                .ok_or_else(|| polars_err!(InvalidOperation: "`separator` cannot be empty"))
                .copied()
                .map_err(RPolarsErr::from)?;
            let eol_char = eol_char
                .as_bytes()
                .first()
                .ok_or_else(|| polars_err!(InvalidOperation: "`eol_char` cannot be empty"))
                .copied()
                .map_err(RPolarsErr::from)?;

            let row_index = row_index_name.map(|x| RowIndex {
                name: x.into(),
                offset: row_index_offset,
            });

            let overwrite_dtype = match overwrite_dtype {
                Some(x) => Some(<Wrap<Schema>>::try_from(x)?.0),
                None => None,
            };

            let schema = match schema {
                Some(x) => Some(<Wrap<Schema>>::try_from(x)?.0),
                None => None,
            };

            // TODO: Refactor with adding `cloud` feature as like Python Polars
            #[cfg(not(target_arch = "wasm32"))]
            let cloud_options = match storage_options {
                Some(x) => {
                    let out = <Wrap<Vec<(String, String)>>>::try_from(x).map_err(|_| {
                        RPolarsErr::Other(
                            "`storage_options` must be a named character vector".to_string(),
                        )
                    })?;
                    Some(out.0)
                }
                None => None,
            };

            #[cfg(target_arch = "wasm32")]
            let cloud_options: Option<Vec<(String, String)>> = None;

            let mut r = LazyCsvReader::new_paths(source.clone().into());
            let first_path: Option<PathBuf> = source.first().unwrap().clone().into();

            // TODO: Refactor with adding `cloud` feature as like Python Polars
            #[cfg(not(target_arch = "wasm32"))]
            if let Some(first_path) = first_path {
                let first_path_url = first_path.to_string_lossy();

                let mut cloud_options =
                    parse_cloud_options(&first_path_url, cloud_options.unwrap_or_default())?;
                if let Some(file_cache_ttl) = file_cache_ttl {
                    cloud_options.file_cache_ttl = file_cache_ttl;
                }
                cloud_options = cloud_options.with_max_retries(retries);
                r = r.with_cloud_options(Some(cloud_options));
            }

            let r = r
                .with_infer_schema_length(infer_schema_length)
                .with_separator(separator)
                .with_has_header(has_header)
                .with_ignore_errors(ignore_errors)
                .with_skip_rows(skip_rows)
                .with_n_rows(n_rows)
                .with_cache(cache)
                .with_dtype_overwrite(overwrite_dtype.map(Arc::new))
                .with_schema(schema.map(Arc::new))
                .with_low_memory(low_memory)
                .with_comment_prefix(comment_prefix.map(|x| x.into()))
                .with_quote_char(quote_char)
                .with_eol_char(eol_char)
                .with_rechunk(rechunk)
                .with_skip_rows_after_header(skip_rows_after_header)
                .with_encoding(encoding)
                .with_row_index(row_index)
                .with_try_parse_dates(try_parse_dates)
                .with_null_values(null_values)
                .with_missing_is_null(!missing_utf8_is_empty_string)
                .with_truncate_ragged_lines(truncate_ragged_lines)
                .with_decimal_comma(decimal_comma)
                .with_glob(glob)
                .with_raise_if_empty(raise_if_empty)
                .with_include_file_paths(include_file_paths.map(|x| x.into()));

            Ok(r.finish().map_err(RPolarsErr::from)?.into())
        }
        #[cfg(target_arch = "wasm32")]
        {
            Err(RPolarsErr::Other(format!("Not supported in WASM")).into())
        }
    }

    #[allow(unused_variables)]
    fn new_from_parquet(
        source: StringSexp,
        cache: bool,
        parallel: &str,
        rechunk: bool,
        low_memory: bool,
        use_statistics: bool,
        try_parse_hive_dates: bool,
        retries: NumericScalar,
        glob: bool,
        allow_missing_columns: bool,
        row_index_offset: NumericScalar,
        storage_options: Option<StringSexp>,
        n_rows: Option<NumericScalar>,
        row_index_name: Option<&str>,
        hive_partitioning: Option<bool>,
        schema: Option<ListSexp>,
        hive_schema: Option<ListSexp>,
        include_file_paths: Option<&str>,
    ) -> Result<Self> {
        #[cfg(not(target_arch = "wasm32"))]
        {
            let source = source
                .to_vec()
                .iter()
                .map(PathBuf::from)
                .collect::<Vec<PathBuf>>();
            let row_index_offset = <Wrap<u32>>::try_from(row_index_offset)?.0;
            let n_rows = match n_rows {
                Some(x) => Some(<Wrap<usize>>::try_from(x)?.0),
                None => None,
            };
            let parallel = <Wrap<ParallelStrategy>>::try_from(parallel)?.0;
            let retries = <Wrap<usize>>::try_from(retries)?.0;
            let hive_schema = match hive_schema {
                Some(x) => Some(Arc::new(<Wrap<Schema>>::try_from(x)?.0)),
                None => None,
            };
            let schema = match schema {
                Some(x) => Some(<Wrap<Schema>>::try_from(x)?.0),
                None => None,
            };

            let row_index = row_index_name.map(|x| RowIndex {
                name: x.into(),
                offset: row_index_offset,
            });

            let hive_options = HiveOptions {
                enabled: hive_partitioning,
                hive_start_idx: 0,
                schema: hive_schema,
                try_parse_dates: try_parse_hive_dates,
            };

            let mut args = ScanArgsParquet {
                n_rows,
                cache,
                parallel,
                rechunk,
                row_index,
                low_memory,
                cloud_options: None,
                use_statistics,
                schema: schema.map(Arc::new),
                hive_options,
                glob,
                include_file_paths: include_file_paths.map(|x| x.into()),
                allow_missing_columns,
            };

            let first_path = source.first().unwrap().clone().into();

            // TODO: Refactor with adding `cloud` feature as like Python Polars
            #[cfg(not(target_arch = "wasm32"))]
            let cloud_options = match storage_options {
                Some(x) => {
                    let out = <Wrap<Vec<(String, String)>>>::try_from(x).map_err(|_| {
                        RPolarsErr::Other(
                            "`storage_options` must be a named character vector".to_string(),
                        )
                    })?;
                    Some(out.0)
                }
                None => None,
            };

            #[cfg(target_arch = "wasm32")]
            let cloud_options: Option<Vec<(String, String)>> = None;

            // TODO: Refactor with adding `cloud` feature as like Python Polars
            #[cfg(not(target_arch = "wasm32"))]
            if let Some(first_path) = first_path {
                let first_path_url = first_path.to_string_lossy();
                let cloud_options =
                    parse_cloud_options(&first_path_url, cloud_options.unwrap_or_default())?;
                args.cloud_options = Some(cloud_options.with_max_retries(retries));
            }

            let lf =
                LazyFrame::scan_parquet_files(source.into(), args).map_err(RPolarsErr::from)?;

            Ok(lf.into())
        }
        #[cfg(target_arch = "wasm32")]
        {
            Err(RPolarsErr::Other(format!("Not supported in WASM")).into())
        }
    }

    #[allow(unused_variables)]
    fn new_from_ndjson(
        source: StringSexp,
        low_memory: bool,
        rechunk: bool,
        ignore_errors: bool,
        retries: NumericScalar,
        row_index_offset: NumericScalar,
        row_index_name: Option<&str>,
        infer_schema_length: Option<NumericScalar>,
        schema: Option<ListSexp>,
        schema_overrides: Option<ListSexp>,
        batch_size: Option<NumericScalar>,
        n_rows: Option<NumericScalar>,
        include_file_paths: Option<&str>,
        storage_options: Option<StringSexp>,
        file_cache_ttl: Option<NumericScalar>,
    ) -> Result<Self> {
        #[cfg(not(target_arch = "wasm32"))]
        {
            let source = source
                .to_vec()
                .iter()
                .map(PathBuf::from)
                .collect::<Vec<PathBuf>>();
            let row_index_offset = <Wrap<u32>>::try_from(row_index_offset)?.0;
            let infer_schema_length = match infer_schema_length {
                Some(x) => Some(<Wrap<usize>>::try_from(x)?.0),
                None => None,
            };
            let batch_size = match batch_size {
                Some(x) => Some(<Wrap<NonZeroUsize>>::try_from(x)?.0),
                None => None,
            };
            let n_rows = match n_rows {
                Some(x) => Some(<Wrap<usize>>::try_from(x)?.0),
                None => None,
            };
            let file_cache_ttl = match file_cache_ttl {
                Some(x) => Some(<Wrap<u64>>::try_from(x)?.0),
                None => None,
            };
            let retries = <Wrap<usize>>::try_from(retries)?.0;
            let schema = match schema {
                Some(x) => Some(<Wrap<Schema>>::try_from(x)?.0),
                None => None,
            };
            let schema_overrides = match schema_overrides {
                Some(x) => Some(<Wrap<Schema>>::try_from(x)?.0),
                None => None,
            };

            let row_index = row_index_name.map(|x| RowIndex {
                name: x.into(),
                offset: row_index_offset,
            });

            let first_path = source.first().unwrap().clone().into();

            let mut r = LazyJsonLineReader::new_paths(source.into());

            // TODO: Refactor with adding `cloud` feature as like Python Polars
            #[cfg(not(target_arch = "wasm32"))]
            let cloud_options = match storage_options {
                Some(x) => {
                    let out = <Wrap<Vec<(String, String)>>>::try_from(x).map_err(|_| {
                        RPolarsErr::Other(
                            "`storage_options` must be a named character vector".to_string(),
                        )
                    })?;
                    Some(out.0)
                }
                None => None,
            };

            #[cfg(target_arch = "wasm32")]
            let cloud_options: Option<Vec<(String, String)>> = None;

            // TODO: Refactor with adding `cloud` feature as like Python Polars
            #[cfg(not(target_arch = "wasm32"))]
            if let Some(first_path) = first_path {
                let first_path_url = first_path.to_string_lossy();

                let mut cloud_options =
                    parse_cloud_options(&first_path_url, cloud_options.unwrap_or_default())?;
                cloud_options = cloud_options.with_max_retries(retries);

                if let Some(file_cache_ttl) = file_cache_ttl {
                    cloud_options.file_cache_ttl = file_cache_ttl;
                }

                r = r.with_cloud_options(Some(cloud_options));
            };

            let lf = r
                .with_infer_schema_length(infer_schema_length.and_then(NonZeroUsize::new))
                .with_batch_size(batch_size)
                .with_n_rows(n_rows)
                .low_memory(low_memory)
                .with_rechunk(rechunk)
                .with_schema(schema.map(Arc::new))
                .with_schema_overwrite(schema_overrides.map(Arc::new))
                .with_row_index(row_index)
                .with_ignore_errors(ignore_errors)
                .with_include_file_paths(include_file_paths.map(|x| x.into()))
                .finish()
                .map_err(RPolarsErr::from)?;

            Ok(lf.into())
        }
        #[cfg(target_arch = "wasm32")]
        {
            Err(RPolarsErr::Other(format!("Not supported in WASM")).into())
        }
    }

    fn sink_parquet(
        &self,
        target: Sexp,
        compression: &str,
        stat_min: bool,
        stat_max: bool,
        stat_distinct_count: bool,
        stat_null_count: bool,
        retries: NumericScalar,
        sync_on_close: &str,
        maintain_order: bool,
        mkdir: bool,
        compression_level: Option<NumericScalar>,
        row_group_size: Option<NumericScalar>,
        data_page_size: Option<NumericScalar>,
        storage_options: Option<StringSexp>,
        // TODO: support these arguments
        // metadata,
        // field_overwrites,
    ) -> Result<Self> {
        #[cfg(not(target_arch = "wasm32"))]
        {
            let target: RSinkTarget = target.try_into()?;

            let statistics = StatisticsOptions {
                min_value: stat_min,
                max_value: stat_max,
                null_count: stat_null_count,
                distinct_count: stat_distinct_count,
            };
            let compression_level: Option<i32> = match compression_level {
                Some(x) => Some(x.as_i32()?),
                None => None,
            };
            let compression = parse_parquet_compression(compression, compression_level)?;
            let row_group_size: Option<usize> = match row_group_size {
                Some(x) => Some(<Wrap<usize>>::try_from(x)?.0),
                None => None,
            };
            let data_page_size: Option<usize> = match data_page_size {
                Some(x) => Some(<Wrap<usize>>::try_from(x)?.0),
                None => None,
            };
            let retries = <Wrap<usize>>::try_from(retries)?.0;

            let options = ParquetWriteOptions {
                compression,
                statistics,
                row_group_size,
                data_page_size,
                key_value_metadata: None,
                field_overwrites: vec![],
            };
            let cloud_options = match storage_options {
                Some(x) => {
                    let out = <Wrap<Vec<(String, String)>>>::try_from(x).map_err(|_| {
                        RPolarsErr::Other(
                            "`storage_options` must be a named character vector".to_string(),
                        )
                    })?;
                    Some(out.0)
                }
                None => None,
            };
            let cloud_options = match target.base_path() {
                None => None,
                Some(base_path) => {
                    let cloud_options = parse_cloud_options(
                        base_path.to_str().unwrap(),
                        cloud_options.unwrap_or_default(),
                    )?;
                    Some(cloud_options.with_max_retries(retries))
                }
            };
            let sync_on_close = <Wrap<SyncOnCloseType>>::try_from(sync_on_close)?.0;
            let sink_options = SinkOptions {
                sync_on_close,
                maintain_order,
                mkdir,
            };

            ({
                let ldf = self.ldf.clone();
                match target {
                    RSinkTarget::File(target) => {
                        ldf.sink_parquet(target, options, cloud_options, sink_options)
                    }
                    RSinkTarget::Partition(partition) => ldf.sink_parquet_partitioned(
                        Arc::new(partition.base_path),
                        None,
                        partition.variant,
                        options,
                        cloud_options,
                        sink_options,
                        partition.per_partition_sort_by,
                        None,
                    ),
                }
            })
            .map(Into::into)
            .map_err(RPolarsErr::from)
            .map_err(Into::into)
        }
        #[cfg(target_arch = "wasm32")]
        {
            Err(RPolarsErr::Other(format!("Not supported in WASM")).into())
        }
    }

    fn sink_csv(
        &self,
        target: Sexp,
        include_bom: bool,
        include_header: bool,
        separator: &str,
        line_terminator: &str,
        quote_char: &str,
        batch_size: NumericScalar,
        retries: NumericScalar,
        sync_on_close: &str,
        maintain_order: bool,
        mkdir: bool,
        datetime_format: Option<&str>,
        date_format: Option<&str>,
        time_format: Option<&str>,
        float_scientific: Option<bool>,
        float_precision: Option<NumericScalar>,
        null_value: Option<&str>,
        quote_style: Option<&str>,
        storage_options: Option<StringSexp>,
    ) -> Result<Self> {
        #[cfg(not(target_arch = "wasm32"))]
        {
            let target: RSinkTarget = target.try_into()?;

            let quote_style = match quote_style {
                Some(x) => <Wrap<QuoteStyle>>::try_from(x)?.0,
                None => QuoteStyle::default(),
            };
            let retries = <Wrap<usize>>::try_from(retries)?.0;
            let null_value = null_value
                .map(|x| x.to_string())
                .unwrap_or(SerializeOptions::default().null);
            let batch_size = <Wrap<NonZeroUsize>>::try_from(batch_size)?.0;
            let float_precision = match float_precision {
                Some(x) => Some(<Wrap<usize>>::try_from(x)?.0),
                None => None,
            };
            let separator = <Wrap<u8>>::try_from(separator)?.0;
            let quote_char = <Wrap<u8>>::try_from(quote_char)?.0;

            let serialize_options = SerializeOptions {
                date_format: date_format.map(|x| x.to_string()),
                time_format: time_format.map(|x| x.to_string()),
                datetime_format: datetime_format.map(|x| x.to_string()),
                float_scientific,
                float_precision,
                separator,
                quote_char,
                null: null_value.to_string(),
                line_terminator: line_terminator.to_string(),
                quote_style,
            };

            let options = CsvWriterOptions {
                include_bom,
                include_header,
                batch_size,
                serialize_options,
            };
            let cloud_options = match storage_options {
                Some(x) => {
                    let out = <Wrap<Vec<(String, String)>>>::try_from(x).map_err(|_| {
                        RPolarsErr::Other(
                            "`storage_options` must be a named character vector".to_string(),
                        )
                    })?;
                    Some(out.0)
                }
                None => None,
            };
            let cloud_options = match target.base_path() {
                None => None,
                Some(base_path) => {
                    let cloud_options = parse_cloud_options(
                        base_path.to_str().unwrap(),
                        cloud_options.unwrap_or_default(),
                    )?;
                    Some(cloud_options.with_max_retries(retries))
                }
            };
            let sync_on_close = <Wrap<SyncOnCloseType>>::try_from(sync_on_close)?.0;
            let sink_options = SinkOptions {
                sync_on_close,
                maintain_order,
                mkdir,
            };

            ({
                let ldf = self.ldf.clone();
                match target {
                    RSinkTarget::File(target) => {
                        ldf.sink_csv(target, options, cloud_options, sink_options)
                    }
                    RSinkTarget::Partition(partition) => ldf.sink_csv_partitioned(
                        Arc::new(partition.base_path),
                        None,
                        partition.variant,
                        options,
                        cloud_options,
                        sink_options,
                        partition.per_partition_sort_by,
                        None,
                    ),
                }
            })
            .map(Into::into)
            .map_err(RPolarsErr::from)
            .map_err(Into::into)
        }
        #[cfg(target_arch = "wasm32")]
        {
            Err(RPolarsErr::Other(format!("Not supported in WASM")).into())
        }
    }

    fn sink_json(
        &self,
        target: Sexp,
        retries: NumericScalar,
        sync_on_close: &str,
        maintain_order: bool,
        mkdir: bool,
        storage_options: Option<StringSexp>,
    ) -> Result<Self> {
        #[cfg(not(target_arch = "wasm32"))]
        {
            let target: RSinkTarget = target.try_into()?;

            let options = JsonWriterOptions {};
            let retries = <Wrap<usize>>::try_from(retries)?.0;

            let cloud_options = match storage_options {
                Some(x) => {
                    let out = <Wrap<Vec<(String, String)>>>::try_from(x).map_err(|_| {
                        RPolarsErr::Other(
                            "`storage_options` must be a named character vector".to_string(),
                        )
                    })?;
                    Some(out.0)
                }
                None => None,
            };
            let cloud_options = match target.base_path() {
                None => None,
                Some(base_path) => {
                    let cloud_options = parse_cloud_options(
                        base_path.to_str().unwrap(),
                        cloud_options.unwrap_or_default(),
                    )?;
                    Some(cloud_options.with_max_retries(retries))
                }
            };
            let sync_on_close = <Wrap<SyncOnCloseType>>::try_from(sync_on_close)?.0;
            let sink_options = SinkOptions {
                sync_on_close,
                maintain_order,
                mkdir,
            };

            ({
                let ldf = self.ldf.clone();
                match target {
                    RSinkTarget::File(target) => {
                        ldf.sink_json(target, options, cloud_options, sink_options)
                    }
                    RSinkTarget::Partition(partition) => ldf.sink_json_partitioned(
                        Arc::new(partition.base_path),
                        None,
                        partition.variant,
                        options,
                        cloud_options,
                        sink_options,
                        partition.per_partition_sort_by,
                        None,
                    ),
                }
            })
            .map(Into::into)
            .map_err(RPolarsErr::from)
            .map_err(Into::into)
        }
        #[cfg(target_arch = "wasm32")]
        {
            Err(RPolarsErr::Other(format!("Not supported in WASM")).into())
        }
    }

    fn sink_ipc(
        &self,
        target: Sexp,
        compression: &str,
        compat_level: Sexp,
        retries: NumericScalar,
        sync_on_close: &str,
        maintain_order: bool,
        mkdir: bool,
        storage_options: Option<StringSexp>,
    ) -> Result<Self> {
        #[cfg(not(target_arch = "wasm32"))]
        {
            let target: RSinkTarget = target.try_into()?;

            let retries = <Wrap<usize>>::try_from(retries)?.0;
            let compression: Option<IpcCompression> =
                <Wrap<Option<IpcCompression>>>::try_from(compression)?.0;
            let compat_level = <Wrap<CompatLevel>>::try_from(compat_level)?.0;
            let options = IpcWriterOptions {
                compression,
                compat_level,
                ..Default::default()
            };

            let cloud_options = match storage_options {
                Some(x) => {
                    let out = <Wrap<Vec<(String, String)>>>::try_from(x).map_err(|_| {
                        RPolarsErr::Other(
                            "`storage_options` must be a named character vector".to_string(),
                        )
                    })?;
                    Some(out.0)
                }
                None => None,
            };
            let cloud_options = match target.base_path() {
                None => None,
                Some(base_path) => {
                    let cloud_options = parse_cloud_options(
                        base_path.to_str().unwrap(),
                        cloud_options.unwrap_or_default(),
                    )?;
                    Some(cloud_options.with_max_retries(retries))
                }
            };
            let sync_on_close = <Wrap<SyncOnCloseType>>::try_from(sync_on_close)?.0;
            let sink_options = SinkOptions {
                sync_on_close,
                maintain_order,
                mkdir,
            };

            ({
                let ldf = self.ldf.clone();
                match target {
                    RSinkTarget::File(target) => {
                        ldf.sink_ipc(target, options, cloud_options, sink_options)
                    }
                    RSinkTarget::Partition(partition) => ldf.sink_ipc_partitioned(
                        Arc::new(partition.base_path),
                        None,
                        partition.variant,
                        options,
                        cloud_options,
                        sink_options,
                        partition.per_partition_sort_by,
                        None,
                    ),
                }
            })
            .map(Into::into)
            .map_err(RPolarsErr::from)
            .map_err(Into::into)
        }
        #[cfg(target_arch = "wasm32")]
        {
            Err(RPolarsErr::Other(format!("Not supported in WASM")).into())
        }
    }
}
