use polars::lazy::dsl::Expr as PLExpr;
use crate::lazy::dsl::Expr as ArghExpr;

pub fn r_exprs_to_exprs(r_exprs: Vec<ArghExpr>) -> Vec<PLExpr> {
    // Safety:
    // transparent struct
    unsafe { std::mem::transmute(r_exprs) }
}
