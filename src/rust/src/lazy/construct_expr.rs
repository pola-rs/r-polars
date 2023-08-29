use super::dsl::Expr;
use crate::rpolarserr::RResult;
use crate::utils::{extendr_helpers::robj_inherits, unpack_r_eval};
use extendr_api::{
    eval_string_with_params, Attributes, ExternalPtr, Length, Rinternals, Robj, NULL, R,
};

pub fn robj_to_lit(robj: Robj) -> RResult<Expr> {
    match () {
        _ if robj.is_null() => Expr::lit(NULL.into()),
        _ if robj.inherits("Expr") => {
            let extptr_expr: ExternalPtr<Expr> = robj.try_into()?;
            Ok(Expr(extptr_expr.0.clone()))
        }
        _ if robj.inherits("Series") => Expr::lit(robj),
        _ if robj.len() != 1 || robj_inherits(&robj, ["list", "POSIXct", "PTime", "Date"]) => {
            Expr::lit(unpack_r_eval(R!(
                "polars:::result(polars::pl$Series({{robj}}))"
            ))?)
        }
        _ => Expr::lit(robj),
    }
}
