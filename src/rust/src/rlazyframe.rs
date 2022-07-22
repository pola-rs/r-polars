use crate::rdataframe::rexpr::*;
use crate::rdataframe::wrap_errors::*;
use crate::rdataframe::Rdataframe;
use extendr_api::prelude::*;
use polars::prelude as pl;
use std::result::Result;

#[derive(Clone)]
#[extendr]
pub struct Rlazyframe(pub pl::LazyFrame);

#[extendr]
impl Rlazyframe {
    pub fn print(&self) {
        rprintln!("{}", self.0.describe_plan());
    }

    pub fn describe_optimized_plan(&self) -> Result<(), Error> {
        rprintln!("{}", self.0.describe_optimized_plan().map_err(wrap_error)?);
        Ok(())
    }

    pub fn collect(&self) -> Result<Rdataframe, Error> {
        let x = self.clone().0.collect().map_err(wrap_error)?;
        Ok(Rdataframe(x))
    }

    fn select(&mut self, exprs: &ProtoRexprArray) -> Rlazyframe {
        let exprs: Vec<pl::Expr> = exprs
            .0
            .iter()
            .map(|protoexpr| protoexpr.to_rexpr("select").0)
            .collect();

        let new_df = self.clone().0.select(exprs);

        Rlazyframe(new_df)
    }
}

extendr_module! {
    mod rlazyframe;
    impl Rlazyframe;
}
