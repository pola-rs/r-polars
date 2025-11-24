mod array;
mod binary;
mod bitwise;
mod categorical;
mod datatype;
mod datetime;
mod general;
mod list;
mod meta;
mod name;
mod rolling;
pub mod selector;
mod serde;
mod string;
mod r#struct;
use polars::lazy::dsl::Expr;
use savvy::{EnvironmentSexp, savvy, savvy_err};

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

impl TryFrom<EnvironmentSexp> for &PlRExpr {
    type Error = savvy::Error;

    fn try_from(env: EnvironmentSexp) -> Result<Self, Self::Error> {
        env.get(".ptr")?
            .map(<&PlRExpr>::try_from)
            .transpose()?
            .ok_or(savvy_err!("Invalid PlRExpr object."))
    }
}
