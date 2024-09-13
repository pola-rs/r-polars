use crate::lazy::dataframe::RPolarsLazyFrame;
use crate::robj_to;
use crate::rpolarserr::RResult;
use extendr_api::prelude::*;
use polars::io::{HiveOptions, RowIndex};
use polars::prelude::{Arc, LazyFrame, ScanArgsIpc};

#[extendr]
pub fn import_arrow_ipc(
    path: Robj,
    n_rows: Robj,
    cache: Robj,
    rechunk: Robj,
    row_name: Robj,
    row_index: Robj,
    hive_partitioning: Robj,
    hive_schema: Robj,
    try_parse_hive_dates: Robj,
    include_file_paths: Robj,
) -> RResult<RPolarsLazyFrame> {
    let hive_options = HiveOptions {
        enabled: robj_to!(Option, bool, hive_partitioning)?,
        hive_start_idx: 0,
        schema: robj_to!(Option, WrapSchema, hive_schema)?.map(|x| Arc::new(x.0)),
        try_parse_dates: robj_to!(bool, try_parse_hive_dates)?,
    };

    let args = ScanArgsIpc {
        n_rows: robj_to!(Option, usize, n_rows)?,
        cache: robj_to!(bool, cache)?,
        rechunk: robj_to!(bool, rechunk)?,
        row_index: robj_to!(Option, String, row_name)?
            .map(|name| {
                robj_to!(u32, row_index).map(|offset| RowIndex {
                    name: name.into(),
                    offset,
                })
            })
            .transpose()?,
        cloud_options: None,
        hive_options,
        include_file_paths: robj_to!(Option, String, include_file_paths)?.map(|x| x.into()),
    };
    let lf = LazyFrame::scan_ipc(robj_to!(String, path)?, args)
        .map_err(crate::rpolarserr::polars_to_rpolars_err)?;
    Ok(RPolarsLazyFrame(lf))
}

extendr_module! {
    mod read_ipc;
    fn import_arrow_ipc;
}
