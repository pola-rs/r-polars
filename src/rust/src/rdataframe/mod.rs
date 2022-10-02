use extendr_api::{extendr, prelude::*, rprintln, Rinternals};
use polars::prelude::{self as pl, IntoLazy};
use std::result::Result;

pub mod read_csv;
pub mod read_parquet;
pub mod rexpr;
pub mod rseries;

pub use crate::rdatatype::*;
pub use crate::rlazyframe::*;
use crate::utils::extendr_concurrent::ParRObj;

use crate::utils::extendr_concurrent::ThreadCom;
use crate::CONFIG;

use read_csv::*;
use read_parquet::*;
use rexpr::*;
use rseries::*;

use crate::utils::extendr_concurrent::concurrent_handler;
use crate::utils::r_result_list;
use crate::utils::wrappers::strpointer_to_;

#[extendr]
#[derive(Debug, Clone)]
pub struct DataFrame(pub pl::DataFrame);

fn handle_thread_r_requests(
    self_df: DataFrame,
    exprs: Vec<pl::Expr>,
) -> std::result::Result<DataFrame, Box<dyn std::error::Error>> {
    let res_res_df = concurrent_handler(
        //call this polars code
        move |tc| {
            //use polars and R functions concurrently
            let retval = self_df.0.lazy().select(exprs).collect();

            //drop global ThreadCom clone
            ThreadCom::kill_global(&CONFIG);

            //local threadcom will also be dropped (likely the last tc, unless some polars thread crashed)
            drop(tc);

            //no more tc's, main thread should wake up now by recieving a Disconnect error signal

            //tada return value
            retval
        },
        //out of hot loop call this R code, just retrieve high-level function wrapper from package
        || extendr_api::eval_string("minipolars:::Series_udf_handler").unwrap(),
        //pass any concurrent 'lambda' call from polars to R via main thread
        |(probj, s): (ParRObj, pl::Series), robj: Robj| -> Result<pl::Series, extendr_api::Error> {
            let opt_f = probj.0.as_function().ok_or_else(|| {
                extendr_api::error::Error::Other(format!("this is not a function: {:?}", probj.0))
            }); //user defined function

            let f = opt_f?;

            let series_udf_handler = robj.as_function().ok_or_else(|| {
                extendr_api::error::Error::Other("this is not a function".to_string())
            })?;

            let rseries_ptr = series_udf_handler.call(pairlist!(f = f, rs = Series(s)))?;

            let rseries_ptr_str = rseries_ptr.as_str().ok_or_else(|| {
                extendr_api::error::Error::Other(format!(
                    "failed to run user function because: {:?}",
                    rseries_ptr
                ))
            })?;

            //safety relies on private minipolars:::series_udf_handler only passes Series pointers.
            let x = unsafe {
                let x: &mut Series = strpointer_to_(rseries_ptr_str)?;
                x
            };

            //try into cast robj into point to expected type

            //unwrap to series
            let s = x.clone().0;

            Ok(s)
        },
        &CONFIG,
    );

    let res_df = res_res_df?;

    let new_df = res_df.map_err(|err| err.to_string())?;
    Ok(DataFrame(new_df))
}

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

    fn to_list(&self) -> List {
        //convert DataFrame to Result of to R vectors, error if DataType is not supported
        let robj_vec_res: Result<Vec<Robj>, _> =
            self.0.iter().map(series_to_r_vector_pl_result).collect();

        //rewrap Ok(Vec<Robj>) as R list
        let robj_list_res = robj_vec_res.map(|ok| r!(extendr_api::prelude::List::from_values(ok)));

        r_result_list(robj_list_res)
    }

    fn select(&mut self, exprs: &ProtoExprArray) -> list::List {
        let exprs: Vec<pl::Expr> = pra_to_vec(exprs, "select");
        let self_df = self.clone();
        let res_df = handle_thread_r_requests(self_df, exprs);
        r_result_list(res_df)
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

        let new_df = gb.agg(agg_exprs).collect().map(|df| DataFrame(df));

        r_result_list(new_df)
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
    impl DataFrame;
}
