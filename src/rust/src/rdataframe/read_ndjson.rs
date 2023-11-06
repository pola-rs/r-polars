//read ndjson

use crate::lazy::dataframe::LazyFrame;
use crate::robj_to;
use crate::rpolarserr::*;
use polars::io::RowCount;
use std::path::PathBuf;

//use crate::utils::wrappers::*;
use extendr_api::{extendr, prelude::*, Rinternals};
use polars::prelude as pl;
use polars::prelude::LazyFileListReader;
use std::result::Result;

#[allow(clippy::too_many_arguments)]
#[extendr]
pub fn new_from_ndjson(
    path: Robj,
    paths: Robj,
    infer_schema_length: Robj,
    batch_size: Robj,
    n_rows: Robj,
    low_memory: Robj,
    rechunk: Robj,
    row_count_name: Robj,
    row_count_offset: Robj,
) -> RResult<LazyFrame> {
    let infer_schema_length = robj_to!(Option, usize, infer_schema_length)?;
    let batch_size = robj_to!(Option, usize, batch_size)?;
    let n_rows = robj_to!(Option, usize, n_rows)?;
    let low_memory = robj_to!(bool, low_memory)?;
    let rechunk = robj_to!(bool, rechunk)?;

    //construct paths, depending on whether one or multiple paths were provided
    let path = robj_to!(Option, String, path)?;
    let r = if path.is_some() {
        let path = PathBuf::from(path.unwrap());
        pl::LazyJsonLineReader::new(&path)
    } else {
        let paths: Vec<PathBuf> = robj_to!(Vec, String, paths)?
            .iter()
            .map(PathBuf::from)
            .collect();
        pl::LazyJsonLineReader::new_paths(paths.into())
    };

    //construct optional RowCount parameter
    let row_count_name = robj_to!(Option, String, row_count_name)?;
    let r = if row_count_name.is_some() {
        let row_count = Some((
            row_count_name.unwrap(),
            robj_to!(Option, u32, row_count_offset)?.unwrap_or(0),
        ))
        .map(|(name, offset)| RowCount { name, offset });

        r.with_row_count(row_count)
    } else {
        r
    };

    let r = r
        .with_infer_schema_length(infer_schema_length)
        .with_batch_size(batch_size)
        .with_n_rows(n_rows)
        .low_memory(low_memory)
        .with_rechunk(rechunk);

    r.finish().map_err(polars_to_rpolars_err).map(LazyFrame)
}

extendr_module! {
    mod read_ndjson;
    fn new_from_ndjson;
}
