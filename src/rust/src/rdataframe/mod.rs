use extendr_api::{extendr, prelude::*, rprintln};
use polars::prelude::{self as pl, IntoLazy, SerWriter};
use std::result::Result;
pub mod read_csv;
pub mod read_ipc;
pub mod read_ndjson;
pub mod read_parquet;
use crate::conversion_r_to_s::robjname2series;
use crate::lazy;
use crate::rdatatype;
use crate::rdatatype::{new_parquet_compression, RPolarsDataType};
use crate::robj_to;
use crate::rpolarserr::*;
use either::Either;
pub use lazy::dataframe::*;

use crate::conversion_s_to_r::pl_series_to_list;
pub use crate::series::*;

use arrow::datatypes::ArrowDataType;
use polars::prelude::ArrowField;
use polars_core::error::PolarsError;
use polars_core::utils::arrow;

use crate::utils::{collect_hinted_result, r_result_list};

use crate::conversion::strings_to_smartstrings;
use polars::frame::explode::MeltArgs;
use polars::prelude::pivot::{pivot, pivot_stable};

pub struct OwnedDataFrameIterator {
    columns: Vec<polars::series::Series>,
    data_type: arrow::datatypes::ArrowDataType,
    idx: usize,
    n_chunks: usize,
}

impl OwnedDataFrameIterator {
    pub fn new(df: polars::frame::DataFrame) -> Self {
        let schema = df.schema().to_arrow(false);
        let data_type = ArrowDataType::Struct(schema.fields);
        let vs = df.get_columns().to_vec();
        Self {
            columns: vs,
            data_type,
            idx: 0,
            n_chunks: df.n_chunks(),
        }
    }
}

impl Iterator for OwnedDataFrameIterator {
    type Item = Result<Box<dyn arrow::array::Array>, PolarsError>;

    fn next(&mut self) -> Option<Self::Item> {
        if self.idx >= self.n_chunks {
            None
        } else {
            // create a batch of the columns with the same chunk no.
            let batch_cols = self
                .columns
                .iter()
                .map(|s| s.to_arrow(self.idx, false))
                .collect();
            self.idx += 1;

            let chunk = polars::frame::ArrowChunk::new(batch_cols);
            let array = arrow::array::StructArray::new(
                self.data_type.clone(),
                chunk.into_arrays(),
                std::option::Option::None,
            );
            Some(std::result::Result::Ok(Box::new(array)))
        }
    }
}

#[derive(Debug, Clone)]
pub struct RPolarsDataFrame(pub pl::DataFrame);

impl From<pl::DataFrame> for RPolarsDataFrame {
    fn from(item: pl::DataFrame) -> Self {
        RPolarsDataFrame(item)
    }
}

#[extendr]
impl RPolarsDataFrame {
    pub fn shape(&self) -> Robj {
        let shp = self.0.shape();
        r!([shp.0, shp.1])
    }

    pub fn n_chunks(&self, strategy: Robj) -> RResult<Vec<f64>> {
        let nchks: Vec<_> = self.0.iter().map(|s| s.n_chunks() as f64).collect();

        match robj_to!(str, strategy)? {
            "all" => Ok(nchks),
            "first" => {
                if nchks.is_empty() {
                    Ok(vec![])
                } else {
                    Ok(vec![nchks.into_iter().next().expect("has atleast len 1")])
                }
            }
            _ => {
                Err(RPolarsErr::new()
                    .plain("strategy not recognized, neither 'all' or 'first'".into()))
            }
        }
    }

    pub fn rechunk(&self) -> Self {
        self.0.agg_chunks().into()
    }

    pub fn clone_in_rust(&self) -> RPolarsDataFrame {
        self.clone()
    }

    #[allow(clippy::should_implement_trait)]
    pub fn default() -> Self {
        RPolarsDataFrame::new_with_capacity(0)
    }

    pub fn lazy(&self) -> RPolarsLazyFrame {
        RPolarsLazyFrame(self.0.clone().lazy())
    }

    //internal use only
    pub fn drop_all_in_place(&mut self) {
        *self = Self::new_with_capacity(0);
    }

