mod binary;
mod categorical;
mod datetime;
mod general;
mod meta;
mod name;
mod serde;
mod struct_;
use polars::lazy::dsl::Expr;
use savvy::{savvy, EnvironmentSexp};

#[savvy]
#[repr(transparent)]
#[derive(Clone)]
pub struct PlRExpr {
    pub inner: Expr,
}

impl From<Expr> for PlRExpr {
    fn from(expr: Expr) -> Self {
        PlRExpr { inner: expr }
    }
}

impl From<EnvironmentSexp> for &PlRExpr {
    fn from(env: EnvironmentSexp) -> Self {
        let ptr = env.get(".ptr").unwrap().unwrap();
        <&PlRExpr>::try_from(ptr).unwrap()
    }
}