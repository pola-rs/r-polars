use polars::lazy::dsl::Expr as PlExpr;
use crate::lazy::dsl::Expr as ArghExpr;

pub fn r_exprs_to_exprs(r_exprs: Vec<ArghExpr>) -> Vec<PlExpr> {
    // Safety:
    // transparent struct
    unsafe { std::mem::transmute(r_exprs) }
}
