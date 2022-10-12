use extendr_api::{extendr, prelude::*, rprintln, Rinternals};
use polars::prelude::{self as pl, IntoLazy};
use std::result::Result;

pub mod read_csv;
pub mod read_parquet;
pub mod rexpr;
pub mod rseries;

pub use crate::rdatatype::*;
pub use crate::rlazyframe::*;

use super::rlib::*;
use read_csv::*;
use read_parquet::*;
use rexpr::*;
pub use rseries::*;

use crate::utils::r_result_list;

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
        let new_series = robjname2series(&robj, name);
        r_result_list(self.0.with_column(new_series).map(|_| ()))
    }

    //internal use
    fn set_column_from_series(&mut self, x: &Series) -> List {
        let s: pl::Series = x.into(); //implicit clone, cannot move R objects
        r_result_list(self.0.with_column(s).map(|_| ()))
    }

    fn print(&self) {
        rprintln!("{:#?}", self.0);
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
        let iter = self.0.iter().map(|s| DataType(s.dtype().clone()));
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
            self.0.iter().map(series_to_r_vector_pl_result).collect();

        //rewrap Ok(Vec<Robj>) as R list
        let robj_list_res = robj_vec_res.map(|ok| {
            r!(extendr_api::prelude::List::from_names_and_values(
                self.columns(),
                ok
            ))
        });

        r_result_list(robj_list_res)
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
