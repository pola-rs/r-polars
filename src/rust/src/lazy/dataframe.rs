use crate::concurrent::{handle_thread_r_requests, PolarsBackgroundHandle};
use crate::lazy::dsl::*;
use crate::rdatatype::new_join_type;
use crate::utils::r_result_list;
use crate::utils::try_f64_into_u32;
use crate::utils::try_f64_into_usize;
use crate::robj_to;
use extendr_api::prelude::*;
use polars::prelude as pl;

#[allow(unused_imports)]
use std::result::Result;

#[derive(Clone)]
pub struct LazyFrame(pub pl::LazyFrame);

#[extendr]
impl LazyFrame {
    fn print(&self) -> Self {
        rprintln!("{}", self.0.describe_plan());
        self.clone()
    }

    pub fn describe_plan(&self) {
        rprintln!("{}", self.0.describe_plan());
    }

    pub fn describe_optimized_plan(&self) -> List {
        let result = self.0.describe_optimized_plan().map(|opt_plan| {
            rprintln!("{}", opt_plan);
        });
        r_result_list(result.map_err(|err| format!("{:?}", err)))
    }

    pub fn collect_background(&self) -> PolarsBackgroundHandle {
        PolarsBackgroundHandle::new(self)
    }

    pub fn collect(&self) -> List {
        let result = handle_thread_r_requests(self.clone().0).map_err(|err| {
            //improve err messages
            let err_string = match err {
                pl::PolarsError::InvalidOperation(polars::error::ErrString::Owned(x)) => {
                    format!("Something (Likely a Column) named {:?} was not found", x)
                }
                x => format!("{:?}", x),
            };

            format!("when calling $collect() on LazyFrame:\n{}", err_string)
        });
        r_result_list(result)
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

    fn limit(&self, n: f64) -> List {
        r_result_list(
            try_f64_into_u32(n)
                .map(|n| LazyFrame(self.0.clone().limit(n)))
                .map_err(|err| format!("limit: {}", err)),
        )
    }

    fn tail(&self, n: Robj) -> Result<LazyFrame, String> {
        Ok(LazyFrame(self.0.clone().tail(robj_to!(u32, n)?)))
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

    fn with_columns(&self, exprs: &ProtoExprArray) -> LazyFrame {
        LazyFrame(self.0.clone().with_columns(pra_to_vec(exprs, "select")))
    }

    fn with_column(&self, expr: &Expr) -> LazyFrame {
        LazyFrame(self.0.clone().with_column(expr.0.clone()))
    }

    fn join(
        &self,
        other: &LazyFrame,
        left_on: &ProtoExprArray,
        right_on: &ProtoExprArray,
        how: &str,
        suffix: &str,
        allow_parallel: bool,
        force_parallel: bool,
    ) -> LazyFrame {
        let ldf = self.0.clone();
        let other = other.0.clone();
        let left_on = pra_to_vec(left_on, "select");
        let right_on = pra_to_vec(right_on, "select");
        let how = new_join_type(how);

        LazyFrame(
            ldf.join_builder()
                .with(other)
                .left_on(left_on)
                .right_on(right_on)
                .allow_parallel(allow_parallel)
                .force_parallel(force_parallel)
                .how(how)
                .suffix(suffix)
                .finish(),
        )
    }
}

#[derive(Clone)]
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

    fn head(&self, n: f64) -> List {
        r_result_list(
            try_f64_into_usize(n)
                .map(|n| LazyFrame(self.0.clone().head(Some(n))))
                .map_err(|err| format!("head: {}", err)),
        )
    }

    fn tail(&self, n: f64) -> List {
        r_result_list(
            try_f64_into_usize(n)
                .map(|n| LazyFrame(self.0.clone().tail(Some(n))))
                .map_err(|err| format!("tail: {}", err)),
        )
    }

    // fn apply(&self, robj: Robj, val: f64) -> Robj {
    //     todo!("not done");
    // }
}

extendr_module! {
    mod dataframe;
    impl LazyFrame;
    impl LazyGroupBy;
}
