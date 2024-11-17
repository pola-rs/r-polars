use crate::lazy::dataframe::RPolarsLazyFrame;
use crate::rdatatype::robj_to_cloud_options;
use crate::robj_to;
use crate::rpolarserr::{polars_to_rpolars_err, RResult};

use extendr_api::Rinternals;
use extendr_api::{extendr, extendr_module, Robj};
use polars::io::{HiveOptions, RowIndex};
use polars::prelude::{self as pl, Arc};

#[allow(clippy::too_many_arguments)]
#[extendr]
pub fn new_from_parquet(
    path: Robj,
    n_rows: Robj,
    cache: Robj,
    parallel: Robj,
    rechunk: Robj,
    row_name: Robj,
    row_index: Robj,
    storage_options: Robj,
    use_statistics: Robj,
    low_memory: Robj,
    hive_partitioning: Robj,
    schema: Robj,
    hive_schema: Robj,
    try_parse_hive_dates: Robj,
    glob: Robj,
    include_file_paths: Robj,
    allow_missing_columns: Robj,
    //retries: Robj // not supported yet, with CloudOptions
) -> RResult<RPolarsLazyFrame> {
    let path = robj_to!(String, path)?;
    let cloud_options = robj_to_cloud_options(&path, &storage_options)?;
    let offset = robj_to!(Option, u32, row_index)?.unwrap_or(0);
    let opt_row_index = robj_to!(Option, String, row_name)?.map(|name| RowIndex {
        name: name.into(),
        offset,
    });
    let hive_options = HiveOptions {
        enabled: robj_to!(Option, bool, hive_partitioning)?,
        hive_start_idx: 0,
        schema: robj_to!(Option, WrapSchema, hive_schema)?.map(|x| Arc::new(x.0)),
        try_parse_dates: robj_to!(bool, try_parse_hive_dates)?,
    };
    let schema = robj_to!(Option, WrapSchema, schema)?;
    let allow_missing_columns = robj_to!(bool, allow_missing_columns)?;
    let args = pl::ScanArgsParquet {
        n_rows: robj_to!(Option, usize, n_rows)?,
        cache: robj_to!(bool, cache)?,
        parallel: robj_to!(ParallelStrategy, parallel)?,
        rechunk: robj_to!(bool, rechunk)?,
        row_index: opt_row_index,
        low_memory: robj_to!(bool, low_memory)?,
        cloud_options,
        use_statistics: robj_to!(bool, use_statistics)?,
        schema: schema.map(|x| Arc::new(x.0)),
        hive_options,
        glob: robj_to!(bool, glob)?,
        include_file_paths: robj_to!(Option, String, include_file_paths)?.map(|x| x.into()),
        allow_missing_columns,
    };

    pl::LazyFrame::scan_parquet(path, args)
        .map_err(polars_to_rpolars_err)
        .map(RPolarsLazyFrame)
}

extendr_module! {
    mod read_parquet;
    fn new_from_parquet;
}