    //internal use
    pub fn new_with_capacity(capacity: i32) -> Self {
        let empty_series: Vec<pl::Series> = Vec::with_capacity(capacity as usize);
        RPolarsDataFrame(pl::DataFrame::new(empty_series).unwrap())
    }

    //internal use
    pub fn set_column_from_robj(&mut self, robj: Robj, name: &str) -> Result<(), String> {
        robjname2series(robj, name)
            .and_then(|s| self.0.with_column(s).map(|_| ()))
            .map_err(|err| format!("in set_column_from_robj: {:?}", err))
    }

    //internal use
    pub fn set_column_from_series(&mut self, x: &RPolarsSeries) -> Result<(), String> {
        let s: pl::Series = x.into(); //implicit clone, cannot move R objects
        self.0
            .with_column(s)
            .map(|_| ())
            .map_err(|err| format!("in set_column_from_series: {:?}", err))
    }

    pub fn with_row_index(&self, name: Robj, offset: Robj) -> RResult<Self> {
        Ok(self
            .0
            .clone()
            .with_row_index(
                robj_to!(String, name)?.as_str(),
                robj_to!(Option, u32, offset)?,
            )
            .map_err(polars_to_rpolars_err)?
            .into())
    }

    pub fn print(&self) -> Self {
        rprintln!("{:#?}", self.0);
        self.clone()
    }

    pub fn columns(&self) -> Vec<String> {
        self.0
            .get_column_names_owned()
            .iter()
            .map(|ss| ss.to_string())
            .collect()
    }

    pub fn set_column_names_mut(&mut self, names: Vec<String>) -> Result<(), String> {
        self.0
            .set_column_names(&names[..])
            .map(|_| ())
            .map_err(|err| format!("in set_column_names_mut: {:?}", err))
    }

    pub fn get_column(&self, name: &str) -> List {
        let res_series = self
            .0
            .select([name])
            .map(|df| RPolarsSeries(df.iter().next().unwrap().clone()))
            .map_err(|err| format!("in get_column: {:?}", err));
        r_result_list(res_series)
    }

    pub fn get_columns(&self) -> List {
        let mut l = List::from_values(
            self.0
                .get_columns()
                .iter()
                .map(|x| RPolarsSeries(x.clone())),
        );
        l.set_names(self.0.get_column_names()).unwrap();
        l
    }

    pub fn dtypes(&self) -> List {
        let iter = self.0.iter().map(|s| RPolarsDataType(s.dtype().clone()));
        List::from_values(iter)
    }

    pub fn dtype_strings(&self) -> Vec<String> {
        self.0
            .get_columns()
            .iter()
            .map(|s| format!("{}", s.dtype()))
            .collect()
    }

    pub fn schema(&self) -> List {
        let mut l = self.dtypes();
        l.set_names(self.0.get_column_names()).unwrap();
        l
    }

    // fn compare_other_(&self) -> bool {
    //     self.0.compare
    // }

    pub fn to_list(&self, int64_conversion: &str) -> List {
        let robj_vec_res: Result<Vec<Robj>, _> = collect_hinted_result(
            self.0.width(),
            self.0
                .iter()
                .map(|x| pl_series_to_list(x, false, int64_conversion)),
        );

        let robj_list_res = robj_vec_res
            .map_err(|err| format!("conversion error for a polars Series to R: {}", err))
            .and_then(|vec_robj| {
                extendr_api::prelude::List::from_names_and_values(self.columns(), vec_robj)
                    .map_err(|err| format!("internal error: could not create an R list {}", err))
                    .map(|ok| ok.into_robj())
            });

        r_result_list(robj_list_res)
    }

    //this methods should only be used for benchmarking
    pub fn to_list_unwind(&self, int64_conversion: &str) -> Robj {
        let robj_vec_res: Result<Vec<Robj>, _> = collect_hinted_result(
            self.0.width(),
            self.0
                .iter()
                .map(|x| pl_series_to_list(x, false, int64_conversion)),
        );

        let robj_list_res = robj_vec_res
            .map_err(|err| format!("conversion error for a polars Series to R: {}", err))
            .and_then(|vec_robj| {
                extendr_api::prelude::List::from_names_and_values(self.columns(), vec_robj)
                    .map_err(|err| format!("internal error: could not create an R list {}", err))
                    .map(|ok| ok.into_robj())
            });

        robj_list_res.unwrap()
    }

