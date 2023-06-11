use crate::lazy::dataframe::LazyFrame as RLazyFrame;
use crate::rerr::RResult;
use crate::robj_to;
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
) -> RResult<RLazyFrame> {
    let args = ScanArgsIpc {
        n_rows: robj_to!(Option, usize, n_rows)?,
        cache: robj_to!(bool, cache)?,
        rechunk: robj_to!(bool, rechunk)?,
        row_count: robj_to!(Option, String, row_name)?
            .map(|name| robj_to!(u32, row_count).map(|offset| RowCount { name, offset }))
            .transpose()?,
        memmap: robj_to!(bool, memmap)?,
    };
    let lf = LazyFrame::scan_ipc(robj_to!(String, path)?, args)?;
    Ok(RLazyFrame(lf))
}

extendr_module! {
    mod read_ipc;
    fn import_arrow_ipc;
}
