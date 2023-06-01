use crate::lazy::dataframe::LazyFrame as RLazyFrame;
use crate::{robj_to, Error::Other, Result};
use extendr_api::prelude::*;
use polars::io::RowCount;
use polars::prelude::{LazyFrame, ScanArgsIpc};

#[extendr]
pub fn import_arrow_ipc(
    path: Robj,
    n_rows: Robj,
    cache: Robj,
    rechunk: Robj,
    row_name: Robj,
    row_count: Robj,
    memmap: Robj,
) -> Result<RLazyFrame> {
    let args = ScanArgsIpc {
        n_rows: robj_to!(Option, usize, n_rows)?,
        cache: robj_to!(bool, cache)?,
        rechunk: robj_to!(bool, rechunk)?,
        row_count: robj_to!(Option, String, row_name)?
            .map(|name| robj_to!(u32, row_count).map(|offset| RowCount { name, offset }))
            .transpose()?,
        memmap: robj_to!(bool, memmap)?,
    };
    LazyFrame::scan_ipc(robj_to!(String, path)?, args)
        .map_err(|x| Other(format!("Polaris internal error: {x}")))
        .map(RLazyFrame)
}

extendr_module! {
    mod read_ipc;
    fn import_arrow_ipc;
}
