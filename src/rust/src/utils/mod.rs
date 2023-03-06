pub mod extendr_concurrent;

pub mod wrappers;
use crate::lazy::dsl::Expr;
use crate::rdatatype::RPolarsDataType;
use extendr_api::prelude::list;

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
                        let rval: Result<Robj> = opt.
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
                            Err(extendr_api::Error::Other("rpolars fail because lambda evaluation failed".to_string()))
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
            .collect::<Result<$ca_type>>()
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
                polars::error::ErrString::Owned(format!("Strategy named not found: {}", e)),
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
const MSG_INTEGERISH_MAX: &'static str =
    "exceeds double->integer unambigious conversion bound of 2^52 = 4503599627370496.0";
const MSG_INTEGERISH_MIN: &'static str =
    "exceeds double->integer unambigious conversion bound of -(2^52)= -4503599627370496.0";
const MSG_NAN: &'static str = "the value cannot be NaN";
const MSG_NO_LESS_ONE: &'static str = "cannot be less than one";

pub fn try_f64_into_usize_no_zero(x: f64) -> std::result::Result<usize, String> {
    match x {
        _ if x.is_nan() => Err(MSG_NAN.to_string()),
        _ if x < 1.0 => Err(format!("the value {} {}", x, MSG_NO_LESS_ONE)),
        _ if x > R_MAX_INTEGERISH => Err(format!("the value {} {}", x, MSG_INTEGERISH_MAX)),
        _ if x > USIZE_MAX_INTO_F64 => Err(format!(
            "the value {} cannot exceed usize::MAX {}",
            x,
            usize::MAX
        )),
        _ => Ok(x as usize),
    }
}

pub fn try_f64_into_usize(x: f64) -> std::result::Result<usize, String> {
    match x {
        _ if x.is_nan() => Err(MSG_NAN.to_string()),
        _ if x < 0.0 => Err(format!("the value {} cannot be less than zero", x)),
        _ if x > R_MAX_INTEGERISH => Err(format!("the value {} {}", x, MSG_INTEGERISH_MAX)),
        _ if x > USIZE_MAX_INTO_F64 => Err(format!(
            "the value {} cannot exceed usize::MAX {}",
            x,
            usize::MAX
        )),
        _ => Ok(x as usize),
    }
}

pub fn try_f64_into_u64(x: f64) -> std::result::Result<u64, String> {
    match x {
        _ if x.is_nan() => Err(MSG_NAN.to_string()),
        _ if x < 0.0 => Err(format!("the value {} cannot be less than zero", x)),
        _ if x > R_MAX_INTEGERISH => Err(format!("the value {} {}", x, MSG_INTEGERISH_MAX)),
        _ => Ok(x as u64),
    }
}

pub fn try_f64_into_i64(x: f64) -> std::result::Result<i64, String> {
    match x {
        _ if x.is_nan() => Err(MSG_NAN.to_string()),
        _ if x < R_MIN_INTEGERISH => Err(format!("the value {} {}", x, MSG_INTEGERISH_MIN)),
        _ if x > R_MAX_INTEGERISH => Err(format!("the value {} {}", x, MSG_INTEGERISH_MAX)),
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
        // )),
        _ => Ok(x as i64),
    }
}