    // to_list have this variant with set_structs = true at pl_series_to_list
    // does not expose this arg in to_list as it is quite niche and might be deprecated later
    pub fn to_list_tag_structs(&self, int64_conversion: &str) -> List {
        //convert DataFrame to Result of to R vectors, error if DataType is not supported
        let robj_vec_res: Result<Vec<Robj>, _> = collect_hinted_result(
            self.0.width(),
            self.0
                .iter()
                .map(|x| pl_series_to_list(x, true, int64_conversion)),
        );

        //rewrap Ok(Vec<Robj>) as R list
        let robj_list_res = robj_vec_res
            .map_err(|err| format!("conversion error for a polars Series to R: {}", err))
            .and_then(|vec_robj| {
                extendr_api::prelude::List::from_names_and_values(self.columns(), vec_robj)
                    .map_err(|err| format!("internal error: could not create an R list {}", err))
                    .map(|ok| ok.into_robj())
            });

        r_result_list(robj_list_res)
    }

    pub fn equals(&self, other: &RPolarsDataFrame) -> bool {
        self.0.equals(&other.0)
    }

    pub fn select_at_idx(&self, idx: i32) -> List {
        let expr_result = {
            self.0
                .select_at_idx(idx as usize)
                .map(|s| RPolarsSeries(s.clone()))
                .ok_or_else(|| format!("select_at_idx: no series found at idx {:?}", idx))
        };
        r_result_list(expr_result)
    }

    pub fn drop_in_place(&mut self, names: &str) -> RPolarsSeries {
        RPolarsSeries(self.0.drop_in_place(names).unwrap())
    }

    pub fn select(&self, exprs: Robj) -> RResult<RPolarsDataFrame> {
        self.lazy().select(exprs)?.collect()
    }

    pub fn with_columns(&self, exprs: Robj) -> RResult<RPolarsDataFrame> {
        self.lazy().with_columns(exprs)?.collect()
    }

    pub fn to_struct(&self, name: Robj) -> RResult<RPolarsSeries> {
        use pl::IntoSeries;
        let name = robj_to!(Option, str, name)?.unwrap_or("");
        let s = self.0.clone().into_struct(name);
        Ok(s.into_series().into())
    }

    pub fn unnest(&self, names: Vec<String>) -> RResult<Self> {
        self.lazy().unnest(names)?.collect()
    }

    pub fn partition_by(&self, by: Robj, maintain_order: Robj, include_key: Robj) -> RResult<List> {
        let by = robj_to!(Vec, String, by)?;
        let maintain_order = robj_to!(bool, maintain_order)?;
        let include_key = robj_to!(bool, include_key)?;
        let out = if maintain_order {
            self.0.clone().partition_by_stable(by, include_key)
        } else {
            self.0.partition_by(by, include_key)
        }
        .map_err(polars_to_rpolars_err)?;

        let vec = unsafe { std::mem::transmute::<Vec<pl::DataFrame>, Vec<RPolarsDataFrame>>(out) };
        Ok(List::from_values(vec))
    }

    pub fn export_stream(&self, stream_ptr: &str) {
        let schema = self.0.schema().to_arrow(false);
        let data_type = ArrowDataType::Struct(schema.fields);
        let field = ArrowField::new("", data_type, false);

        let iter_boxed = Box::new(OwnedDataFrameIterator::new(self.0.clone()));
        let mut stream = arrow::ffi::export_iterator(iter_boxed, field);
        let stream_out_ptr_addr: usize = stream_ptr.parse().unwrap();
        let stream_out_ptr = stream_out_ptr_addr as *mut arrow::ffi::ArrowArrayStream;
        unsafe {
            std::ptr::swap_nonoverlapping(
                stream_out_ptr,
                &mut stream as *mut arrow::ffi::ArrowArrayStream,
                1,
            );
        }
    }

