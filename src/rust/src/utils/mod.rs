pub mod extendr_concurrent;

pub mod wrappers;
use crate::lazy::dsl::Expr;
use crate::rdatatype::RPolarsDataType;
use crate::rpolarserr::{rdbg, rerr, RPolarsErr, RResult, WithRctx};
use extendr_api::prelude::list;
use std::any::type_name as tn;
//use std::intrinsics::read_via_copy;
use extendr_api::Attributes;
use extendr_api::ExternalPtr;
use extendr_api::Result as ExtendrResult;
use polars::prelude as pl;

//macro to translate polars NULLs and  emulate R NA value of any type
#[macro_export]
macro_rules! make_r_na_fun {

    (bool $rfun:expr) => {
        R!("function(f) {function() f(NA)}")
            .unwrap()
            .as_function()
            .expect("failed to make function")
    };
    (f64 $rfun:expr) => {
        R!("function(f) {function() f(NA_real_)}")
            .unwrap()
            .as_function()
            .expect("failed to make function")
    };
    (f32 $rfun:expr) => {make_r_na_fun!(f64 $rfun)};

    (i32 $rfun:expr) => {
        R!("function(f) {function() f(NA_integer_)}")
            .unwrap()
            .as_function()
            .expect("failed to make function")
    };
    (i64 $rfun:expr) => {make_r_na_fun!(i32 $rfun)};
    (list $rfun:expr) => {make_r_na_fun!(i32 $rfun)};
    (i16 $rfun:expr) => {make_r_na_fun!(i32 $rfun)};
    (i8 $rfun:expr) => {make_r_na_fun!(i32 $rfun)};
    (f32 $rfun:expr) => {make_r_na_fun!(f64 $rfun)};

    (utf8 $rfun:expr) => {
        R!("function(f) {function() f(NA_character_)}")
            .unwrap()
            .as_function()
            .expect("failed to make function")
    };
}

//build iterator which handle any polars Series input type and convert to R type and evaluate
#[macro_export]
macro_rules! apply_input {
    ($self:expr, $ca_method_and_inp_type:ident, $rfun:expr, $na_fun:expr) => {
        {
            //wrap lambda in a function passing the corrosponding R NAtype if polars null
            //assumes mut na_fun: Function (extendr_api struct) is present invoked scope
            //needs to live there as match_arm life-time is too short for iterator
            $na_fun =
                make_r_na_fun!($ca_method_and_inp_type rfun)
                .call(pairlist!(f = $rfun.clone()))
                .expect("internal errror: failed eval na function")
                .as_function()
                .expect("internal error: failed ret wrap");

            // produce iterator which yield returns from the lambda
            Box::new(
                $self
                    .$ca_method_and_inp_type() //to chunkedarray(ca)
                    .unwrap()
                    .into_iter()
                    .map(|opt| {
                        let rval: extendr_api::Result<Robj> = opt.
                        map_or_else(
                            ||  $na_fun.call(pairlist!()),
                            |x| $rfun.call(pairlist!(x))
                        );//.expect("fail r eval");
                        let y = rval.ok();
                        y
                    })
            )
        }
    };
}

//convert extendr_api abstraction of R value into rust Result<Option<type>>>
//result because evaluation could have failed
//option because value could have been missing
#[macro_export]
macro_rules! handle_type {
    (Doubles $opt_value:expr) => {{
        if let Some(rvalue) = $opt_value {
            //handle R encoding
            if rvalue.is_na() {
                Ok(None)
            } else {
                Ok(Some(rvalue.0))
            }
        } else {
            return Err(extendr_api::Error::Other(
                "zero length output not allowed".to_string(),
            ));
        }
    }};
    (Integers $opt_value:expr) => {{
        if let Some(rint) = $opt_value {
            //those with at least one return value
            let val = rint.0;

            if val == R_INT_NA_ENC {
                //those where value is R_NA_int, return NULL/none to polars
                Ok(None)
            } else {
                //those where the value is non NA
                Ok(Some(val))
            }
        } else {
            //those with no zero length return
            return Err(extendr_api::Error::Other(
                "zero length int not allowed".to_string(),
            ));
        }
    }};

    (Strings $opt_value:expr) => {{
        if let Some(rstr) = $opt_value {
            //those with at least one return value
            if rstr.is_na() {
                Ok(None)
            } else {
                Ok(Some(rstr.as_str().to_string()))
            }
        } else {
            //those with no zero length return
            return Err(extendr_api::Error::Other(
                "zero length int not allowed".to_string(),
            ));
        }
    }};

    (Logicals $opt_value:expr) => {{
        if let Some(rbool) = $opt_value {
            //those with at least one return value
            if rbool.is_na() {
                Ok(None)
            } else {
                Ok(Some(rbool.is_true()))
            }
        } else {
            //those with no zero length return
            return Err(extendr_api::Error::Other(
                "zero length int not allowed".to_string(),
            ));
        }
    }};
}