pub fn try_f64_into_u32(x: f64) -> std::result::Result<u32, String> {
    match x {
        _ if x.is_nan() => Err(MSG_NAN.to_string()),
        _ if x < 0.0 => Err(format!("the value {} cannot be less than zero", x)),
        _ if x > U32_MAX_INTO_F64 => Err(format!(
            "the value {} cannot exceed u32::MAX {}",
            x,
            u32::MAX
        )),
        _ => Ok(x as u32),
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

pub fn unpack_r_result_list(robj: extendr_api::Robj) -> std::result::Result<Robj, String> {
    use extendr_api::*;
    if robj.inherits("extendr_result") {
        let l = robj.as_list().unwrap();
        let ok = l.elt(0).unwrap();
        let err = l.elt(1).unwrap();
        match (ok.rtype(), err.rtype()) {
            (Rtype::Null, Rtype::Null) => Ok(ok),
            (Rtype::Null, _) => {
                if let Some(err_msg) = err.as_str() {
                    Err(err_msg.to_string())
                } else {
                    Err(format!("{:?}", err))
                }
            }
            (_, Rtype::Null) => Ok(ok),
            (_, _) => unreachable!("Internal error: failed to unpack r_result_list"),
        }
    } else {
        Ok(robj)
    }
}

pub fn robj_to_char(robj: extendr_api::Robj) -> std::result::Result<char, String> {
    let robj = unpack_r_result_list(robj)?;
    let mut fchar_iter = if let Some(char_str) = robj.as_str() {
        char_str.chars()
    } else {
        "".chars()
    };
    match (fchar_iter.next(), fchar_iter.next()) {
        (Some(x), None) => Ok(x),
        (_, _) => Err(format!("is not a single char string, but {:?}", robj)),
    }
}

pub fn robj_to_string(robj: extendr_api::Robj) -> std::result::Result<String, String> {
    let robj = unpack_r_result_list(robj)?;
    use extendr_api::Length;
    match (robj.as_str(), robj.len()) {
        (Some(x), 1) => Ok(x.to_string()),
        (_, _) => Err(format!("is not a single string, but {:?}", robj)),
    }
}

pub fn robj_to_str<'a>(robj: extendr_api::Robj) -> std::result::Result<&'a str, String> {
    let robj = unpack_r_result_list(robj)?;
    use extendr_api::Length;
    match (robj.as_str(), robj.len()) {
        (Some(x), 1) => Ok(x),
        (_, _) => Err(format!("is not a single string, but {:?}", robj)),
    }
}

pub fn robj_to_usize(robj: extendr_api::Robj) -> std::result::Result<usize, String> {
    let robj = unpack_r_result_list(robj)?;
    use extendr_api::*;
    if robj.rtype() == Rtype::Strings && robj.len() == 1 {
        let us = robj
            .as_str()
            .unwrap_or("empty string")
            .parse::<usize>()
            .map_err(|err| format!("failed parsing {:?} to usize", err));
        return us;
    }
    match (robj.rtype(), robj.len()) {
        (Rtype::Doubles, 1) => robj.as_real(),
        (Rtype::Integers, 1) => robj.as_integer().map(|i| i as f64),
        (_, _) => None,
    }
    .ok_or_else(|| {
        format!(
            "is not a scalar integer or double as required, but {:?}",
            robj
        )
    })
    .and_then(|float| try_f64_into_usize(float))
}

pub fn robj_to_i64(robj: extendr_api::Robj) -> std::result::Result<i64, String> {
    let robj = unpack_r_result_list(robj)?;
    use extendr_api::*;
    match (robj.rtype(), robj.len()) {
        (Rtype::Doubles, 1) => robj.as_real(),
        (Rtype::Integers, 1) => robj.as_integer().map(|i| i as f64),
        (_, _) => None,
    }
    .ok_or_else(|| format!("not a scalar integer or double as required, but {:?}", robj))
    .and_then(|float| try_f64_into_i64(float))
}

pub fn robj_to_u64(robj: extendr_api::Robj) -> std::result::Result<u64, String> {
    let robj = unpack_r_result_list(robj)?;
    use extendr_api::*;
    match (robj.rtype(), robj.len()) {
        (Rtype::Doubles, 1) => robj.as_real(),
        (Rtype::Integers, 1) => robj.as_integer().map(|i| i as f64),
        (_, _) => None,
    }
    .ok_or_else(|| {
        format!(
            "is not a scalar integer or double as required, but {:?}",
            robj
        )
    })
    .and_then(|float| try_f64_into_u64(float))
}

pub fn robj_to_u32(robj: extendr_api::Robj) -> std::result::Result<u32, String> {
    let robj = unpack_r_result_list(robj)?;
    use extendr_api::*;
    match (robj.rtype(), robj.len()) {
        (Rtype::Doubles, 1) => robj.as_real(),
        (Rtype::Integers, 1) => robj.as_integer().map(|i| i as f64),
        (_, _) => None,
    }
    .ok_or_else(|| {
        format!(
            "is not a scalar integer or double as required, but {:?}",
            robj
        )
    })
    .and_then(|float| try_f64_into_u32(float))
}

pub fn robj_to_bool(robj: extendr_api::Robj) -> std::result::Result<bool, String> {
    let robj = unpack_r_result_list(robj)?;
    use extendr_api::*;
    match (robj.rtype(), robj.len()) {
        (Rtype::Logicals, 1) => robj.as_bool(),
        (_, _) => None,
    }
    .ok_or_else(|| format!("is not a single bool as required, but {:?}", robj))
}

pub fn robj_to_rarrow_schema(robj: extendr_api::Robj) -> std::result::Result<Robj, String> {
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
        Err(format!(
            "is not class c('Schema', 'ArrowObject', 'R6') as required, but {:?}",
            robj
        ))
    }
}

pub fn robj_to_rarrow_field(robj: extendr_api::Robj) -> std::result::Result<Robj, String> {
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
        Err(format!(
            "is not class c('Field', 'ArrowObject', 'R6') as required, but {:?}",
            robj
        ))
    }
}

pub fn robj_to_datatype(robj: extendr_api::Robj) -> std::result::Result<RPolarsDataType, String> {
    let res: ExtendrResult<ExternalPtr<RPolarsDataType>> = robj.try_into();
    let ext_dt = res.map_err(|err| format!("not an DataType, because {:?}", err))?;
    Ok(RPolarsDataType(ext_dt.0.clone()))
}

