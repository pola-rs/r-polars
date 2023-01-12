use extendr_api::{extendr, prelude::*, rprintln, Rinternals};
use polars::prelude::{self as pl, IntoLazy};
use std::result::Result;
pub mod r_to_series;
pub mod read_csv;
pub mod read_parquet;
pub mod rexpr;
pub mod rseries;
pub mod series_to_r;

pub use crate::rdatatype::*;
pub use crate::rlazyframe::*;

use super::rlib::*;
use r_to_series::robjname2series;
use read_csv::*;
use read_parquet::*;
use rexpr::*;
pub use rseries::*;
use series_to_r::pl_series_to_list;

use polars_core::utils::arrow;
use polars::prelude::ArrowField;
use arrow::datatypes::DataType;

use crate::utils::r_result_list;

pub struct OwnedDataFrameIterator {
    columns: Vec<polars::series::Series>,
    data_type: arrow::datatypes::DataType,
    idx: usize,
    n_chunks: usize,
}

impl OwnedDataFrameIterator {
    fn new(df: polars::frame::DataFrame ) -> Self {
        let schema = df.schema().to_arrow();
        let data_type = DataType::Struct(schema.fields);

        Self {
            columns: df.get_columns().clone(),
            data_type,
            idx: 0,
            n_chunks: df.n_chunks()
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
            let array = arrow::array::StructArray::new(self.data_type.clone(), chunk.into_arrays(), std::option::Option::None);
            Some(std::result::Result::Ok(Box::new(array)))
        }
    }
}


#[extendr]
#[derive(Debug, Clone)]
pub struct DataFrame(pub pl::DataFrame);

#[extendr]
impl DataFrame {
    pub fn shape(&self) -> Robj {
        let shp = self.0.shape();
        r!([shp.0, shp.1])
    }

    //renamed back to clone
    fn clone_see_me_macro(&self) -> DataFrame {
        self.clone()
    }

    //internal use
    fn new() -> Self {
        let empty_series: Vec<pl::Series> = Vec::new();
        DataFrame(pl::DataFrame::new(empty_series).unwrap())
    }

    fn lazy(&self) -> LazyFrame {
        LazyFrame(self.0.clone().lazy())
    }

    //internal use
    fn new_with_capacity(capacity: i32) -> Self {
        let empty_series: Vec<pl::Series> = Vec::with_capacity(capacity as usize);
        DataFrame(pl::DataFrame::new(empty_series).unwrap())
    }

    //internal use
    fn set_column_from_robj(&mut self, robj: Robj, name: &str) -> List {
        let result: pl::PolarsResult<()> =
            robjname2series(&robj, name).and_then(|s| self.0.with_column(s).map(|_| ()));
        r_result_list(result)
    }

    //internal use
    fn set_column_from_series(&mut self, x: &Series) -> List {
        let s: pl::Series = x.into(); //implicit clone, cannot move R objects
        r_result_list(self.0.with_column(s).map(|_| ()))
    }

    fn print(&self) -> Self {
        rprintln!("{:#?}", self.0);
        self.clone()
    }

    fn columns(&self) -> Vec<String> {
        self.0.get_column_names_owned()
    }

    fn set_column_names_mut(&mut self, names: Vec<String>) -> List {
        let res = self.0.set_column_names(&names[..]);
        r_result_list(res)
    }

    fn get_column(&self, name: &str) -> List {
        let res_series = self
            .0
            .select([name])
            .map(|df| Series(df.iter().next().unwrap().clone()));
        r_result_list(res_series)
    }

    fn get_columns(&self) -> List {
        let mut l = List::from_values(self.0.get_columns().iter().map(|x| Series(x.clone())));
        l.set_names(self.0.get_column_names()).unwrap();
        l
    }

    fn dtypes(&self) -> List {
        let iter = self.0.iter().map(|s| RPolarsDataType(s.dtype().clone()));
        List::from_values(iter)
    }

    fn schema(&self) -> List {
        let mut l = self.dtypes();
        l.set_names(self.0.get_column_names()).unwrap();
        l
    }

    // fn compare_other_(&self) -> bool {
    //     self.0.compare
    // }

    fn to_list(&self) -> List {
        //convert DataFrame to Result of to R vectors, error if DataType is not supported
        let robj_vec_res: Result<Vec<Robj>, _> =
            self.0.iter().map(|x| pl_series_to_list(x, false)).collect();

        //rewrap Ok(Vec<Robj>) as R list
        let robj_list_res = robj_vec_res.map(|vec_robj| {
            r!(extendr_api::prelude::List::from_names_and_values(
                self.columns(),
                vec_robj
            ))
        });

        r_result_list(robj_list_res)
    }

    // to_list have this variant with set_structs = true at pl_series_to_list
    // does not expose this arg in to_list as it is quite niche and might be deprecated later
    fn to_list_tag_structs(&self) -> List {
        //convert DataFrame to Result of to R vectors, error if DataType is not supported
        let robj_vec_res: Result<Vec<Robj>, _> =
            self.0.iter().map(|x| pl_series_to_list(x, true)).collect();

        //rewrap Ok(Vec<Robj>) as R list
        let robj_list_res = robj_vec_res.map(|vec_robj| {
            r!(extendr_api::prelude::List::from_names_and_values(
                self.columns(),
                vec_robj
            ))
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

    fn select(&mut self, exprs: &ProtoExprArray) -> list::List {
        let exprs: Vec<pl::Expr> = pra_to_vec(exprs, "select");
        LazyFrame(self.lazy().0.select(exprs)).collect()
    }

    //used in GroupBy, not DataFrame
    fn by_agg(
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

        r_result_list(self.0.unnest(names).map(|s| DataFrame(s)))
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
            std::ptr::swap_nonoverlapping(stream_out_ptr, &mut stream as *mut arrow::ffi::ArrowArrayStream, 1);
        }
    }
}
use crate::utils::wrappers::null_to_opt;
impl DataFrame {
    fn to_list_result(&self) -> Result<Robj, pl::PolarsError> {
        //convert DataFrame to Result of to R vectors, error if DataType is not supported
        let robj_vec_res: Result<Vec<Robj>, _> =
            self.0.iter().map(|s| pl_series_to_list(s, true)).collect();

        //rewrap Ok(Vec<Robj>) as R list
        let robj_list_res = robj_vec_res.map(|vec_robj| {
            r!(extendr_api::prelude::List::from_names_and_values(
                self.columns(),
                vec_robj
            ))
        });

        robj_list_res
    }
}

#[derive(Clone, Debug)]
#[extendr]
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
    use rexpr;
    use rseries;
    use read_csv;
    use read_parquet;
    use rdatatype;
    use rlazyframe;
    use rlib;
    impl DataFrame;
    impl VecDataFrame;
}
