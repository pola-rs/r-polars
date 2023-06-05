use crate::lazy::dataframe::LazyFrame as RLazyFrame;
use crate::ranyhow::{ranyhow, Context, Result};
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
) -> Result<RLazyFrame> {
    let args = ScanArgsIpc {
        n_rows: robj_to!(Option, usize, n_rows).map_err(|msg| ranyhow!(msg))?,
        cache: robj_to!(bool, cache).map_err(|msg| ranyhow!(msg))?,
        rechunk: robj_to!(bool, rechunk).map_err(|msg| ranyhow!(msg))?,
        row_count: robj_to!(Option, String, row_name)
            .map_err(|msg| ranyhow!(msg))?
            .map(|name| robj_to!(u32, row_count).map(|offset| RowCount { name, offset }))
            .transpose()
            .map_err(|msg| ranyhow!(msg))?,
        memmap: robj_to!(bool, memmap).map_err(|msg| ranyhow!(msg))?,
    };
    let lf = LazyFrame::scan_ipc(robj_to!(String, path).map_err(|msg| ranyhow!(msg))?, args)
        .context("Pola-rs internal import for Arrow")?;
    Ok(RLazyFrame(lf))
}

extendr_module! {
    mod read_ipc;
    fn import_arrow_ipc;
}