pub fn robj_to_rexpr(robj: extendr_api::Robj) -> std::result::Result<Expr, String> {
    let robj = unpack_r_result_list(robj)?;

    let res = if let Some(str) = robj.as_str() {
        use extendr_api::*;
        let new_col_expr = extendr_api::call!("wrap_e", str).map_err(|err| err.to_string())?;
        let x = robj_to_rexpr(new_col_expr);
        x?
    } else {
        let res: ExtendrResult<ExternalPtr<Expr>> = robj.try_into();
        let ext_expr = res.map_err(|err| format!("not an Expr, because {:?}", err))?;
        Expr(ext_expr.0.clone())
    };

    Ok(res)
}

pub fn list_expr_to_vec_pl_expr(robj: Robj) -> std::result::Result<Vec<pl::Expr>, String> {
    use extendr_api::*;
    let robj = unpack_r_result_list(robj)?;
    let l = robj.as_list().ok_or_else(|| "is not a list".to_string())?;
    let iter = l.iter().map(|(_, robj)| robj_to_rexpr(robj).map(|e| e.0));
    crate::utils::collect_hinted_result::<pl::Expr, String>(l.len(), iter)
}

pub fn iter_pl_expr_to_list_expr<T>(ite: T) -> extendr_api::List
where
    T: IntoIterator<Item = polars::prelude::Expr>,
    T::IntoIter: ExactSizeIterator,
{
    use extendr_api::prelude::*;
    let iter = ite.into_iter().map(|pl_expr| Expr(pl_expr));
    List::from_values(iter)
}

#[macro_export]
macro_rules! robj_to_inner {
    (usize, $a:ident) => {
        crate::utils::robj_to_usize($a)
    };

    (i64, $a:ident) => {
        crate::utils::robj_to_i64($a)
    };

    (u64, $a:ident) => {
        crate::utils::robj_to_u64($a)
    };

    (u32, $a:ident) => {
        crate::utils::robj_to_u32($a)
    };

    (char, $a:ident) => {
        crate::utils::robj_to_char($a)
    };
    (String, $a:ident) => {
        crate::utils::robj_to_string($a)
    };
    (str, $a:ident) => {
        crate::utils::robj_to_str($a)
    };
    (bool, $a:ident) => {
        crate::utils::robj_to_bool($a)
    };

    (Expr, $a:ident) => {
        crate::utils::robj_to_rexpr($a)
    };

    (VecPLExpr, $a:ident) => {
        crate::utils::list_expr_to_vec_pl_expr($a)
    };

    (RPolarsDataType, $a:ident) => {
        crate::utils::robj_to_datatype($a)
    };

    (RField, $a:ident) => {
        crate::utils::robj_to_field($a)
    };

    (RArrow_schema, $a:ident) => {
        crate::utils::robj_to_rarrow_schema($a)
    };

    (RArrow_field, $a:ident) => {
        crate::utils::robj_to_rarrow_field($a)
    };

    (lit, $a:ident) => {
        crate::utils::robj_to_lit($a)
    };
}

//convert any Robj to appropriate rust type with informative error Strings
#[macro_export]
macro_rules! robj_to {
    (Option, $type:ident, $a:ident) => {{
        crate::utils::unpack_r_result_list($a).and_then(|$a| {
            if ($a.is_null()) {
                Ok(None)
            } else {
                Some(
                    crate::robj_to_inner!($type, $a)
                        .map_err(|err| format!("the arg [{}] {}", stringify!($a), err)),
                )
                .transpose()
            }
        })
    }};

    //iterate list and call this macro again on inner objects
    (Vec, $type:ident, $a:ident) => {{
        //unpack raise any R result error
        crate::utils::unpack_r_result_list($a)
            .map_err(|err| format!("the arg [{}] {}", stringify!($a), err))
            .and_then(|x: Robj| {
                //coerce R vectors into list
                let x = if !x.is_list() && x.len() > 1 {
                    extendr_api::call!("as.list", x)
                        .map_err(|err| format!("could not coerce to list: {}", err))?
                } else {
                    x
                };

                if x.is_list() {
                    // convert each element in list to $type
                    let iter = x.as_list().unwrap().iter().enumerate().map(|(i, (_, $a))| {
                        robj_to!($type, $a, format!("element no. [{}] of ", i + 1))
                    });
                    crate::utils::collect_hinted_result::<$type, String>(x.len(), iter)
                } else {
                    // single value without list, convert as is and wrap in a list
                    let $a = x;
                    Ok(vec![robj_to!($type, $a)?])
                }
            })
    }};

    (Map, $type:ident, $a:ident, $f:expr) => {
        crate::robj_to_inner!($type, $a)
            .and_then($f)
            .map_err(|err| format!("the arg [{}] {}", stringify!($a), err))
    };

    ($type:ident, $a:ident) => {
        crate::robj_to_inner!($type, $a)
            .map_err(|err| format!("the arg [{}] {}", stringify!($a), err))
    };

    ($type:ident, $a:ident, $b:expr) => {
        crate::robj_to_inner!($type, $a)
            .map_err(|err| format!("the arg [{}] {}", stringify!($a), err))
            .map_err(|err| format!("{} {}", $b, err))
    };
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
