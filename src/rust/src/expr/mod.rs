mod binary;
mod categorical;
mod datetime;
mod general;
mod meta;
mod name;
mod serde;
mod struct_;
use polars::lazy::dsl::Expr;
use savvy::{savvy, EnvironmentSexp, ListSexp, TypedSexp};

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

pub(crate) trait ToExprs {
    fn to_exprs(self) -> Vec<Expr>;
}

impl ToExprs for Vec<PlRExpr> {
    fn to_exprs(self) -> Vec<Expr> {
        // SAFETY: repr is transparent.
        unsafe { std::mem::transmute(self) }
    }
}

pub(crate) trait ToRExprs {
    fn to_rexprs(self) -> Vec<PlRExpr>;
}

impl ToRExprs for Vec<Expr> {
    fn to_rexprs(self) -> Vec<PlRExpr> {
        // SAFETY: repr is transparent.
        unsafe { std::mem::transmute(self) }
    }
}

impl From<EnvironmentSexp> for &PlRExpr {
    fn from(env: EnvironmentSexp) -> Self {
        let ptr = env.get(".ptr").unwrap().unwrap();
        <&PlRExpr>::try_from(ptr).unwrap()
    }
}
