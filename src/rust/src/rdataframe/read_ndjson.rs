//read ndjson

use crate::lazy::dataframe::RPolarsLazyFrame;
use crate::robj_to;
use crate::rpolarserr::*;
use polars::io::RowIndex;

//use crate::utils::wrappers::*;
use extendr_api::{extendr, prelude::*};
use polars::prelude as pl;
use polars::prelude::LazyFileListReader;
use std::result::Result;

#[allow(clippy::too_many_arguments)]
#[extendr]
pub fn new_from_ndjson(
    path: Robj,
    infer_schema_length: Robj,
    batch_size: Robj,
    n_rows: Robj,
    low_memory: Robj,
    rechunk: Robj,
    row_index_name: Robj,
    row_index_offset: Robj,
    ignore_errors: Robj,
) -> RResult<RPolarsLazyFrame> {
    let offset = robj_to!(Option, u32, row_index_offset)?.unwrap_or(0);
    let opt_rowindex =
        robj_to!(Option, String, row_index_name)?.map(|name| RowIndex { name, offset });

    let vec_pathbuf = robj_to!(Vec, PathBuf, path)?;
    let linereader = match vec_pathbuf.len() {
        2.. => Ok(pl::LazyJsonLineReader::new_paths(vec_pathbuf.into())),
        1 => Ok(pl::LazyJsonLineReader::new(&vec_pathbuf[0])),
        _ => rerr().plain("path cannot have zero length").bad_arg("path"),
    }?;

    linereader
        .with_infer_schema_length(robj_to!(Option, usize, infer_schema_length)?)
        .with_batch_size(robj_to!(Option, nonzero_usize, batch_size)?)
        .with_n_rows(robj_to!(Option, usize, n_rows)?)
        .low_memory(robj_to!(bool, low_memory)?)
        .with_row_index(opt_rowindex)
        .with_rechunk(robj_to!(bool, rechunk)?)
        .with_ignore_errors(robj_to!(bool, ignore_errors)?)
        .finish()
        .map_err(polars_to_rpolars_err)
        .map(RPolarsLazyFrame)
}

extendr_module! {
    mod read_ndjson;
    fn new_from_ndjson;
}