//consume iterator of robj returns from lambda and collect as poalrs Series
#[macro_export]
macro_rules! apply_output {

    ($r_iter:expr, $strict_downcast:expr, $allow_fail_eval:expr, $dc_type:ident, $ca_type:ty) => {
        //across all inputs
        $r_iter
            .map(|res_robj: Option<Robj>| {

                //for those with non failed R evaluation
                res_robj.map_or_else(
                    || {
                        if($allow_fail_eval) {
                            Ok(None)
                        } else {
                            Err(extendr_api::Error::Other("polars error because lambda evaluation failed".to_string()))
                        }

                    },

                    //unpack a return value from R
                    |robj| {

                        //downcast into expected type
                        let opt_vals: Option<$dc_type> = robj.clone().try_into().ok();

                        //check if successful downcast
                        if opt_vals.is_none() {
                            if $strict_downcast {
                                return Err(extendr_api::Error::Other(
                                    format!("a lambda returned {:?} and not the expected {} .  Try strict=FALSE, or change expected output type or rewrite lambda", robj.rtype() ,stringify!($dc_type))
                                ))
                            } else {
                                //return null to polars
                                return Ok(None);
                            }
                        }

                        //downcast worked, get first val
                        let vals = opt_vals.unwrap();
                        let opt_value = vals
                            .iter()
                            .next(); //could be none if return length is 0
                            //any other elements above 1 are never checked

                        //handle quircks of each R type and return corrosponding polars type
                        handle_type!($dc_type opt_value)
                    }
                )
            })
            //collect evaluation return on first error or all values ok
            .collect::<extendr_api::Result<$ca_type>>()
            //if all ok collect into serias and rename
            .map(|ca| {
                Series(ca.into_series())
            })
    };
}
//from py-polars conversions

pub fn parse_fill_null_strategy(
    strategy: &str,
    limit: Option<u32>,
) -> pl::PolarsResult<pl::FillNullStrategy> {
    use pl::FillNullStrategy::*;
    let parsed = match strategy {
        "forward" => Forward(limit),
        "backward" => Backward(limit),
        "min" => Min,
        "max" => Max,
        "mean" => Mean,
        "zero" => Zero,
        "one" => One,
        e => {
            return Err(pl::PolarsError::InvalidOperation(
                format!("Strategy named not found: {}", e).into(),
            ))
        }
    };
    Ok(parsed)
}

//R encodes i64/u64 as f64 ...

const R_MAX_INTEGERISH: f64 = 4503599627370496.0;
const R_MIN_INTEGERISH: f64 = -4503599627370496.0;
//const I64_MIN_INTO_F64: f64 = i64::MIN as f64;
//const I64_MAX_INTO_F64: f64 = i64::MAX as f64;
const USIZE_MAX_INTO_F64: f64 = usize::MAX as f64;
const U32_MAX_INTO_F64: f64 = u32::MAX as f64;
pub const BIT64_NA_ECODING: i64 = -9223372036854775808i64;

const WITHIN_INT_MAX: &str =
    "cannot exceeds double->integer unambigious conversion bound of 2^52 = 4503599627370496.0";
const WITHIN_INT_MIN: &str =
    "cannot exceeds double->integer unambigious conversion bound of -(2^52)= -4503599627370496.0";
const WITHIN_USIZE_MAX: &str = "cannot exceed the upper bound for usize";
const WITHIN_U32_MAX: &str = "cannot exceed the upper bound for u32 of 4294967295";
const WITHIN_U8_MAX: &str = "cannot exceed the upper bound for u8 of 255";
const NOT_NAN: &str = "cannot be NaN";
const NO_LESS_THAN_ONE: &str = "cannot be less than one";
const NO_LESS_THAN_ZERO: &str = "cannot be less than zero";

