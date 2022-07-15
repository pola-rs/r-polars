//read csv
use super::wrap_errors::wrap_error;
use crate::utils::wrappers::Wrap;
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
#[allow(clippy::too_many_arguments)]
pub fn new_from_csv_r(
    path: String,
    sep: &str,
    has_header: bool,
    ignore_errors: bool,
    skip_rows: usize,
    n_rows: Option<usize>,
    cache: bool,
    overwrite_dtype: Option<Vec<(&str, Wrap<DataType>)>>,
    low_memory: bool,
    comment_char: Option<&str>,
    quote_char: Option<&str>,
    null_values: Option<Wrap<NullValues>>,
    infer_schema_length: Option<usize>,
    // with_schema_modify: Option<PyObject>,
    rechunk: bool,
    skip_rows_after_header: usize,
    encoding: &str,
    row_count: Option<(String, IdxSize)>, //replaced IdxSize with usize
    parse_dates: bool,
) -> Result<LazyFrame> {
    let null_values = null_values.map(|w| w.0);
    let comment_char = comment_char.map(|s| s.as_bytes()[0]);
    let quote_char = quote_char.map(|s| s.as_bytes()[0]);
    let delimiter = sep.as_bytes()[0];

    let row_count = row_count.map(|(name, offset)| RowCount { name, offset });

    let encoding = match encoding {
        "utf8" => CsvEncoding::Utf8,
        "utf8-lossy" => CsvEncoding::LossyUtf8,
        e => return Err(Error::Other(format!("encoding not {} not implemented.", e)).into()),
    };

    let overwrite_dtype = overwrite_dtype.map(|overwrite_dtype| {
        let fields = overwrite_dtype
            .into_iter()
            .map(|(name, dtype)| Field::new(name, dtype.0));
        Schema::from(fields)
    });
    let mut r = LazyCsvReader::new(path)
        .with_infer_schema_length(infer_schema_length)
        .with_delimiter(delimiter)
        .has_header(has_header)
        .with_ignore_parser_errors(ignore_errors)
        .with_skip_rows(skip_rows)
        .with_n_rows(n_rows)
        .with_cache(cache)
        .with_dtype_overwrite(overwrite_dtype.as_ref())
        .low_memory(low_memory)
        .with_comment_char(comment_char)
        .with_quote_char(quote_char)
        .with_rechunk(rechunk)
        .with_skip_rows_after_header(skip_rows_after_header)
        .with_encoding(encoding)
        .with_row_count(row_count)
        .with_parse_dates(parse_dates)
        .with_null_values(null_values);

    // TODO replace with R closure to modify schema
    // if let Some(lambda) = with_schema_modify {
    //     let f = |schema: Schema| {
    //         let gil = Python::acquire_gil();
    //         let py = gil.python();

    //         let iter = schema.iter_names();
    //         let names = PyList::new(py, iter);

    //         let out = lambda.call1(py, (names,)).expect("python function failed");
    //         let new_names = out
    //             .extract::<Vec<String>>(py)
    //             .expect("python function should return List[str]");
    //         assert_eq!(
    //             new_names.len(),
    //             schema.len(),
    //             "The length of the new names list should be equal to the original column length"
    //         );

    //         let fields = schema
    //             .iter_dtypes()
    //             .zip(new_names)
    //             .map(|(dtype, name)| Field::from_owned(name, dtype.clone()));
    //         Ok(Schema::from(fields))
    //     };
    //     r = r.with_schema_modify(f).map_err(PyPolarsErr::from)?
    // }

    let x = r.finish().map_err(wrap_error)?;

    Ok(x)
}
