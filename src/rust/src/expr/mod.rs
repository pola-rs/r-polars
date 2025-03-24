mod array;
mod binary;
mod bitwise;
mod categorical;
mod datetime;
mod general;
mod list;
mod meta;
mod name;
mod rolling;
mod serde;
mod string;
mod r#struct;
use polars::lazy::dsl::Expr;
use savvy::{EnvironmentSexp, savvy};

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
