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

// #[extendr]
// pub fn robj_to_col(name: Robj, dotdot: Robj) -> RResult<Expr> {
//     // let last_type_str = None;
//     // use crate::utils::unpack_r_eval;
//     // let name = if name.inherits("Series") {
//     //     unpack_r_eval(R!(polars:::result({{name}}$to_vector())))?
//     // } else {
//     //     name
//     // };

//     let name = robj_to!(Vec, String, name)?;
//     //let _ddd = robj_to!(Vec, String, dotdot)?;
//     //name.append(&mut ddd);
//     Ok(Expr::cols(name))

//     // match () {
//     //     _ if name.is_char() => {
//     //         let name = robj_to!(Vec, String, name)?;
//     //         //let _ddd = robj_to!(Vec, String, dotdot)?;
//     //         //name.append(&mut ddd);
//     //         Ok(Expr::cols(name))
//     //     }

//     //     _ => todo!(),
//     // }

//     // if ddd.length() > 0 {

//     // }
//     // if res.is_ok() {
//     //     return res;
//     // } else {
//     //     res_dtype = robj_to!(Vec, RPolarsDataType, name);
//     //     if res_dtype.is_ok() {
//     //         return ();
//     //     }
//     // }
//     // let ddd = dotdotdot.as_list().unwrap();
// }

extendr_module! {
    mod construct_expr;
    fn internal_wrap_e;
    fn robj_to_col;
}
