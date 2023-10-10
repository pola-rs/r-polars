use extendr_api::{extendr, prelude::*, rprintln, Rinternals};
use polars::prelude::{self as pl, IntoLazy};
use std::result::Result;
pub mod read_csv;
pub mod read_ipc;
pub mod read_parquet;
use crate::conversion_r_to_s::robjname2series;
use crate::lazy;
use crate::rdatatype;
use crate::rdatatype::RPolarsDataType;
use crate::robj_to;
use crate::rpolarserr::*;

pub use lazy::dataframe::*;

use crate::conversion_s_to_r::pl_series_to_list;
pub use crate::series::*;

use arrow::datatypes::DataType;
use polars::prelude::ArrowField;
use polars_core::utils::arrow;

use crate::utils::{collect_hinted_result, r_result_list};

use crate::conversion::strings_to_smartstrings;
use polars::frame::explode::MeltArgs;
use polars::prelude::pivot::{pivot, pivot_stable};

pub struct OwnedDataFrameIterator {
    columns: Vec<polars::series::Series>,
    data_type: arrow::datatypes::DataType,
    idx: usize,
    n_chunks: usize,
}

impl OwnedDataFrameIterator {
    pub fn new(df: polars::frame::DataFrame) -> Self {
        let schema = df.schema().to_arrow();
        let data_type = DataType::Struct(schema.fields);
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

    //renamed back to clone
    pub fn clone_see_me_macro(&self) -> DataFrame {
        self.clone()
    }

    #[allow(clippy::should_implement_trait)]
    pub fn default() -> Self {
        DataFrame::new_with_capacity(0)
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
        robjname2series(robj, name)
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

    pub fn with_row_count(&self, name: Robj, offset: Robj) -> RResult<Self> {
        Ok(self
            .0
            .clone()
            .with_row_count(
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

    pub fn frame_equal(&self, other: &DataFrame) -> bool {
        self.0.frame_equal(&other.0)
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

    pub fn select(&self, exprs: Robj) -> RResult<DataFrame> {
        self.lazy().select(exprs)?.collect()
    }

    pub fn with_columns(&self, exprs: Robj) -> RResult<DataFrame> {
        self.lazy().with_columns(exprs)?.collect()
    }

    //used in GroupBy, not DataFrame
    pub fn by_agg(
        &mut self,
        group_exprs: Robj,
        agg_exprs: Robj,
        maintain_order: Robj,
    ) -> RResult<DataFrame> {
        let group_exprs: Vec<pl::Expr> = robj_to!(VecPLExprCol, group_exprs)?;
        let agg_exprs: Vec<pl::Expr> = robj_to!(VecPLExprColNamed, agg_exprs)?;
        let maintain_order = robj_to!(Option, bool, maintain_order)?.unwrap_or(false);
        let lazy_df = self.clone().0.lazy();
        let lgb = if maintain_order {
            lazy_df.groupby_stable(group_exprs)
        } else {
            lazy_df.groupby(group_exprs)
        };
        LazyFrame(lgb.agg(agg_exprs)).collect()
    }

    pub fn to_struct(&self, name: &str) -> Series {
        use pl::IntoSeries;
        let s = self.0.clone().into_struct(name);
        s.into_series().into()
    }

    pub fn unnest(&self, names: Vec<String>) -> RResult<Self> {
        self.lazy().unnest(names)?.collect()
    }

    pub fn export_stream(&self, stream_ptr: &str) {
        let schema = self.0.schema().to_arrow();
        let data_type = DataType::Struct(schema.fields);
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

    pub fn from_arrow_record_batches(rbr: Robj) -> Result<DataFrame, String> {
        Ok(DataFrame(crate::arrow_interop::to_rust::to_rust_df(rbr)?))
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
            .map(DataFrame)
    }

    pub fn pivot_expr(
        &self,
        values: Robj,
        index: Robj,
        columns: Robj,
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
            robj_to!(Vec, String, values)?,
            robj_to!(Vec, String, index)?,
            robj_to!(Vec, String, columns)?,
            robj_to!(bool, sort_columns)?,
            robj_to!(Option, PLExpr, aggregate_expr)?,
            robj_to!(Option, str, separator)?,
        )
        .map_err(polars_to_rpolars_err)
        .map(DataFrame)
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
                robj_to!(usize, n)?,
                robj_to!(bool, with_replacement)?,
                robj_to!(bool, shuffle)?,
                robj_to!(Option, u64, seed)?,
            )
            .map_err(polars_to_rpolars_err)
            .map(DataFrame)
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
                robj_to!(f64, frac)?,
                robj_to!(bool, with_replacement)?,
                robj_to!(bool, shuffle)?,
                robj_to!(Option, u64, seed)?,
            )
            .map_err(polars_to_rpolars_err)
            .map(DataFrame)
    }
}
impl DataFrame {
    pub fn to_list_result(&self) -> Result<Robj, pl::PolarsError> {
        //convert DataFrame to Result of to R vectors, error if DataType is not supported
        let robj_vec_res: Result<Vec<Robj>, _> = self
            .0
            .iter()
            .map(|s| pl_series_to_list(s, true, true))
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
pub struct VecDataFrame(pub Vec<pl::DataFrame>);

#[extendr]
impl VecDataFrame {
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

    impl DataFrame;
    impl VecDataFrame;
}
