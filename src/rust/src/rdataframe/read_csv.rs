//read csv

use crate::rdataframe::wrap_errors::wrap_error;
use crate::rdatatype::RdatatypeVector;
use crate::utils::wrappers::*;
use extendr_api::{extendr, prelude::*, rprintln, Error, Rinternals};
use polars::prelude as pl;
//this function is derived from  polars/py-polars/src/lazy/dataframe.rs new_from_csv
use std::result::Result;

use crate::rdataframe::Rdataframe;
//see param, null_values
#[derive(Clone, Debug)]
#[extendr]
pub struct RNullValues(pl::NullValues);

#[extendr]
impl RNullValues {
    pub fn new_all_columns(x: String) -> Self {
        RNullValues(pl::NullValues::AllColumns(x))
    }
    pub fn new_columns(x: Vec<String>) -> Self {
        RNullValues(pl::NullValues::Columns(x))
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

#[derive(Clone)]
#[extendr]
pub struct Rlazyframe(pl::LazyFrame);

#[extendr]
impl Rlazyframe {
    pub fn rprint(&self) {
        rprintln!("{}", self.0.describe_plan());
    }

    pub fn collect(&self) -> Result<Rdataframe, Error> {
        let x = self.clone().0.collect().map_err(wrap_error)?;
        Ok(Rdataframe(x))
    }
}

#[extendr]
pub fn new_csv_r(
    path: String,
    sep: &str,
    has_header: bool,
    ignore_errors: bool,
    skip_rows: i32,        //usize
    n_rows: Nullable<i32>, //option usize
    cache: bool,
    overwrite_dtype: Nullable<&RdatatypeVector>, //Option<Vec<(&str, Wrap<DataType>)>>, alias None/Null
    low_memory: bool,
    comment_char: Nullable<&str>,
    quote_char: Nullable<&str>,
    null_values: Nullable<&RNullValues>,
    infer_schema_length: Nullable<i32>,
    //with_schema_modify: Option<PyObject>,
    rechunk: bool,
    skip_rows_after_header: i32,
    encoding: &str,
    row_count_name: Nullable<String>,
    row_count_offset: i32, //replaced IdxSize with usize
    parse_dates: bool,
) -> Result<Rlazyframe, Error> {
    let s = format!(
        "path{path},sep{sep},has_header{has_header},ignore_errors{ignore_errors},skip_rows \
        {skip_rows}n_rows{:?},cache{cache},overwrite_dtype{:?}",
        n_rows, overwrite_dtype
    );
    rprintln!("{}", s);

    let encoding = match encoding {
        "utf8" => pl::CsvEncoding::Utf8,
        "utf8-lossy" => pl::CsvEncoding::LossyUtf8,
        e => return Err(Error::Other(format!("encoding {} not implemented.", e))),
    };

    let dtv = null_to_opt(overwrite_dtype).map(|x| x.clone());

    let schema = dtv.map(|some_od| {
        let fields = some_od.0.iter().map(|(name, dtype)| {
            if let Some(sname) = name {
                pl::Field::new(sname, dtype.clone())
            } else {
                todo!("missing column name for  dtype not implented");
            }
        });
        pl::Schema::from(fields)
    });

    let row_count = null_to_opt(row_count_name).map(|name| polars::io::RowCount {
        name,
        offset: row_count_offset as u32, //could not point to type polars::polars_arrow::index::IdxSize
    });

    let r = pl::LazyCsvReader::new(path)
        .with_infer_schema_length(null_to_opt(infer_schema_length).map(|x| x as usize))
        .with_delimiter(sep.as_bytes()[0])
        .has_header(has_header)
        .with_ignore_parser_errors(ignore_errors)
        .with_skip_rows(skip_rows as usize)
        .with_n_rows(null_to_opt(n_rows).map(|x| x as usize))
        .with_cache(cache)
        .with_dtype_overwrite(schema.as_ref())
        .low_memory(low_memory)
        .with_comment_char(null_to_opt(comment_char).map(|x| x.as_bytes()[0]))
        .with_quote_char(null_to_opt(quote_char).map(|x| x.as_bytes()[0]))
        .with_rechunk(rechunk)
        .with_skip_rows_after_header(skip_rows_after_header as usize)
        .with_encoding(encoding)
        .with_row_count(row_count)
        .with_parse_dates(parse_dates)
        .with_null_values(Wrap(null_values).into());

    let x = r.finish().map_err(wrap_error)?;

    Ok(Rlazyframe(x))
}

extendr_module! {
    mod read_csv;
    fn new_csv_r;
    impl Rlazyframe;
    impl RNullValues;
}