pub fn try_f64_into_usize_no_zero(x: f64) -> RResult<usize> {
    let base_err = rerr().bad_val(rdbg(x));
    match x {
        _ if x.is_nan() => base_err.misvalued(NOT_NAN),
        _ if x < 1.0 => base_err.misvalued(NO_LESS_THAN_ONE),
        _ if x > R_MAX_INTEGERISH => base_err.misvalued(WITHIN_INT_MAX),
        _ if x > USIZE_MAX_INTO_F64 => base_err.misvalued(WITHIN_USIZE_MAX),
        _ => Ok(x as usize),
    }
}

pub fn try_f64_into_usize(x: f64) -> RResult<usize> {
    let base_err = rerr().bad_val(rdbg(x));
    match x {
        _ if x.is_nan() => base_err.misvalued(NOT_NAN),
        _ if x < 0.0 => base_err.misvalued(NO_LESS_THAN_ZERO),
        _ if x > R_MAX_INTEGERISH => base_err.misvalued(WITHIN_INT_MAX),
        _ if x > USIZE_MAX_INTO_F64 => base_err.misvalued(WITHIN_USIZE_MAX),
        _ => Ok(x as usize),
    }
}

pub fn try_f64_into_u64(x: f64) -> RResult<u64> {
    let base_err = rerr().bad_val(rdbg(x));
    match x {
        _ if x.is_nan() => base_err.misvalued(NOT_NAN),
        _ if x < 0.0 => base_err.misvalued(NO_LESS_THAN_ZERO),
        _ if x > R_MAX_INTEGERISH => base_err.misvalued(WITHIN_INT_MAX),
        _ => Ok(x as u64),
    }
}

pub fn try_f64_into_i64(x: f64) -> RResult<i64> {
    let base_err = rerr().bad_val(rdbg(x));
    match x {
        _ if x.is_nan() => base_err.misvalued(NOT_NAN),
        _ if x < R_MIN_INTEGERISH => base_err.misvalued(WITHIN_INT_MIN),
        _ if x > R_MAX_INTEGERISH => base_err.misvalued(WITHIN_INT_MAX),
        // should not matter
        // _ if x > I64_MAX_INTO_F64 => Err(format!(
        //     "the value {} cannot exceed i64::MAX {}",
        //     x,
        //     i64::MAX
        // )),
        // _ if x < I64_MIN_INTO_F64 => Err(format!(
        //     "the value {} cannot exceed i64::MIN {}",
        //     x,
        //     i64::MIN
        // ))
        _ => Ok(x as i64),
    }
}

pub fn try_f64_into_u32(x: f64) -> RResult<u32> {
    let base_err = rerr().bad_val(rdbg(x));
    match x {
        _ if x.is_nan() => base_err.misvalued(NOT_NAN),
        _ if x < 0.0 => base_err.misvalued(NO_LESS_THAN_ZERO),
        _ if x > U32_MAX_INTO_F64 => base_err.misvalued(WITHIN_U32_MAX),
        _ => Ok(x as u32),
    }
}

pub fn try_i64_into_u64(x: i64) -> RResult<u64> {
    let base_err = rerr().bad_val(rdbg(x));
    match x {
        _ if x < 0 => base_err.misvalued(NO_LESS_THAN_ZERO),
        _ => Ok(x as u64),
    }
}

pub fn try_i64_into_usize(x: i64) -> RResult<usize> {
    let base_err = rerr().bad_val(rdbg(x));
    match x {
        _ if x < 0 => base_err.misvalued(NO_LESS_THAN_ZERO),
        _ => Ok(x as usize),
    }
}

pub fn try_i64_into_u32(x: i64) -> RResult<u32> {
    let base_err = rerr().bad_val(rdbg(x));
    match x {
        _ if x < 0 => base_err.misvalued(NO_LESS_THAN_ZERO),
        _ if x > u32::MAX as i64 => base_err.misvalued(WITHIN_U32_MAX),
        _ => Ok(x as u32),
    }
}

pub fn try_i64_into_u8(x: i64) -> RResult<u8> {
    let base_err = rerr().bad_val(rdbg(x));
    match x {
        _ if x < 0 => base_err.misvalued(NO_LESS_THAN_ZERO),
        _ if x > u8::MAX as i64 => base_err.misvalued(WITHIN_U8_MAX),
        _ => Ok(x as u8),
    }
}

