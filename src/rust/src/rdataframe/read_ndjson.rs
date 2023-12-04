//read ndjson

use crate::lazy::dataframe::RPolarsLazyFrame;
use crate::robj_to;
use crate::rpolarserr::*;
use polars::io::RowCount;

//use crate::utils::wrappers::*;
use extendr_api::{extendr, prelude::*, Rinternals};
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
    row_count_name: Robj,
    row_count_offset: Robj,
) -> RResult<RPolarsLazyFrame> {
    let offset = robj_to!(Option, u32, row_count_offset)?.unwrap_or(0);
    let opt_rowcount =
        robj_to!(Option, String, row_count_name)?.map(|name| RowCount { name, offset });

    let vec_pathbuf = robj_to!(Vec, PathBuf, path)?;
    let linereader = match vec_pathbuf.len() {
        2.. => Ok(pl::LazyJsonLineReader::new_paths(vec_pathbuf.into())),
        1 => Ok(pl::LazyJsonLineReader::new(&vec_pathbuf[0])),
        _ => rerr().plain("path cannot have zero length").bad_arg("path"),
    }?;

    linereader
        .with_infer_schema_length(robj_to!(Option, usize, infer_schema_length)?)
        .with_batch_size(robj_to!(Option, usize, batch_size)?)
        .with_n_rows(robj_to!(Option, usize, n_rows)?)
        .low_memory(robj_to!(bool, low_memory)?)
        .with_row_count(opt_rowcount)
        .with_rechunk(robj_to!(bool, rechunk)?)
        .finish()
        .map_err(polars_to_rpolars_err)
        .map(RPolarsLazyFrame)
}

extendr_module! {
    mod read_ndjson;
    fn new_from_ndjson;
}
