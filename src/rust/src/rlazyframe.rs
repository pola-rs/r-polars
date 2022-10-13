use crate::rdataframe::rexpr::*;
use crate::rdatatype::new_join_type;
use crate::utils::r_result_list;
use extendr_api::prelude::*;

use crate::concurrent::handle_thread_r_requests;
use polars::prelude as pl;
#[derive(Clone)]
#[extendr]
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
            ()
        });
        r_result_list(result)
    }

    pub fn collect(&self) -> List {
        let result = handle_thread_r_requests(self.clone().0);
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

    fn limit(&self, n: u32) -> LazyFrame {
        // from R side passed n rlang::is_integerish() and within [0;2^32-1]
        // and therefore fully contained in u32. extendr auto converts if f64 or i32
        LazyFrame(self.0.clone().limit(n as u32))
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
