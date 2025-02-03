use crate::{
    prelude::*, PlRDataFrame, PlRDataType, PlRExpr, PlRLazyFrame, PlRLazyGroupBy, RPolarsErr,
};
use polars::io::{HiveOptions, RowIndex};
use savvy::{
    savvy, ListSexp, LogicalSexp, NumericScalar, OwnedListSexp, OwnedStringSexp, Result, Sexp,
    StringSexp,
};
use std::num::NonZeroUsize;
use std::path::PathBuf;

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
        predicate_pushdown: bool,
        projection_pushdown: bool,
        simplify_expression: bool,
        slice_pushdown: bool,
        comm_subplan_elim: bool,
        comm_subexpr_elim: bool,
        cluster_with_columns: bool,
        streaming: bool,
        _eager: bool,
    ) -> Result<Self> {
        let ldf = self
            .ldf
            .clone()
            .with_type_coercion(type_coercion)
            .with_predicate_pushdown(predicate_pushdown)
            .with_simplify_expr(simplify_expression)
            .with_slice_pushdown(slice_pushdown)
            .with_comm_subplan_elim(comm_subplan_elim)
            .with_comm_subexpr_elim(comm_subexpr_elim)
            .with_cluster_with_columns(cluster_with_columns)
            .with_streaming(streaming)
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

    fn collect(&self) -> Result<PlRDataFrame> {
        use crate::{
            r_threads::{concurrent_handler, ThreadCom},
            r_udf::{RUdfReturn, RUdfSignature, CONFIG},
        };
        fn serve_r(
            udf_sig: RUdfSignature,
        ) -> std::result::Result<RUdfReturn, Box<dyn std::error::Error>> {
            udf_sig.eval()
        }

        let ldf = self.ldf.clone();

        #[cfg(not(target_arch = "wasm32"))]
        let df = if ThreadCom::try_from_global(&CONFIG).is_ok() {
            ldf.collect().map_err(RPolarsErr::from)?
        } else {
            concurrent_handler(
                // closure 1: spawned by main thread
                // tc is a ThreadCom which any child thread can use to submit R jobs to main thread
                move |tc| {
                    // get return value
                    let retval = ldf.collect();

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
                s.as_bytes()
                    .first()
                    .ok_or_else(|| polars_err!(InvalidOperation: "`quote_char` cannot be empty"))
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
                    RPolarsErr::Other("`storage_options` must be a named character vector".to_string())
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
                        RPolarsErr::Other("`storage_options` must be a named character vector".to_string())
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
                        RPolarsErr::Other("`storage_options` must be a named character vector".to_string())
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
}
