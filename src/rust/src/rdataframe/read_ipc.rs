use crate::lazy::dataframe::RPolarsLazyFrame as RLazyFrame;
use crate::robj_to;
use crate::rpolarserr::RResult;
use extendr_api::prelude::*;
use polars::io::RowIndex;
use polars::prelude::{LazyFrame, ScanArgsIpc};

#[extendr]
pub fn import_arrow_ipc(
    path: Robj,
    n_rows: Robj,
    cache: Robj,
    rechunk: Robj,
    row_name: Robj,
    row_index: Robj,
    memory_map: Robj,
) -> RResult<RLazyFrame> {
    let args = ScanArgsIpc {
        n_rows: robj_to!(Option, usize, n_rows)?,
        cache: robj_to!(bool, cache)?,
        rechunk: robj_to!(bool, rechunk)?,
        row_index: robj_to!(Option, String, row_name)?
            .map(|name| robj_to!(u32, row_index).map(|offset| RowIndex { name, offset }))
            .transpose()?,
        memory_map: robj_to!(bool, memory_map)?,
        cloud_options: None,
    };
    let lf = LazyFrame::scan_ipc(robj_to!(String, path)?, args)
        .map_err(crate::rpolarserr::polars_to_rpolars_err)?;
    Ok(RLazyFrame(lf))
}

extendr_module! {
    mod read_ipc;
    fn import_arrow_ipc;
}
