use crate::lazy::dataframe::LazyFrame as RLazyFrame;
use crate::utils::r_result_list;
use crate::utils::wrappers::null_to_opt;
use extendr_api::{extendr, prelude::*};
use polars::io::RowCount;
use polars::prelude::*;

#[extendr]
pub fn new_from_ipc(
    path: String,
    n_rows: Nullable<i64>,
    cache: bool,
    rechunk: bool,
    row_name: Nullable<String>,
    row_count: i64,
    memmap: bool,
) -> List {
    let args = ScanArgsIpc {
        n_rows: null_to_opt(n_rows).and_then(|n| usize::try_from(n).ok()),
        cache,
        rechunk,
        row_count: u32::try_from(row_count)
            .ok()
            .and_then(|rc| null_to_opt(row_name).map(|name| RowCount { name, offset: rc })),
        memmap,
    };
    r_result_list(
        LazyFrame::scan_ipc(path, args)
            .map_err(|x| x.to_string())
            .map(|lf| RLazyFrame(lf)),
    )
}

extendr_module! {
    mod read_ipc;
    fn new_from_ipc;
}