pub fn try_u64_into_usize(x: u64) -> RResult<usize> {
    let base_err = rerr().bad_val(rdbg(x));
    match x {
        _ if x > usize::MAX as u64 => base_err.misvalued(WITHIN_USIZE_MAX),
        _ => Ok(x as usize),
    }
}

use extendr_api::Robj;
pub fn r_result_list<T, E>(result: Result<T, E>) -> list::List
where
    T: Into<Robj>,
    E: Into<Robj>,
{
    use extendr_api::*;
    result
        .into_robj()
        .as_list()
        .expect("Internal error: failed to restor list")
}

pub fn r_error_list<E>(err: E) -> list::List
where
    E: Into<Robj>,
{
    use extendr_api::*;
    let x = Err::<Robj, E>(err).into_robj();
    x.as_list().expect("Internal error: failed to restor list")
}

pub fn r_ok_list<T>(ok: T) -> list::List
where
    T: Into<Robj>,
{
    use extendr_api::*;
    let x = Ok::<T, Robj>(ok);
    let x = x.into_robj();
    x.as_list().expect("Internal error: failed to restor list")
}

pub fn reinterpret(s: &pl::Series, signed: bool) -> pl::PolarsResult<pl::Series> {
    use pl::*;
    match (s.dtype(), signed) {
        (DataType::UInt64, true) => {
            let ca = s.u64().unwrap();
            Ok(ca.reinterpret_signed().into_series())
        }
        (DataType::UInt64, false) => Ok(s.clone()),
        (DataType::Int64, false) => {
            let ca = s.i64().unwrap();
            Ok(ca.reinterpret_unsigned().into_series())
        }
        (DataType::Int64, true) => Ok(s.clone()),
        _ => Err(PolarsError::ComputeError(
            "reinterpret is only allowed for 64bit integers dtype, use cast otherwise".into(),
        )),
    }
}

fn inner_unpack_r_result_list(robj: extendr_api::Robj) -> Result<Robj, Robj> {
    use extendr_api::*;
    if robj.inherits("extendr_result") {
        let l = robj.as_list().expect("extendr_result is a list");
        let ok = l.elt(0).expect("extendr_result has a 1st element");
        let err = l.elt(1).expect("extendr_result has a 2nd element");
        let inner_res = match err.rtype() {
            Rtype::Null => Ok(ok),
            _ => Err(err),
        };
        inner_res
    } else {
        Ok(robj)
    }
}

//TODO refactor, put step 2 and 3 in a separeate sub function and rename unpack_r_result_list
// then move subfunction to rpolarserr and refactor into a trait conversion

// The aim of this function is to return Ok for Robj which is not an extendr_result Err variant.
// Any err will be converted to a RPolarsErr
// This function is used as guard for many input conversions.
pub fn unpack_r_result_list(robj: extendr_api::Robj) -> RResult<Robj> {
    use crate::rpolarserr::*;
    use extendr_api::*;
    // 1 - join any non-extendr_result with the Ok variant
    let res = inner_unpack_r_result_list(robj);

    // 2 - try upgrade any Robj-error to an Robj-RPolarsErr (upgrade_err is an optional dependency-injection)
    let res = res.map_err(|err| {
        R!("polars:::upgrade_err_internal_ns({{err}})")
            .map_err(|err| format!("internal error while upgrade error: {}", err))
            .unwrap()
    });

    // 3 - Convert any Robj-err to a Robj-RPolarsErr
    let res = res.map_err(|err| {
        if err.inherits("RPolarsErr") {
            //robj was already an external ptr to RPolarsErr, use as is
            unsafe { &mut *err.external_ptr_addr::<RPolarsErr>() }.clone()
        } else {
            //robj was still some other error, upcast err to a string err and wrap in RPolarsErr
            RPolarsErr::new().plain(rdbg(err))
        }
    });

    res
}

pub fn robj_to_char(robj: extendr_api::Robj) -> RResult<char> {
    let robj = unpack_r_result_list(robj)?;
    let mut fchar_iter = if let Some(char_str) = robj.as_str() {
        char_str.chars()
    } else {
        "".chars()
    };
    match (fchar_iter.next(), fchar_iter.next()) {
        (Some(x), None) => Ok(x),
        (_, _) => rerr().bad_robj(&robj).mistyped(tn::<char>()),
    }
}

