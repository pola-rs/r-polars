use crate::utils::r_result_list;

use crate::rlazyframe::LazyFrame;

//use crate::utils::wrappers::*;
use crate::utils::wrappers::null_to_opt;
use extendr_api::{extendr, prelude::*};
use polars::prelude::{self as pl};
//this function is derived from  polars/py-polars/src/lazy/DataFrame.rs new_from_csv

#[extendr]
pub fn new_from_parquet(
    path: String,
    n_rows: Nullable<i32>,
    cache: bool,
    parallel: String, //Wrap<ParallelStrategy>,
    rechunk: bool,
    row_name: Nullable<String>,
    row_count: u32,
    low_memory: bool,
) -> List {
    let parallel_strategy = match parallel {
        x if x == "Auto" => pl::ParallelStrategy::Auto,
        _ => panic!("not implemented"),
    };

    let row_name = null_to_opt(row_name);

    let row_count = row_name.map(|name| polars::io::RowCount {
        name,
        offset: row_count,
    });
    let n_rows = null_to_opt(n_rows);

    let args = pl::ScanArgsParquet {
        n_rows: n_rows.map(|x| x as usize),
        cache,
        parallel: parallel_strategy,
        rechunk,
        row_count,
        low_memory,
    };

    let lf_result = pl::LazyFrame::scan_parquet(path, args)
        .map_err(|x| x.to_string())
        .map(|lf| LazyFrame(lf));
    r_result_list(lf_result)
}

extendr_module! {
    mod read_parquet;
    fn new_from_parquet;
}
