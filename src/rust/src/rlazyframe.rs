use crate::rdataframe::rexpr::*;
use crate::rdataframe::wrap_errors::*;
use crate::rdataframe::DataFrame;
use extendr_api::prelude::*;
use polars::prelude as pl;
use std::result::Result;

#[derive(Clone)]
#[extendr]
pub struct LazyFrame(pub pl::LazyFrame);

#[extendr]
impl LazyFrame {
    pub fn print(&self) {
        rprintln!("{}", self.0.describe_plan());
    }

    pub fn describe_optimized_plan(&self) -> Result<(), Error> {
        rprintln!("{}", self.0.describe_optimized_plan().map_err(wrap_error)?);
        Ok(())
    }

    pub fn collect(&self) -> Result<DataFrame, Error> {
        let x = self.clone().0.collect().map_err(wrap_error)?;
        Ok(DataFrame(x))
    }

    fn select(&self, exprs: &ProtoExprArray) -> LazyFrame {
        let exprs: Vec<pl::Expr> = exprs
            .0
            .iter()
            .map(|protoexpr| protoexpr.to_rexpr("select").0)
            .collect();

        let new_df = self.clone().0.select(exprs);

        LazyFrame(new_df)
    }

    fn filter(&self, expr: &Expr) -> LazyFrame {
        let new_df = self.clone().0.filter(expr.0.clone());
        LazyFrame(new_df)
    }

    fn groupby(&self, exprs: &ProtoExprArray, maintain_order: bool) -> LazyGroupBy {
        let expr_vec = pra_to_vec(exprs, "select");
        if maintain_order {
            LazyGroupBy(self.0.clone().groupby_stable(expr_vec))
        } else {
            LazyGroupBy(self.0.clone().groupby(expr_vec))
        }
    }
}

#[derive(Clone)]
#[extendr]
pub struct LazyGroupBy(pub pl::LazyGroupBy);

#[extendr]
impl LazyGroupBy {
    fn print(&self) {
        rprintln!(" The insides of this object is a mystery, inspect the lazyframe instead.");
    }

    fn agg(&self, exprs: &ProtoExprArray) -> LazyFrame {
        let expr_vec = pra_to_vec(exprs, "select");
        LazyFrame(self.0.clone().agg(expr_vec))
    }

    fn head(&self, n: i32) -> LazyFrame {
        LazyFrame(self.0.clone().head(Some(n as usize)))
    }

    fn tail(&self, n: i32) -> LazyFrame {
        LazyFrame(self.0.clone().tail(Some(n as usize)))
    }

    // fn apply(&self, robj: Robj, val: f64) -> Robj {
    //     todo!("not done");
    // }
}

extendr_module! {
    mod rlazyframe;
    impl LazyFrame;
    impl LazyGroupBy;
}
