use extendr_api::{extendr, prelude::*, rprintln, Error, Rinternals};
use polars::prelude::{self as pl, IntoLazy};
use std::result::Result;

pub mod read_csv;
pub mod rexpr;
pub mod rseries;
pub mod wrap_errors;
pub use crate::rdatatype::*;
pub use crate::rlazyframe::*;
use crate::utils::extendr_concurrent::ParRObj;
use crate::CONFIG;

use read_csv::*;
use rexpr::*;
use rseries::*;
use wrap_errors::*;

#[extendr]
#[derive(Debug, Clone)]
pub struct Rdataframe(pub pl::DataFrame);

#[extendr]
impl Rdataframe {
    fn clone_extendr(&self) -> Rdataframe {
        self.clone()
    }

    fn new() -> Self {
        let empty_series: Vec<pl::Series> = Vec::new();
        Rdataframe(pl::DataFrame::new(empty_series).unwrap())
    }

    fn lazy(&self) -> Rlazyframe {
        Rlazyframe(self.0.clone().lazy())
    }

    fn new_with_capacity(capacity: i32) -> Self {
        let empty_series: Vec<pl::Series> = Vec::with_capacity(capacity as usize);
        Rdataframe(pl::DataFrame::new(empty_series).unwrap())
    }

    fn set_column_from_robj(&mut self, robj: Robj, name: &str) -> Result<(), Error> {
        let new_series = robjname2series(&robj, name);
        self.0.with_column(new_series).map_err(wrap_error)?;
        Ok(())
    }

    fn set_column_from_rseries(&mut self, x: &Rseries) -> Result<(), Error> {
        let s: pl::Series = x.into(); //implicit clone, cannot move R objects
        self.0.with_column(s).map_err(wrap_error)?;
        Ok(())
    }

    fn print(&self) {
        rprintln!("{:#?}", self.0);
    }

    fn name(&self) -> String {
        self.0.to_string()
    }

    fn colnames(&self) -> Vec<String> {
        self.0.get_column_names_owned()
    }

    fn as_rlist_of_vectors(&self) -> Result<Robj, Error> {
        let x: Result<Vec<Robj>, Error> = self
            .0
            .iter()
            .map(series_to_r_vector_pl_result)
            .map(|x| x.map_err(|e| Error::from(wrap_error(e))))
            .collect();

        Ok(r!(extendr_api::prelude::List::from_values(x?)))
    }

    fn select(&mut self, exprs: &ProtoRexprArray) -> Result<Rdataframe, Error> {
        use crate::utils::extendr_concurrent::concurrent_handler;

        let exprs: Vec<pl::Expr> = pra_to_vec(exprs, "select");

        let self_df = self.clone();

        let new_df = concurrent_handler(
            //call this polars code
            move |_tc| self_df.0.lazy().select(exprs).collect().map_err(wrap_error),
            //out of hot loop call this R code, just retrieve high-level function wrapper from package
            || extendr_api::eval_string("minipolars::polars_series").unwrap(),
            //pass any concurrent 'lambda' call from polars to R via main thread
            |(probj, s): (ParRObj, pl::Series), robj: Robj| -> pl::Series {
                let opt_f = probj.0.as_function(); //user defined function
                let polars_series_wrapper = robj.as_function().unwrap();
                let ps = polars_series_wrapper.call(pairlist!(x = Rseries(s)));
                let robj = opt_f.unwrap().call(pairlist!(s = ps)).unwrap();
                let s: pl::Series = robj.as_real_vector().unwrap().iter().collect();

                s
            },
            &CONFIG,
        )?;

        Ok(Rdataframe(new_df))
    }

    fn groupby_agg(
        &mut self,
        group_exprs: &ProtoRexprArray,
        agg_exprs: &ProtoRexprArray,
    ) -> Result<Rdataframe, Error> {
        let group_exprs: Vec<pl::Expr> = pra_to_vec(group_exprs, "select");
        let agg_exprs: Vec<pl::Expr> = pra_to_vec(agg_exprs, "select");

        let new_df = self
            .clone()
            .0
            .lazy()
            .groupby(group_exprs)
            .agg(agg_exprs)
            .collect()
            .map_err(wrap_error)?;

        Ok(Rdataframe(new_df))
    }
}

extendr_module! {
    mod rdataframe;
    use rexpr;
    use rseries;
    use read_csv;
    use rdatatype;
    use rlazyframe;
    impl Rdataframe;
}
