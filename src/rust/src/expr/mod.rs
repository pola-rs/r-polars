mod general;
use crate::prelude::Wrap;
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

impl From<ListSexp> for Wrap<Vec<Expr>> {
    fn from(list: ListSexp) -> Self {
        let expr_list = list
            .iter()
            .map(|(name, value)| {
                let rexpr = match value.into_typed() {
                    TypedSexp::Environment(e) => <&PlRExpr>::from(e).clone(),
                    _ => unreachable!("Only accept a list of Expr"),
                };
                if name.is_empty() {
                    rexpr.inner
                } else {
                    rexpr.inner.alias(name)
                }
            })
            .collect();
        Wrap(expr_list)
    }
}
