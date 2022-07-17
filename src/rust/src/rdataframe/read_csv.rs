//read csv

use super::wrap_errors::wrap_error;

use crate::datatype::{Rdatatype, Rdatatype_vector};
use crate::utils::wrappers::Wrap;
use extendr_api::HashMap;
use extendr_api::{extendr, prelude::*, rprintln, Deref, DerefMut, Rinternals};
use polars::datatypes::DataType;
use polars::datatypes::Field;
use polars::error::PolarsError;
use polars::io::csv::{CsvEncoding, NullValues};
use polars::io::RowCount;
use polars::lazy::frame::{AllowedOptimizations, LazyCsvReader, LazyFrame, LazyGroupBy};
use polars::prelude::IdxSize;
use polars::prelude::Schema;

//this function is derived from  polars/py-polars/src/lazy/dataframe.rs new_from_csv

#[extendr]
pub fn new_csv_r(
    path: String,
    sep: &str,
    has_header: bool,
    ignore_errors: bool,
    skip_rows: u32,        //usize
    n_rows: Nullable<u32>, //option usize
    cache: bool,
    overwrite_dtype: &Rdatatype_vector, //Option<Vec<(&str, Wrap<DataType>)>>, alias None/Null
                                        // low_memory: bool,
                                        // comment_char: Option<&str>,
                                        // quote_char: Option<&str>,
                                        // null_values: Option<Wrap<NullValues>>,
                                        // infer_schema_length: Option<usize>,
                                        // // with_schema_modify: Option<PyObject>,
                                        // rechunk: bool,
                                        // skip_rows_after_header: usize,
                                        // encoding: &str,
                                        // row_count: Option<(String, IdxSize)>, //replaced IdxSize with usize
                                        // parse_dates: bool,
) {
    let s = format!(
        "path{path},sep{sep},has_header{has_header},ignore_errors{ignore_errors},skip_rows \
        {skip_rows}n_rows{:?},cache{cache},overwrite_dtype{:?}",
        n_rows, overwrite_dtype
    );
    rprintln!("{}", s);
}

// #[allow(clippy::too_many_arguments)]
// pub fn new_from_csv_lazy(
//     path: String,
//     sep: &str,
//     has_header: bool,
//     ignore_errors: bool,
//     skip_rows: usize,
//     n_rows: Option<usize>,
//     cache: bool,
//     overwrite_dtype: Option<Vec<(&str, Wrap<DataType>)>>,
//     low_memory: bool,
//     comment_char: Option<&str>,
//     quote_char: Option<&str>,
//     null_values: Option<Wrap<NullValues>>,
//     infer_schema_length: Option<usize>,
//     // with_schema_modify: Option<PyObject>,
//     rechunk: bool,
//     skip_rows_after_header: usize,
//     encoding: &str,
//     row_count: Option<(String, IdxSize)>, //replaced IdxSize with usize
//     parse_dates: bool,
// ) -> Result<LazyFrame> {
//     let r = R!("NULL")?;
//     let n1 = <Nullable<i32>>::from_robj(&r)?;
//     let o1: Option<i32> = Wrap(n1).into();
//     if let extendr_api::wrapper::nullable::Nullable::NotNull(x) = n1 {}

//     let null_values = null_values.map(|w| w.0);
//     let comment_char = comment_char.map(|s| s.as_bytes()[0]);
//     let quote_char = quote_char.map(|s| s.as_bytes()[0]);
//     let delimiter = sep.as_bytes()[0];

//     let row_count = row_count.map(|(name, offset)| RowCount { name, offset });

//     let encoding = match encoding {
//         "utf8" => CsvEncoding::Utf8,
//         "utf8-lossy" => CsvEncoding::LossyUtf8,
//         e => return Err(Error::Other(format!("encoding not {} not implemented.", e)).into()),
//     };

//     let overwrite_dtype = overwrite_dtype.map(|overwrite_dtype| {
//         let fields = overwrite_dtype
//             .into_iter()
//             .map(|(name, dtype)| Field::new(name, dtype.0));
//         Schema::from(fields)
//     });
//     let r = LazyCsvReader::new(path)
//         .with_infer_schema_length(infer_schema_length)
//         .with_delimiter(delimiter)
//         .has_header(has_header)
//         .with_ignore_parser_errors(ignore_errors)
//         .with_skip_rows(skip_rows)
//         .with_n_rows(n_rows)
//         .with_cache(cache)
//         .with_dtype_overwrite(overwrite_dtype.as_ref())
//         .low_memory(low_memory)
//         .with_comment_char(comment_char)
//         .with_quote_char(quote_char)
//         .with_rechunk(rechunk)
//         .with_skip_rows_after_header(skip_rows_after_header)
//         .with_encoding(encoding)
//         .with_row_count(row_count)
//         .with_parse_dates(parse_dates)
//         .with_null_values(null_values);

//     let x = r.finish().map_err(wrap_error)?;

//     Ok(x)
// }

extendr_module! {
    mod read_csv;
    fn new_csv_r;
}