pub fn robj_to_string(robj: extendr_api::Robj) -> RResult<String> {
    let robj = unpack_r_result_list(robj)?;
    use extendr_api::Length;
    match (robj.as_str(), robj.len()) {
        (Some(x), 1) => Ok(x.to_string()),
        (_, _) => rerr().bad_robj(&robj).mistyped(tn::<String>()),
    }
}

pub fn robj_to_str<'a>(robj: extendr_api::Robj) -> RResult<&'a str> {
    let robj = unpack_r_result_list(robj)?;
    use extendr_api::Length;
    match (robj.as_str(), robj.len()) {
        (Some(x), 1) => Ok(x),
        (_, _) => rerr().bad_robj(&robj).mistyped(tn::<&'a str>()),
    }
}

pub fn robj_to_usize(robj: extendr_api::Robj) -> RResult<usize> {
    robj_to_u64(robj).and_then(try_u64_into_usize)
}

pub fn robj_to_i64(robj: extendr_api::Robj) -> RResult<i64> {
    let robj = unpack_r_result_list(robj)?;
    use extendr_api::*;
    return match (robj.rtype(), robj.len()) {
        (Rtype::Strings, 1) => robj
            .as_str()
            .unwrap_or("<Empty String>")
            .parse::<i64>()
            .ok(),
        //specialized integer64 conversion
        (Rtype::Doubles, 1) if robj.inherits("integer64") => robj
            .as_real()
            .and_then(|v| i64::try_from(v.to_bits()).ok())
            .filter(|val| *val != crate::utils::BIT64_NA_ECODING),
        //from R doubles or integers
        (Rtype::Doubles, 1) => robj.as_real().and_then(|v| try_f64_into_i64(v).ok()),
        (Rtype::Integers, 1) => robj.as_integer().map(i64::from),
        (_, _) => None,
    }
    .ok_or(RPolarsErr::new())
    .bad_robj(&robj)
    .mistyped(tn::<i64>());
}

pub fn robj_to_u64(robj: extendr_api::Robj) -> RResult<u64> {
    robj_to_i64(robj).and_then(try_i64_into_u64)
}

pub fn robj_to_u32(robj: extendr_api::Robj) -> RResult<u32> {
    robj_to_i64(robj).and_then(try_i64_into_u32)
}

pub fn robj_to_u8(robj: extendr_api::Robj) -> RResult<u8> {
    robj_to_i64(robj).and_then(try_i64_into_u8)
}

pub fn robj_to_bool(robj: extendr_api::Robj) -> RResult<bool> {
    let robj = unpack_r_result_list(robj)?;
    robj.as_bool()
        .ok_or(RPolarsErr::new())
        .bad_robj(&robj)
        .mistyped(tn::<bool>())
}

pub fn robj_to_binary_vec(robj: extendr_api::Robj) -> RResult<Vec<u8>> {
    let robj = unpack_r_result_list(robj)?;
    let binary_vec: Vec<u8> = robj
        .as_raw_slice()
        .ok_or(RPolarsErr::new())
        .bad_robj(&robj)
        .mistyped(tn::<Vec<u8>>())?
        .to_vec();
    Ok(binary_vec)
}

pub fn robj_to_rarrow_schema(robj: extendr_api::Robj) -> RResult<Robj> {
    let robj = unpack_r_result_list(robj)?;

    let is_arrow_schema = robj
        .class()
        .map(|striter| {
            striter
                .zip(["Schema", "ArrowObject", "R6"])
                .all(|(x, y)| x.eq(y))
        })
        .unwrap_or(false);

    if is_arrow_schema {
        Ok(robj)
    } else {
        rerr()
            .bad_robj(&robj)
            .mistyped("c('Schema', 'ArrowObject', 'R6')")
    }
}

pub fn robj_to_rarrow_field(robj: extendr_api::Robj) -> RResult<Robj> {
    let robj = unpack_r_result_list(robj)?;

    let is_arrow_schema = robj
        .class()
        .map(|striter| {
            striter
                .zip(["Field", "ArrowObject", "R6"])
                .all(|(x, y)| x.eq(y))
        })
        .unwrap_or(false);
    if is_arrow_schema {
        Ok(robj)
    } else {
        rerr()
            .bad_robj(&robj)
            .mistyped("c('Field', 'ArrowObject', 'R6')")
    }
}

pub fn robj_to_datatype(robj: extendr_api::Robj) -> RResult<RPolarsDataType> {
    let rv = rdbg(&robj);
    let res: ExtendrResult<ExternalPtr<RPolarsDataType>> = robj.try_into();
    let ext_dt = res.bad_val(rv).mistyped(tn::<RPolarsDataType>())?;
    Ok(RPolarsDataType(ext_dt.0.clone()))
}

//this function is used to convert and Rside Expr into rust side Expr
// wrap_e allows to also convert any allowed non Exp
pub fn robj_to_rexpr(robj: extendr_api::Robj, str_to_lit: bool) -> RResult<Expr> {
    let robj = unpack_r_result_list(robj)?;

    //use R side wrap_e to convert any R value into Expr or
    use extendr_api::*;
    let robj_result_expr = R!("polars:::result(polars:::wrap_e({{robj}},{{str_to_lit}}))")
        .map_err(crate::rpolarserr::extendr_to_rpolars_err)
        .plain("internal error: polars:::result failed to catch this error")?;

    // handle any error from wrap_e
    let robj_expr = unpack_r_result_list(robj_result_expr).when("converting R value to expr")?;

    //PolarsExpr -> RExpr
    let res: ExtendrResult<ExternalPtr<Expr>> = robj_expr.clone().try_into();
    let ext_expr = res
        .bad_robj(&robj_expr)
        .mistyped(tn::<Expr>())
        .when("converting R extptr PolarsExpr to rust RExpr")
        .plain("internal error: wrap_e should fail or return an Expr")?;
    Ok(Expr(ext_expr.0.clone()))
}

pub fn robj_to_lazyframe(robj: extendr_api::Robj) -> RResult<crate::rdataframe::LazyFrame> {
    let robj = unpack_r_result_list(robj)?;
    let rv = rdbg(&robj);
    use crate::rdataframe::LazyFrame;
    let res: Result<ExternalPtr<LazyFrame>, _> = robj.try_into();
    let ext_ldf = res.bad_val(rv).mistyped(tn::<LazyFrame>())?;
    Ok(LazyFrame(ext_ldf.0.clone()))
}

pub fn list_expr_to_vec_pl_expr(robj: Robj, str_to_lit: bool) -> RResult<Vec<pl::Expr>> {
    use extendr_api::*;
    let robj = unpack_r_result_list(robj)?;
    let l = robj
        .as_list()
        .ok_or(RPolarsErr::new())
        .mistyped(tn::<List>())?;
    let iter = l
        .iter()
        .map(|(_, robj)| robj_to_rexpr(robj, str_to_lit).map(|e| e.0));
    crate::utils::collect_hinted_result_rerr::<pl::Expr>(l.len(), iter)
}

pub fn iter_pl_expr_to_list_expr<T>(ite: T) -> extendr_api::List
where
    T: IntoIterator<Item = polars::prelude::Expr>,
    T::IntoIter: ExactSizeIterator,
{
    use extendr_api::prelude::*;
    let iter = ite.into_iter().map(Expr);
    List::from_values(iter)
}

#[macro_export]
macro_rules! robj_to_inner {
    (usize, $a:ident) => {
        $crate::utils::robj_to_usize($a)
    };

    (i64, $a:ident) => {
        $crate::utils::robj_to_i64($a)
    };

    (u64, $a:ident) => {
        $crate::utils::robj_to_u64($a)
    };

    (u32, $a:ident) => {
        $crate::utils::robj_to_u32($a)
    };

    (u8, $a:ident) => {
        $crate::utils::robj_to_u8($a)
    };

    (char, $a:ident) => {
        $crate::utils::robj_to_char($a)
    };
    (String, $a:ident) => {
        $crate::utils::robj_to_string($a)
    };
    (str, $a:ident) => {
        $crate::utils::robj_to_str($a)
    };
    (timeunit, $a:ident) => {
        $crate::rdatatype::robj_to_timeunit($a)
    };
    (new_closed_window, $a:ident) => {
        $crate::rdatatype::new_closed_window($a)
    };
    (bool, $a:ident) => {
        $crate::utils::robj_to_bool($a)
    };

    (Raw, $a:ident) => {
        $crate::utils::robj_to_binary_vec($a)
    };

    (Expr, $a:ident) => {
        $crate::utils::robj_to_rexpr($a, true)
    };

    (PLExpr, $a:ident) => {
        $crate::utils::robj_to_rexpr($a, true).map(|ok| ok.0)
    };

    (ExprCol, $a:ident) => {
        $crate::utils::robj_to_rexpr($a, false)
    };

    (VecPLExpr, $a:ident) => {
        $crate::utils::list_expr_to_vec_pl_expr($a, true)
    };

    (VecPLExprCol, $a:ident) => {
        $crate::utils::list_expr_to_vec_pl_expr($a, false)
    };

    (RPolarsDataType, $a:ident) => {
        $crate::utils::robj_to_datatype($a)
    };

    (RField, $a:ident) => {
        $crate::utils::robj_to_field($a)
    };

    (LazyFrame, $a:ident) => {
        $crate::utils::robj_to_lazyframe($a)
    };

    (RArrow_schema, $a:ident) => {
        $crate::utils::robj_to_rarrow_schema($a)
    };

    (RArrow_field, $a:ident) => {
        $crate::utils::robj_to_rarrow_field($a)
    };

    (lit, $a:ident) => {
        $crate::utils::robj_to_lit($a)
    };
}

//convert any Robj to appropriate rust type with informative error Strings
#[macro_export]
macro_rules! robj_to {
    (Option, $type1:ident, $type2:ident, $a:ident) => {{
        $crate::utils::unpack_r_result_list($a).and_then(|$a| {
            if ($a.is_null()) {
                Ok(None)
            } else {
                Some($crate::robj_to!($type1, $type2, $a)).transpose()
            }
        })
    }};

    (Option, $type:ident, $a:ident) => {{
        use $crate::rpolarserr::WithRctx;
        $crate::utils::unpack_r_result_list($a).and_then(|$a| {
            if ($a.is_null()) {
                Ok(None)
            } else {
                Some($crate::robj_to_inner!($type, $a).bad_arg(stringify!($a))).transpose()
            }
        })
    }};

    //iterate list and call this macro again on inner objects
    (Vec, $type:ident, $a:ident) => {{
        use $crate::rpolarserr::WithRctx;
        //unpack raise any R result error
        $crate::utils::unpack_r_result_list($a).and_then(|x: Robj| {
            //coerce R vectors into list
            let x = if !x.is_list() && x.len() != 1 {
                extendr_api::call!("as.list", x)
                    .mistyped(std::any::type_name::<List>())
                    .bad_arg(stringify!($a))?
            } else {
                x
            };
            if x.is_list() {
                // convert each element in list to $type
                let iter = x.as_list().unwrap().iter().enumerate().map(|(i, (_, $a))| {
                    robj_to!($type, $a, format!("element no. [{}] of ", i + 1))
                });
                $crate::utils::collect_hinted_result_rerr::<$type>(x.len(), iter)
            } else {
                // single value without list, convert as is and wrap in a list
                let $a = x;
                Ok(vec![robj_to!($type, $a)?])
            }
        })
    }};

    (Map, $type:ident, $a:ident, $f:expr) => {{
        use $crate::rpolarserr::WithRctx;
        $crate::robj_to_inner!($type, $a)
            .and_then($f)
            .bad_arg(stringify!($a))
    }};

    ($type:ident, $a:ident) => {{
        use $crate::rpolarserr::WithRctx;
        $crate::robj_to_inner!($type, $a).bad_arg(stringify!($a))
    }};

    ($type:ident, $a:ident, $b:expr) => {{
        use $crate::rpolarserr::WithRctx;
        $crate::robj_to_inner!($type, $a)
            .hint($b)
            .bad_arg(stringify!($a))
    }};
}

pub fn collect_hinted_result<T, E>(
    size: usize,
    iter: impl IntoIterator<Item = Result<T, E>>,
) -> Result<Vec<T>, E> {
    let mut new_vec = Vec::with_capacity(size);
    for item in iter {
        new_vec.push(item?);
    }
    Ok(new_vec)
}

pub fn collect_hinted_result_rerr<T>(
    size: usize,
    iter: impl IntoIterator<Item = RResult<T>>,
) -> RResult<Vec<T>> {
    let mut new_vec = Vec::with_capacity(size);
    for item in iter {
        new_vec.push(item?);
    }
    Ok(new_vec)
}
