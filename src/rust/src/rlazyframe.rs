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
    pub fn rprint(&self) {
        rprintln!("{}", self.0.describe_plan());
    }

    pub fn collect(&self) -> Result<Rdataframe, Error> {
        let x = self.clone().0.collect().map_err(wrap_error)?;
        Ok(Rdataframe(x))
    }
}

extendr_module! {
    mod rlazyframe;
    impl Rlazyframe;
}
