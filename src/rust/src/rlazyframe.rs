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

    fn select(&self, exprs: &ProtoRexprArray) -> Rlazyframe {
        let exprs: Vec<pl::Expr> = exprs
            .0
            .iter()
            .map(|protoexpr| protoexpr.to_rexpr("select").0)
            .collect();

        let new_df = self.clone().0.select(exprs);

        Rlazyframe(new_df)
    }

    fn filter(&self, expr: &Rexpr) -> Rlazyframe {
        let new_df = self.clone().0.filter(expr.0.clone());
        Rlazyframe(new_df)
    }

    fn groupby(&self, exprs: &ProtoRexprArray) -> Rlazygroupby {
        let expr_vec = pra_to_vec(exprs, "select");
        Rlazygroupby(self.0.clone().groupby(expr_vec))
    }
}

#[derive(Clone)]
#[extendr]
pub struct Rlazygroupby(pub pl::LazyGroupBy);

#[extendr]
impl Rlazygroupby {
    fn print(&self) {
        rprintln!(" The insides of this object is a mystery, inspect the lazyframe instead.");
    }

    fn agg(&self, exprs: &ProtoRexprArray) -> Rlazyframe {
        let expr_vec = pra_to_vec(exprs, "select");
        Rlazyframe(self.0.clone().agg(expr_vec))
    }

    fn head(&self, n: i32) -> Rlazyframe {
        Rlazyframe(self.0.clone().head(Some(n as usize)))
    }

    fn tail(&self, n: i32) -> Rlazyframe {
        Rlazyframe(self.0.clone().tail(Some(n as usize)))
    }
}

extendr_module! {
    mod rlazyframe;
    impl Rlazyframe;
    impl Rlazygroupby;
}
