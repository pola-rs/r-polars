//read csv

use crate::rdatatype::RPolarsDataTypeVector;

use crate::lazy::dataframe::RPolarsLazyFrame;
use crate::robj_to;
use crate::rpolarserr::*;
use polars::io::RowIndex;

//use crate::utils::wrappers::*;
use crate::utils::wrappers::{null_to_opt, Wrap};
use extendr_api::{extendr, prelude::*};
use polars::prelude as pl;
use std::result::Result;

//see param, null_values
#[derive(Clone, Debug)]
pub struct RPolarsRNullValues(pl::NullValues);

use polars::prelude::LazyFileListReader;

#[extendr]
impl RPolarsRNullValues {
    pub fn new_all_columns(x: String) -> Self {
        RPolarsRNullValues(pl::NullValues::AllColumnsSingle(x))
    }
    pub fn new_columns(x: Vec<String>) -> Self {
        RPolarsRNullValues(pl::NullValues::AllColumns(x))
    }
    pub fn new_named(robj: Robj) -> Self {
        let null_markers = robj.as_str_iter().expect("must be str");
        let column_names = robj.names().expect("names were missing");

        let key_val_pair: Vec<(String, String)> = column_names
            .zip(null_markers)
            .map(|(k, v)| (k.to_owned(), v.to_owned()))
            .collect();
        RPolarsRNullValues(pl::NullValues::Named(key_val_pair))
    }
}
impl From<Wrap<Nullable<&RPolarsRNullValues>>> for Option<pl::NullValues> {
    fn from(x: Wrap<Nullable<&RPolarsRNullValues>>) -> Self {
        null_to_opt(x.0).map(|y| y.clone().0)
    }
}

#[allow(clippy::too_many_arguments)]
#[extendr]
pub fn new_from_csv(
    path: Robj,
    has_header: Robj,
    separator: Robj,
    comment_prefix: Robj,
    quote_char: Robj,
    skip_rows: Robj,
    dtypes: Nullable<&RPolarsDataTypeVector>,
    null_values: Nullable<&RPolarsRNullValues>,
    // missing_utf8_is_empty_string: Robj,
    ignore_errors: Robj,
    cache: Robj,
    infer_schema_length: Robj,
    n_rows: Robj,
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
) -> RResult<RPolarsLazyFrame> {
    let offset = robj_to!(Option, u32, row_count_offset)?.unwrap_or(0);
    let opt_rowcount =
        robj_to!(Option, String, row_count_name)?.map(|name| RowIndex { name, offset });

    let vec_pathbuf = robj_to!(Vec, PathBuf, path)?;
    let linereader = match vec_pathbuf.len() {
        2.. => Ok(pl::LazyCsvReader::new_paths(vec_pathbuf.into())),
        1 => Ok(pl::LazyCsvReader::new(&vec_pathbuf[0])),
        _ => rerr().plain("path cannot have zero length").bad_arg("path"),
    }?;
    //construct encoding parameter
    let encoding = match encoding {
        "utf8" => Ok(pl::CsvEncoding::Utf8),
        "utf8-lossy" => Ok(pl::CsvEncoding::LossyUtf8),
        _ => rerr().bad_val(format!("encoding choice: '{}' is not supported", encoding)),
    }?;

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

    linereader
        .with_infer_schema_length(robj_to!(Option, usize, infer_schema_length)?)
        .with_separator(robj_to!(Utf8Byte, separator)?)
        .has_header(robj_to!(bool, has_header)?)
        .with_ignore_errors(robj_to!(bool, ignore_errors)?)
        .with_skip_rows(robj_to!(usize, skip_rows)?)
        .with_n_rows(robj_to!(Option, usize, n_rows)?)
        .with_cache(robj_to!(bool, cache)?)
        .with_dtype_overwrite(schema.as_ref())
        .low_memory(robj_to!(bool, low_memory)?)
        .with_comment_prefix(robj_to!(Option, str, comment_prefix)?)
        .with_quote_char(robj_to!(Option, Utf8Byte, quote_char)?)
        .with_end_of_line_char(robj_to!(Utf8Byte, eol_char)?)
        .with_rechunk(robj_to!(bool, rechunk)?)
        .with_skip_rows_after_header(robj_to!(usize, skip_rows_after_header)?)
        .with_encoding(encoding)
        .with_try_parse_dates(robj_to!(bool, try_parse_dates)?)
        .with_null_values(Wrap(null_values).into())
        // .with_missing_is_null(!robj_to!(bool, missing_utf8_is_empty_string)?)
        .with_row_index(opt_rowcount)
        .truncate_ragged_lines(robj_to!(bool, truncate_ragged_lines)?)
        .raise_if_empty(robj_to!(bool, raise_if_empty)?)
        .finish()
        .map_err(polars_to_rpolars_err)
        .map(RPolarsLazyFrame)
}

extendr_module! {
    mod read_csv;
    fn new_from_csv;
    impl RPolarsRNullValues;
}
