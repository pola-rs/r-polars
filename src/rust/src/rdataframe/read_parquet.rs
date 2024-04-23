use crate::lazy::dataframe::RPolarsLazyFrame;
use crate::rdatatype::robj_to_cloudoptions;
use crate::robj_to;
use crate::rpolarserr::{polars_to_rpolars_err, RResult};

use extendr_api::Rinternals;
use extendr_api::{extendr, extendr_module, Robj};
use polars::io::RowIndex;
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
    row_index: Robj,
    //storage_options: Robj, // not supported yet, add provide features e.g. aws
    cloud_options: Robj,
    use_statistics: Robj,
    low_memory: Robj,
    hive_partitioning: Robj,
    //retries: Robj // not supported yet, with CloudOptions
) -> RResult<RPolarsLazyFrame> {
    let path = robj_to!(String, path)?;
    let cloud_options = robj_to_cloudoptions(&path, &cloud_options)?;
    let offset = robj_to!(Option, u32, row_index)?.unwrap_or(0);
    let opt_row_index = robj_to!(Option, String, row_name)?.map(|name| RowIndex { name, offset });
    let args = pl::ScanArgsParquet {
        n_rows: robj_to!(Option, usize, n_rows)?,
        cache: robj_to!(bool, cache)?,
        parallel: robj_to!(ParallelStrategy, parallel)?,
        rechunk: robj_to!(bool, rechunk)?,
        row_index: opt_row_index,
        low_memory: robj_to!(bool, low_memory)?,
        cloud_options,
        use_statistics: robj_to!(bool, use_statistics)?,
        hive_options: polars::io::HiveOptions {
            enabled: robj_to!(bool, hive_partitioning)?,
            schema: None, // TODO: implement a option to set this
        },
    };

    pl::LazyFrame::scan_parquet(path, args)
        .map_err(polars_to_rpolars_err)
        .map(RPolarsLazyFrame)
}

extendr_module! {
    mod read_parquet;
    fn new_from_parquet;
}
