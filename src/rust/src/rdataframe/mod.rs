use extendr_api::{extendr, prelude::*, rprintln, Rinternals};
use polars::prelude::{self as pl, IntoLazy};
use std::result::Result;
pub mod read_csv;
pub mod read_ipc;
pub mod read_parquet;
use crate::lazy::dsl;

use crate::lazy;
use crate::rdatatype;
use crate::rlib;
use crate::utils::extendr_concurrent::ParRObj;
pub use lazy::dataframe::*;

use crate::conversion_r_to_s::robjname2series;
use crate::rdatatype::RPolarsDataType;

use crate::conversion_s_to_r::pl_series_to_list;
pub use crate::series::*;
use dsl::*;

use arrow::datatypes::DataType;
use polars::prelude::ArrowField;
use polars_core::utils::arrow;

use crate::utils::{collect_hinted_result, r_result_list};

pub struct OwnedDataFrameIterator {
    columns: Vec<polars::series::Series>,
    data_type: arrow::datatypes::DataType,
    idx: usize,
    n_chunks: usize,
}

impl OwnedDataFrameIterator {
    fn new(df: polars::frame::DataFrame) -> Self {
        let schema = df.schema().to_arrow();
        let data_type = DataType::Struct(schema.fields);

        Self {
            columns: df.get_columns().clone(),
            data_type,
            idx: 0,
            n_chunks: df.n_chunks(),
        }
    }
}

impl Iterator for OwnedDataFrameIterator {
    type Item = Result<Box<dyn arrow::array::Array>, arrow::error::Error>;

