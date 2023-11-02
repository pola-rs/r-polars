//read csv

use crate::rdatatype::DataTypeVector;

use crate::lazy::dataframe::LazyFrame;
use crate::robj_to;
use crate::rpolarserr::*;
use polars::io::RowCount;
use std::path::PathBuf;

//use crate::utils::wrappers::*;
use crate::utils::wrappers::{null_to_opt, Wrap};
use extendr_api::{extendr, prelude::*, Rinternals};
use polars::prelude as pl;
use std::result::Result;

//see param, null_values
#[derive(Clone, Debug)]
pub struct RNullValues(pl::NullValues);
use polars::prelude::LazyFileListReader;

#[extendr]
impl RNullValues {
    pub fn new_all_columns(x: String) -> Self {
        RNullValues(pl::NullValues::AllColumnsSingle(x))
    }
    pub fn new_columns(x: Vec<String>) -> Self {
        RNullValues(pl::NullValues::AllColumns(x))
    }
    pub fn new_named(robj: Robj) -> Self {
        let null_markers = robj.as_str_iter().expect("must be str");
        let column_names = robj.names().expect("names were missing");

        let key_val_pair: Vec<(String, String)> = column_names
            .zip(null_markers)
            .map(|(k, v)| (k.to_owned(), v.to_owned()))
            .collect();
        RNullValues(pl::NullValues::Named(key_val_pair))
    }
}
impl From<Wrap<Nullable<&RNullValues>>> for Option<pl::NullValues> {
    fn from(x: Wrap<Nullable<&RNullValues>>) -> Self {
        null_to_opt(x.0).map(|y| y.clone().0)
    }
}

#[allow(clippy::too_many_arguments)]
#[extendr]
pub fn new_from_csv(
    path: Robj,
    paths: Robj,
    has_header: Robj,
    separator: Robj,
    comment_char: Robj,
    quote_char: Robj,
    skip_rows: Robj,
    dtypes: Nullable<&DataTypeVector>,
    null_values: Nullable<&RNullValues>,
    missing_utf8_is_empty_string: Robj,
    ignore_errors: Robj,
    cache: Robj,
    infer_schema_length: Nullable<i32>,
    n_rows: Nullable<i32>,
    encoding: &str,
    low_memory: Robj,
    rechunk: Robj,
    skip_rows_after_header: Robj,
    row_count_name: Robj,
    row_count_offset: Robj,
    try_parse_dates: Robj,
    eol_char: Robj,
    raise_if_empty: Robj,
    truncate_ragged_lines: Robj,
) -> RResult<LazyFrame> {
    let separator = robj_to!(Utf8Byte, separator)?;
    let has_header = robj_to!(bool, has_header)?;
    let ignore_errors = robj_to!(bool, ignore_errors)?;
    let quote_char = robj_to!(Option, Utf8Byte, quote_char)?;
    let comment_char = robj_to!(Option, Utf8Byte, comment_char)?;
    let eol_char = robj_to!(Utf8Byte, eol_char)?;
    let skip_rows = robj_to!(usize, skip_rows)?;
    let skip_rows_after_header = robj_to!(usize, skip_rows_after_header)?;
    let cache = robj_to!(bool, cache)?;
    let low_memory = robj_to!(bool, low_memory)?;
    let missing_utf8_is_empty_string = robj_to!(bool, missing_utf8_is_empty_string)?;
    let rechunk = robj_to!(bool, rechunk)?;
    let try_parse_dates = robj_to!(bool, try_parse_dates)?;
    let raise_if_empty = robj_to!(bool, raise_if_empty)?;
    let truncate_ragged_lines = robj_to!(bool, truncate_ragged_lines)?;

    //construct encoding parameter
    let encoding = match encoding {
        "utf8" => pl::CsvEncoding::Utf8,
        "utf8-lossy" => pl::CsvEncoding::LossyUtf8,
        e => {
            panic!("encoding {} not implemented.", e);
            // let result = Err(format!("encoding {} not implemented.", e)).unwrap();
            // return Ok(result)
            //     .map_err(polars_to_rpolars_err)
            //     .map(LazyFrame);
        }
    };

    //construct optional Schema parameter for overwrite_dtype
    let dtv = null_to_opt(dtypes).cloned();
    let schema = dtv.map(|some_od| {
        let fields = some_od.0.iter().map(|(name, dtype)| {
            if let Some(sname) = name {
                pl::Field::new(sname, dtype.clone())
            } else {
                todo!("missing column name for  dtype not implemented");
            }
        });
        pl::Schema::from_iter(fields)
    });

    //construct paths, depending on whether one or multiple paths were provided
    let path = robj_to!(Option, String, path)?;
    let r = if path.is_some() {
        let path = PathBuf::from(path.unwrap());
        pl::LazyCsvReader::new(&path)
    } else {
        let paths: Vec<PathBuf> = robj_to!(Vec, String, paths)?
            .iter()
            .map(|x| PathBuf::from(x))
            .collect();
        pl::LazyCsvReader::new_paths(paths.into())
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
        .with_infer_schema_length(null_to_opt(infer_schema_length).map(|x| x as usize))
        .with_separator(separator)
        .has_header(has_header)
        .with_ignore_errors(ignore_errors)
        .with_skip_rows(skip_rows)
        .with_n_rows(null_to_opt(n_rows).map(|x| x as usize))
        .with_cache(cache)
        .with_dtype_overwrite(schema.as_ref())
        .low_memory(low_memory)
        .with_comment_char(comment_char)
        .with_quote_char(quote_char)
        .with_end_of_line_char(eol_char)
        .with_rechunk(rechunk)
        .with_skip_rows_after_header(skip_rows_after_header)
        .with_encoding(encoding)
        .with_try_parse_dates(try_parse_dates)
        .with_null_values(Wrap(null_values).into())
        .with_missing_is_null(!missing_utf8_is_empty_string)
        .truncate_ragged_lines(truncate_ragged_lines)
        .raise_if_empty(raise_if_empty);

    r.finish().map_err(polars_to_rpolars_err).map(LazyFrame)
}

extendr_module! {
    mod read_csv;
    fn new_from_csv;
    impl RNullValues;
}
