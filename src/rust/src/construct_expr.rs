// replaces wrap_e_legacy, derived from robj_to!

use crate::lazy::dsl::Expr;
use crate::robj_to;
use crate::rpolarserr::*;
use extendr_api::prelude::*;

#[extendr]
pub fn internal_wrap_e(robj: Robj, str_to_lit: Robj) -> RResult<Expr> {
    if robj_to!(bool, str_to_lit)? {
        robj_to!(Expr, robj)
    } else {
        robj_to!(ExprCol, robj)
    }
}

#[extendr]
pub fn robj_to_col(name: Robj) -> RResult<Expr> {
    let vs: Vec<String> = robj_to!(Vec, String, name)?;
    Ok(Expr::cols(vs))
}

extendr_module! {
    mod construct_expr;
    fn internal_wrap_e;
    fn robj_to_col;
}