    fn next(&mut self) -> Option<Self::Item> {
        if self.idx >= self.n_chunks {
            None
        } else {
            // create a batch of the columns with the same chunk no.
            let batch_cols = self.columns.iter().map(|s| s.to_arrow(self.idx)).collect();
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
pub struct DataFrame(pub pl::DataFrame);

impl From<pl::DataFrame> for DataFrame {
    fn from(item: pl::DataFrame) -> Self {
        DataFrame(item)
    }
}

#[extendr]
impl DataFrame {

    pub fn shape(&self) -> Robj {
        let shp = self.0.shape();
        r!([shp.0, shp.1])
    }
    
    //renamed back to clone
    pub fn clone_see_me_macro(&self) -> DataFrame {
        self.clone()
    }

    //internal use
    pub fn new() -> Self {
        let empty_series: Vec<pl::Series> = Vec::new();
        DataFrame(pl::DataFrame::new(empty_series).unwrap())
    }

    pub fn lazy(&self) -> LazyFrame {
        LazyFrame(self.0.clone().lazy())
    }

    //internal use
    pub fn new_with_capacity(capacity: i32) -> Self {
        let empty_series: Vec<pl::Series> = Vec::with_capacity(capacity as usize);
        DataFrame(pl::DataFrame::new(empty_series).unwrap())
    }

    //internal use
    pub fn set_column_from_robj(&mut self, robj: Robj, name: &str) -> Result<(), String> {
        robjname2series(&ParRObj(robj), name)
            .and_then(|s| self.0.with_column(s).map(|_| ()))
            .map_err(|err| format!("in set_column_from_robj: {:?}", err))
    }

    //internal use
    pub fn set_column_from_series(&mut self, x: &Series) -> Result<(), String> {
        let s: pl::Series = x.into(); //implicit clone, cannot move R objects
        self.0
            .with_column(s)
            .map(|_| ())
            .map_err(|err| format!("in set_column_from_series: {:?}", err))
    }

    pub fn new_par_from_list(robj_list: List) -> Result<DataFrame, String> {
        let v: Vec<(ParRObj, String)> = robj_list
            .iter()
            .map(|(str, robj)| (ParRObj(robj.clone()), str.to_owned()))
            .collect();

        crate::conversion_r_to_s::par_read_robjs(v)
            .and_then(|v_s| pl::DataFrame::new(v_s))
            .map_err(|err| err.to_string())
            .map(|df| DataFrame(df))
    }

    pub fn print(&self) -> Self {
        rprintln!("{:#?}", self.0);
        self.clone()
    }

    pub fn columns(&self) -> Vec<String> {
        self.0.get_column_names_owned()
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
            .map(|df| Series(df.iter().next().unwrap().clone()))
            .map_err(|err| format!("in get_column: {:?}", err));
        r_result_list(res_series)
    }

    pub fn get_columns(&self) -> List {
        let mut l = List::from_values(self.0.get_columns().iter().map(|x| Series(x.clone())));
        l.set_names(self.0.get_column_names()).unwrap();
        l
    }

    pub fn dtypes(&self) -> List {
        let iter = self.0.iter().map(|s| RPolarsDataType(s.dtype().clone()));
        List::from_values(iter)
    }

    pub fn schema(&self) -> List {
        let mut l = self.dtypes();
        l.set_names(self.0.get_column_names()).unwrap();
        l
    }

    // fn compare_other_(&self) -> bool {
    //     self.0.compare
    // }

    pub fn to_list(&self) -> List {
        let robj_vec_res: Result<Vec<Robj>, _> = collect_hinted_result(
            self.0.width(),
            self.0.iter().map(|x| pl_series_to_list(x, false, true)),
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
    pub fn to_list_unwind(&self) -> Robj {
        let robj_vec_res: Result<Vec<Robj>, _> = collect_hinted_result(
            self.0.width(),
            self.0.iter().map(|x| pl_series_to_list(x, false, true)),
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
    pub fn to_list_tag_structs(&self) -> List {
        //convert DataFrame to Result of to R vectors, error if DataType is not supported
        let robj_vec_res: Result<Vec<Robj>, _> = collect_hinted_result(
            self.0.width(),
            self.0.iter().map(|x| pl_series_to_list(x, true, true)),
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

    pub fn select_at_idx(&self, idx: i32) -> List {
        let expr_result = || -> Result<Series, String> {
            self.0
                .select_at_idx(idx as usize)
                .map(|s| Series(s.clone()))
                .ok_or_else(|| format!("select_at_idx: no series found at idx {:?}", idx))
        }();
        r_result_list(expr_result)
    }
    
    pub fn drop_in_place(&mut self, names: &str) -> Series {
        Series(self.0.drop_in_place(names).unwrap())
    }

    pub fn select(&mut self, exprs: &ProtoExprArray) -> list::List {
        let exprs: Vec<pl::Expr> = pra_to_vec(exprs, "select");
        LazyFrame(self.lazy().0.select(exprs)).collect()
    }

    //used in GroupBy, not DataFrame
    pub fn by_agg(
        &mut self,
        group_exprs: &ProtoExprArray,
        agg_exprs: &ProtoExprArray,
        maintain_order: bool,
    ) -> List {
        let group_exprs: Vec<pl::Expr> = pra_to_vec(group_exprs, "select");
        let agg_exprs: Vec<pl::Expr> = pra_to_vec(agg_exprs, "select");

        let lazy_df = self.clone().0.lazy();

        let gb = if maintain_order {
            lazy_df.groupby_stable(group_exprs)
        } else {
            lazy_df.groupby(group_exprs)
        };

        LazyFrame(gb.agg(agg_exprs)).collect()
    }

    pub fn to_struct(&self, name: &str) -> Series {
        use pl::IntoSeries;
        let s = self.0.clone().into_struct(name);
        s.into_series().into()
    }

    pub fn unnest(&self, names: Nullable<Vec<String>>) -> List {
        let names = if let Some(vec_string) = null_to_opt(names) {
            vec_string
        } else {
            //missing names choose to unnest any column of DataType Struct
            self.0
                .dtypes()
                .iter()
                .zip(self.0.get_column_names().iter())
                .filter(|(dtype, _)| match dtype {
                    pl::DataType::Struct(_) => true,
                    _ => false,
                })
                .map(|(_, y)| y.to_string())
                .collect::<Vec<String>>()
        };

        r_result_list(
            self.0
                .unnest(names)
                .map(|s| DataFrame(s))
                .map_err(|err| format!("in unnest: {:?}", err)),
        )
    }

    pub fn export_stream(&self, stream_ptr: &str) {
        let schema = self.0.schema().to_arrow();
        let data_type = DataType::Struct(schema.fields);
        let field = ArrowField::new("", data_type.clone(), false);

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

    pub fn from_arrow_record_batches(rbr: Robj) -> Result<DataFrame, String> {
        Ok(DataFrame(crate::arrow_interop::to_rust::to_rust_df(rbr)?))
    }

    pub fn estimated_size(&self) -> f64 {
        self.0.clone().estimated_size() as f64
    }

    pub fn null_count(&self) -> Self {
        self.0.clone().null_count().into()
    }
}
use crate::utils::wrappers::null_to_opt;
impl DataFrame {
    pub fn to_list_result(&self) -> Result<Robj, pl::PolarsError> {
        //convert DataFrame to Result of to R vectors, error if DataType is not supported
        let robj_vec_res: Result<Vec<Robj>, _> = self
            .0
            .iter()
            .map(|s| pl_series_to_list(s, true, true))
            .collect();

        //rewrap Ok(Vec<Robj>) as R list
        let robj_list_res = robj_vec_res.map(|vec_robj| {
            let l = extendr_api::prelude::List::from_names_and_values(self.columns(), vec_robj)
                .unwrap();
            l.into_robj()
        });

        robj_list_res
    }
}

#[derive(Clone, Debug)]
pub struct VecDataFrame(pub Vec<pl::DataFrame>);

#[extendr]
impl VecDataFrame {
    pub fn new() -> Self {
        VecDataFrame(Vec::new())
    }

    pub fn with_capacity(n: i32) -> Self {
        VecDataFrame(Vec::with_capacity(n as usize))
    }

    pub fn push(&mut self, df: &DataFrame) {
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
    use read_parquet;
    use rdatatype;
    use rlib;
    impl DataFrame;
    impl VecDataFrame;
}