    pub fn from_arrow_record_batches(rbr: Robj) -> Result<RPolarsDataFrame, String> {
        Ok(RPolarsDataFrame(unsafe {
            crate::arrow_interop::to_rust::to_rust_df(rbr)
        }?))
    }

    pub fn estimated_size(&self) -> f64 {
        self.0.clone().estimated_size() as f64
    }

    pub fn null_count(&self) -> Self {
        self.0.clone().null_count().into()
    }

    fn melt(
        &self,
        id_vars: Robj,
        value_vars: Robj,
        value_name: Robj,
        variable_name: Robj,
    ) -> RResult<Self> {
        let args = MeltArgs {
            id_vars: strings_to_smartstrings(robj_to!(Vec, String, id_vars)?),
            value_vars: strings_to_smartstrings(robj_to!(Vec, String, value_vars)?),
            value_name: robj_to!(Option, String, value_name)?.map(|s| s.into()),
            variable_name: robj_to!(Option, String, variable_name)?.map(|s| s.into()),
            streamable: false,
        };

        self.0
            .melt2(args)
            .map_err(polars_to_rpolars_err)
            .map(RPolarsDataFrame)
    }

    #[allow(clippy::too_many_arguments)]
    pub fn pivot_expr(
        &self,
        index: Robj,
        columns: Robj,
        values: Robj,
        maintain_order: Robj,
        sort_columns: Robj,
        aggregate_expr: Robj,
        separator: Robj,
    ) -> RResult<Self> {
        let fun = if robj_to!(bool, maintain_order)? {
            pivot_stable
        } else {
            pivot
        };

        fun(
            &self.0,
            robj_to!(Vec, String, index)?,
            robj_to!(Vec, String, columns)?,
            robj_to!(Option, Vec, String, values)?,
            robj_to!(bool, sort_columns)?,
            robj_to!(Option, PLExpr, aggregate_expr)?,
            robj_to!(Option, str, separator)?,
        )
        .map_err(polars_to_rpolars_err)
        .map(RPolarsDataFrame)
    }

    pub fn sample_n(
        &self,
        n: Robj,
        with_replacement: Robj,
        shuffle: Robj,
        seed: Robj,
    ) -> RResult<Self> {
        self.0
            .clone()
            .sample_n(
                &robj_to!(PLSeries, n)?,
                robj_to!(bool, with_replacement)?,
                robj_to!(bool, shuffle)?,
                robj_to!(Option, u64, seed)?,
            )
            .map_err(polars_to_rpolars_err)
            .map(RPolarsDataFrame)
    }

    pub fn sample_frac(
        &self,
        frac: Robj,
        with_replacement: Robj,
        shuffle: Robj,
        seed: Robj,
    ) -> RResult<Self> {
        self.0
            .clone()
            .sample_frac(
                &robj_to!(PLSeries, frac)?,
                robj_to!(bool, with_replacement)?,
                robj_to!(bool, shuffle)?,
                robj_to!(Option, u64, seed)?,
            )
            .map_err(polars_to_rpolars_err)
            .map(RPolarsDataFrame)
    }

    pub fn transpose(&mut self, keep_names_as: Robj, new_col_names: Robj) -> RResult<Self> {
        let opt_s = robj_to!(Option, str, keep_names_as)?;
        let opt_vec_s = robj_to!(Option, Vec, String, new_col_names)?;
        let opt_either_vec_s = opt_vec_s.map(Either::Right);
        self.0
            .transpose(opt_s, opt_either_vec_s)
            .map_err(polars_to_rpolars_err)
            .map(RPolarsDataFrame)
    }

