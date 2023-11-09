use crate::lazy::dataframe::LazyFrame;
use crate::robj_to;
use crate::rpolarserr::{polars_to_rpolars_err, RResult};

use extendr_api::Rinternals;
use extendr_api::{extendr, extendr_module, Robj};
use polars::io::RowCount;
use polars::prelude::{self as pl};
#[allow(clippy::too_many_arguments)]
#[extendr]
pub fn new_from_parquet(
    path: Robj,
    n_rows: Robj,
    cache: Robj,
    parallel: Robj,
    rechunk: Robj,
    row_name: Robj,
    row_count: Robj,
    low_memory: Robj,
    hive_partitioning: Robj,
) -> RResult<LazyFrame> {
    let offset = robj_to!(Option, u32, row_count)?.unwrap_or(0);
    let opt_rowcount = robj_to!(Option, String, row_name)?.map(|name| RowCount { name, offset });
    let args = pl::ScanArgsParquet {
        n_rows: robj_to!(Option, usize, n_rows)?,
        cache: robj_to!(bool, cache)?,
        parallel: robj_to!(ParallelStrategy, parallel)?,
        rechunk: robj_to!(bool, rechunk)?,
        row_count: opt_rowcount,
        low_memory: robj_to!(bool, low_memory)?,
        cloud_options: None,  //TODO implement cloud options
        use_statistics: true, //TODO expose use statistics
        hive_partitioning: robj_to!(bool, hive_partitioning)?,
    };

    pl::LazyFrame::scan_parquet(robj_to!(String, path)?, args)
        .map_err(polars_to_rpolars_err)
        .map(LazyFrame)
}

extendr_module! {
    mod read_parquet;
    fn new_from_parquet;
}