    #[allow(clippy::too_many_arguments)]
    pub fn write_csv(
        &self,
        file: Robj,
        include_bom: Robj,
        include_header: Robj,
        separator: Robj,
        line_terminator: Robj,
        quote: Robj,
        batch_size: Robj,
        datetime_format: Robj,
        date_format: Robj,
        time_format: Robj,
        float_precision: Robj,
        null_value: Robj,
        quote_style: Robj,
    ) -> RResult<()> {
        let file = robj_to!(str, file)?;
        let f = std::fs::File::create(file)?;
        pl::CsvWriter::new(f)
            .include_bom(robj_to!(bool, include_bom)?)
            .include_header(robj_to!(bool, include_header)?)
            .with_separator(robj_to!(Utf8Byte, separator)?)
            .with_line_terminator(robj_to!(String, line_terminator)?)
            .with_quote_char(robj_to!(Utf8Byte, quote)?)
            .with_batch_size(robj_to!(nonzero_usize, batch_size)?)
            .with_datetime_format(robj_to!(Option, String, datetime_format)?)
            .with_date_format(robj_to!(Option, String, date_format)?)
            .with_time_format(robj_to!(Option, String, time_format)?)
            .with_float_precision(robj_to!(Option, usize, float_precision)?)
            .with_null_value(robj_to!(String, null_value)?)
            .with_quote_style(robj_to!(QuoteStyle, quote_style)?)
            .finish(&mut self.0.clone())
            .map_err(polars_to_rpolars_err)
    }

    pub fn write_parquet(
        &self,
        file: Robj,
        compression_method: Robj,
        compression_level: Robj,
        statistics: Robj,
        row_group_size: Robj,
        data_pagesize_limit: Robj,
    ) -> RResult<u64> {
        let file = robj_to!(str, file)?;
        let f = std::fs::File::create(file)?;
        pl::ParquetWriter::new(f)
            .with_compression(new_parquet_compression(
                compression_method,
                compression_level,
            )?)
            .with_statistics(robj_to!(bool, statistics)?)
            .with_row_group_size(robj_to!(Option, usize, row_group_size)?)
            .with_data_page_size(robj_to!(Option, usize, data_pagesize_limit)?)
            .set_parallel(true)
            .finish(&mut self.0.clone())
            .map_err(polars_to_rpolars_err)
    }

    pub fn write_json(&mut self, file: Robj, pretty: Robj, row_oriented: Robj) -> RResult<()> {
        let f = std::fs::File::create(robj_to!(str, file)?)?;
        match (robj_to!(bool, pretty)?, robj_to!(bool, row_oriented)?) {
            (_, true) => pl::JsonWriter::new(f)
                .with_json_format(pl::JsonFormat::Json)
                .finish(&mut self.0),
            (true, _) => serde_json::to_writer_pretty(f, &self.0)
                .map_err(|e| pl::polars_err!(ComputeError: "{e}")),
            (false, _) => {
                serde_json::to_writer(f, &self.0).map_err(|e| pl::polars_err!(ComputeError: "{e}"))
            }
        }
        .map_err(polars_to_rpolars_err)
    }

    pub fn write_ndjson(&mut self, file: Robj) -> RResult<()> {
        let f = std::fs::File::create(robj_to!(str, file)?)?;
        pl::JsonWriter::new(f)
            .with_json_format(pl::JsonFormat::JsonLines)
            .finish(&mut self.0)
            .map_err(polars_to_rpolars_err)
    }
}

impl RPolarsDataFrame {
    pub fn to_list_result(&self, int64_conversion: &str) -> Result<Robj, pl::PolarsError> {
        //convert DataFrame to Result of to R vectors, error if DataType is not supported
        let robj_vec_res: Result<Vec<Robj>, _> = self
            .0
            .iter()
            .map(|s| pl_series_to_list(s, true, int64_conversion))
            .collect();

        //rewrap Ok(Vec<Robj>) as R list
        robj_vec_res.map(|vec_robj| {
            let l = extendr_api::prelude::List::from_names_and_values(self.columns(), vec_robj)
                .unwrap();
            l.into_robj()
        })
    }
}

#[derive(Clone, Debug, Default)]
pub struct RPolarsVecDataFrame(pub Vec<pl::DataFrame>);

#[extendr]
impl RPolarsVecDataFrame {
    pub fn with_capacity(n: i32) -> Self {
        RPolarsVecDataFrame(Vec::with_capacity(n as usize))
    }

    pub fn push(&mut self, df: &RPolarsDataFrame) {
        self.0.push(df.0.clone());
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self);
    }
}

extendr_module! {
    mod rdataframe;
    use read_csv;
    use read_ipc;
    use read_ndjson;
    use read_parquet;
    use rdatatype;

    impl RPolarsDataFrame;
    impl RPolarsVecDataFrame;
}
