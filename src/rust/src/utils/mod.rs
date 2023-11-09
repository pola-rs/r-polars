pub mod extendr_concurrent;

pub mod extendr_helpers;
pub mod wrappers;

use crate::conversion_r_to_s::robjname2series;
use crate::lazy::dsl::Expr;
use crate::rdatatype::RPolarsDataType;
use crate::rpolarserr::{polars_to_rpolars_err, rdbg, rerr, RPolarsErr, RResult, WithRctx};
use crate::series::Series;

use std::any::type_name as tn;
//use std::intrinsics::read_via_copy;
use crate::lazy::dsl::robj_to_col;
use crate::rdataframe::{DataFrame, LazyFrame};
use extendr_api::eval_string_with_params;
use extendr_api::prelude::{list, Result as EResult, Strings};
use extendr_api::Attributes;
use extendr_api::CanBeNA;
use extendr_api::ExternalPtr;
use extendr_api::Result as ExtendrResult;
use extendr_api::R;

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
                Ok(Some(rvalue.inner()))
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
            let val = rint.inner();

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
const I32_MIN_INTO_F64: f64 = i32::MIN as f64;
const I32_MAX_INTO_F64: f64 = i32::MAX as f64;
pub const BIT64_NA_ECODING: i64 = -9223372036854775808i64;

const WITHIN_INT_MAX: &str =
    "cannot exceeds double->integer unambigious conversion bound of 2^52 = 4503599627370496.0";
const WITHIN_INT_MIN: &str =
    "cannot exceeds double->integer unambigious conversion bound of -(2^52)= -4503599627370496.0";
const WITHIN_USIZE_MAX: &str = "cannot exceed the upper bound for usize";
const WITHIN_U32_MAX: &str = "cannot exceed the upper bound for u32 of 4294967295";
const WITHIN_I32_MIN: &str = "cannot exceed the upper bound for i32 of 2147483647";
const WITHIN_I32_MAX: &str = "cannot exceed the upper lower for i32 of -2147483648";
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

pub fn try_f64_into_i32(x: f64) -> RResult<i32> {
    let f_base_err = || rerr().bad_val(rdbg(x));
    match x {
        _ if x.is_nan() => f_base_err().misvalued(NOT_NAN),
        _ if x < I32_MIN_INTO_F64 => f_base_err().misvalued(WITHIN_I32_MIN),
        _ if x > I32_MAX_INTO_F64 => f_base_err().misvalued(WITHIN_I32_MAX),
        _ => Ok(x as i32),
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

pub fn try_i64_into_i32(x: i64) -> RResult<i32> {
    let f_base_err = || rerr().bad_val(rdbg(x));
    match x {
        _ if x < i32::MIN as i64 => f_base_err().misvalued(WITHIN_I32_MIN),
        _ if x > i32::MAX as i64 => f_base_err().misvalued(WITHIN_I32_MAX),
        _ => Ok(x as i32),
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

pub fn inner_unpack_r_result_list(robj: extendr_api::Robj) -> Result<Robj, Robj> {
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

//None if not real or Na.
pub fn robj_bit64_to_opt_i64(robj: Robj) -> Option<i64> {
    robj.as_real()
        .and_then(|v| i64::try_from(v.to_bits()).ok())
        .filter(|val| *val != crate::utils::BIT64_NA_ECODING)
}

pub fn robj_parse_str_to_t<T>(robj: Robj) -> RResult<T>
where
    T: std::str::FromStr,
    <T as std::str::FromStr>::Err: std::error::Error,
{
    Ok(robj.as_str().unwrap_or("<Empty String>").parse::<T>()?)
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

pub fn robj_to_pathbuf(robj: extendr_api::Robj) -> RResult<std::path::PathBuf> {
    Ok(std::path::PathBuf::from(robj_to_string(robj)?))
}

pub fn robj_to_str<'a>(robj: extendr_api::Robj) -> RResult<&'a str> {
    let robj = unpack_r_result_list(robj)?;
    use extendr_api::Length;
    match (robj.as_str(), robj.len()) {
        (Some(x), 1) => Ok(x),
        (_, _) => rerr().bad_robj(&robj).mistyped(tn::<&'a str>()),
    }
}

// This conversion assists conversion of R choice char vec e.g. c("a", "b")
// Only the first element "a" will passed on as String
// conversion error if not a char vec with none-zero length.
// NA is not allowed
// other conversions will use it e.g. robj_to_join_type() or robj_to_closed_window()
pub fn robj_to_rchoice(robj: extendr_api::Robj) -> RResult<String> {
    let robj = unpack_r_result_list(robj)?;
    let robj_clone = robj.clone();
    let s_res: EResult<Strings> = robj.try_into();
    let opt_str = s_res.map(|s| s.iter().next().map(|rstr| rstr.clone()));
    match opt_str {
        // NA_CHARACTER not allowed as first element return error
        Ok(Some(rstr)) if rstr.is_na() => {
            Err(RPolarsErr::new().notachoice("NA_character_ is not allowed".into()))
        }

        // At least one string, return first string
        Ok(Some(rstr)) => Ok(rstr.to_string()),

        // Not character vector, return Error
        Err(_extendr_err) => {
            //let rpolars_err: RPolarsErr = _extendr_err.into(); extendr error not that helpful
            Err(RPolarsErr::new().notachoice("input is not a character vector".into()))
        }

        // An empty chr vec, return Error
        Ok(None) => Err(RPolarsErr::new().notachoice("character vector has zero length".into())),
    }
    .map_err(|err| err.bad_robj(robj_clone))
}

pub fn robj_to_usize(robj: extendr_api::Robj) -> RResult<usize> {
    robj_to_u64(robj).and_then(try_u64_into_usize)
}

pub fn robj_to_utf8_byte(robj: extendr_api::Robj) -> RResult<u8> {
    let mut utf8_byte_iter = robj_to_str(robj)?.as_bytes().iter();
    match (utf8_byte_iter.next(), utf8_byte_iter.next()) {
        (Some(s), None) => Ok(*s),
        (None, None) => rerr().plain("cannot extract single byte from empty string"),
        (Some(_), Some(_)) => rerr().plain("multi byte-string not allowed"),
        (None, Some(_)) => unreachable!("the iter() cannot yield Some after None(depleted)"),
    }
}

pub fn robj_to_quote_style(robj: Robj) -> RResult<pl::QuoteStyle> {
    match robj_to_str(robj.clone())? {
        "always" => Ok(pl::QuoteStyle::Always),
        "necessary" => Ok(pl::QuoteStyle::Necessary),
        "non_numeric" => Ok(pl::QuoteStyle::NonNumeric),
        "never" => Ok(pl::QuoteStyle::Never),
        _ => rerr()
            .plain(
                "`quote_style` should be one of 'always', 'necessary', 'non_numeric', or 'never'.",
            )
            .bad_robj(&robj),
    }
}

fn err_no_nan<T>() -> RResult<T> {
    rerr().plain("any NA value is not allowed here".to_string())
}

fn err_no_scalar<T>() -> RResult<T> {
    rerr().plain("only a scalar value is allowed here (length = 1)")
}

pub fn robj_to_i64(robj: extendr_api::Robj) -> RResult<i64> {
    let robj = unpack_r_result_list(robj)?;
    use extendr_api::*;

    return match (robj.rtype(), robj.len()) {
        (_, 0 | 2..) => Some(err_no_scalar()),
        (Rtype::Strings, 1) => Some(robj_parse_str_to_t(robj.clone())),
        (Rtype::Doubles, 1) if robj.inherits("integer64") => {
            robj_bit64_to_opt_i64(robj.clone()).map(Ok)
        }
        (Rtype::Doubles, 1) => robj.as_real().map(try_f64_into_i64),
        (Rtype::Integers, 1) => robj.as_integer().map(i64::from).map(Ok),

        (_, _) => {
            Some(rerr().plain("does not support this R type for this conversion".to_string()))
        }
    }
    .unwrap_or_else(err_no_nan)
    .bad_robj(&robj)
    .mistyped(tn::<i64>())
    .when("converting into type");
}

pub fn robj_to_i32(robj: extendr_api::Robj) -> RResult<i32> {
    let robj = unpack_r_result_list(robj)?;
    use extendr_api::*;

    return match (robj.rtype(), robj.len()) {
        (_, 0 | 2..) => Some(err_no_scalar()),
        (Rtype::Strings, 1) => Some(robj_parse_str_to_t(robj.clone())),
        (Rtype::Doubles, 1) if robj.inherits("integer64") => {
            robj_bit64_to_opt_i64(robj.clone()).map(try_i64_into_i32)
        }
        (Rtype::Doubles, 1) => robj.as_real().map(try_f64_into_i32),
        (Rtype::Integers, 1) => robj.as_integer().map(i32::from).map(Ok),
        (_, _) => {
            Some(rerr().plain("does not support this R type for this conversion".to_string()))
        }
    }
    .unwrap_or_else(err_no_nan)
    .bad_robj(&robj)
    .mistyped(tn::<i32>())
    .when("converting into type");
}

pub fn robj_to_f64(robj: extendr_api::Robj) -> RResult<f64> {
    let robj = unpack_r_result_list(robj)?;
    use extendr_api::*;

    return match (robj.rtype(), robj.len()) {
        (_, 0 | 2..) => Some(err_no_scalar()),
        (Rtype::Strings, 1) => Some(robj_parse_str_to_t(robj.clone())),
        (Rtype::Doubles, 1) if robj.inherits("integer64") => {
            robj_bit64_to_opt_i64(robj.clone()).map(|v| Ok(v as f64))
        }
        (Rtype::Doubles, 1) => robj.as_real().map(Ok),
        (Rtype::Integers, 1) => robj.as_integer().map(|v| Ok(v as f64)),
        (_, _) => {
            Some(rerr().plain("does not support this R type for this conversion".to_string()))
        }
    }
    .unwrap_or_else(err_no_nan)
    .bad_robj(&robj)
    .mistyped(tn::<f64>())
    .when("converting into type");
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

pub fn robj_to_pl_duration_string(robj: extendr_api::Robj) -> RResult<String> {
    let robj = unpack_r_result_list(robj)?;
    let robj_clone = robj.clone(); //reserve shallowcopy for writing err msg

    use extendr_api::*;
    let pl_duration_robj = unpack_r_eval(R!("polars:::result(polars:::as_pl_duration({{robj}}))"))
        .bad_robj(&robj_clone)
        .mistyped("String")
        .when("preparing a polars duration string")?;

    robj_to_string(pl_duration_robj)
        .plain("internal error in as_pl_duration: did not return a string")
}

//this function is used to convert and Rside Expr into rust side Expr
// wrap_e allows to also convert any allowed non Exp
pub fn robj_to_rexpr(robj: extendr_api::Robj, str_to_lit: bool) -> RResult<Expr> {
    let robj = unpack_r_result_list(robj)?;
    let robj_clone = robj.clone(); //reserve shallowcopy for writing err msg

    //use R side wrap_e to convert any R value into Expr or
    internal_rust_wrap_e(robj, str_to_lit)
        .bad_robj(&robj_clone)
        .plain("cannot be converted into an Expr")
}

// used in conjunction with R!("...")
pub fn unpack_r_eval(res: extendr_api::Result<Robj>) -> RResult<Robj> {
    unpack_r_result_list(res.map_err(|err| {
        extendr_api::Error::Other(format!("internal_error calling R from rust: {:?}", err))
    })?)
}

pub fn r_expr_to_rust_expr(robj_expr: Robj) -> RResult<Expr> {
    let res: ExtendrResult<extendr_api::ExternalPtr<Expr>> = robj_expr.clone().try_into();
    Ok(Expr(
        res.bad_robj(&robj_expr)
            .mistyped(tn::<Expr>())
            .when("converting R extptr PolarsExpr to rust RExpr")
            .plain("internal error: could not convert R Expr (externalptr) to rust Expr")?
            .0
            .clone(),
    ))
}

fn internal_rust_wrap_e(robj: Robj, str_to_lit: bool) -> RResult<Expr> {
    use extendr_api::*;

    if !str_to_lit && robj.rtype() == Rtype::Strings {
        robj_to_col(robj, extendr_api::NULL.into())
    } else {
        Expr::lit(robj)
    }
}

pub fn robj_to_lazyframe(robj: extendr_api::Robj) -> RResult<LazyFrame> {
    let robj = unpack_r_result_list(robj)?;
    let rv = rdbg(&robj);

    // closure to allow ?-convert extendr::Result to RResult
    let res = || -> RResult<LazyFrame> {
        match () {
            // allow input as a DataFrame
            _ if robj.inherits("DataFrame") => {
                let extptr_df: ExternalPtr<DataFrame> = robj.try_into()?;
                Ok(extptr_df.lazy())
            }
            _ if robj.inherits("LazyFrame") => {
                let lf: ExternalPtr<LazyFrame> = robj.try_into()?;
                let lf = LazyFrame(lf.0.clone());
                Ok(lf)
            }
            _ if robj.inherits("data.frame") => {
                let df = unpack_r_eval(R!("polars:::result(pl$DataFrame({{robj}}))"))?;
                let extptr_df: ExternalPtr<DataFrame> = df.try_into()?;
                Ok(extptr_df.lazy())
            }
            _ => Ok(DataFrame::new_with_capacity(1)
                .lazy()
                .0
                .select(&[robj_to_rexpr(robj, true)?.0]))
            .map(LazyFrame),
        }
    }();

    res.bad_val(rv).mistyped(tn::<LazyFrame>())
}

pub fn robj_to_dataframe(robj: extendr_api::Robj) -> RResult<DataFrame> {
    let robj = unpack_r_result_list(robj)?;
    let robj_clone = robj.clone();

    // closure to allow ?-convert extendr::Result to RResult
    let res = || -> RResult<DataFrame> {
        match () {
            // allow input as a DataFrame
            _ if robj.inherits("DataFrame") => {
                let extptr_df: ExternalPtr<DataFrame> = robj.try_into()?;
                Ok(extptr_df.0.clone())
            }
            _ if robj.inherits("data.frame") => {
                let df = unpack_r_eval(R!("polars:::result(pl$DataFrame({{robj}}))"))?;
                let extptr_df: ExternalPtr<DataFrame> = df.try_into()?;
                Ok(extptr_df.0.clone())
            }
            _ => DataFrame::new_with_capacity(1)
                .lazy()
                .0
                .select(&[robj_to_rexpr(robj, true)?.0])
                .collect(),
        }
        .map(DataFrame)
        .map_err(polars_to_rpolars_err)
    }();

    res.bad_val(rdbg(robj_clone))
        .plain("could not be converted into a DataFrame")
}

pub fn robj_to_series(robj: extendr_api::Robj) -> RResult<Series> {
    let robj = unpack_r_result_list(robj)?;
    let robj_clone = robj.clone();
    robjname2series(robj, "")
        .map(Series)
        .map_err(polars_to_rpolars_err)
        .bad_val(rdbg(robj_clone))
        .plain("could not be converted into a DataFrame")
}

pub fn list_expr_to_vec_pl_expr(
    robj: Robj,
    str_to_lit: bool,
    named: bool,
) -> RResult<Vec<pl::Expr>> {
    use extendr_api::*;
    let robj = unpack_r_result_list(robj)?;
    let l = robj
        .as_list()
        .ok_or(RPolarsErr::new())
        .mistyped(tn::<List>())?;
    let mut arg_names = robj.names().unwrap_or(StrIter::default());
    let iter = l.iter().enumerate().map(|(i, (_, robj))| {
        let name = arg_names.next().unwrap_or("");
        robj_to_rexpr(robj.clone(), str_to_lit)
            .when(format!("converting element {} into an Expr", i + 1))
            .map(|e| {
                if name != "" && named {
                    e.0.alias(name)
                } else {
                    e.0
                }
            })
    });
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

    (f64, $a:ident) => {
        $crate::utils::robj_to_f64($a)
    };

    (i64, $a:ident) => {
        $crate::utils::robj_to_i64($a)
    };

    (i32, $a:ident) => {
        $crate::utils::robj_to_i32($a)
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

    (Utf8Byte, $a:ident) => {
        $crate::utils::robj_to_utf8_byte($a)
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
    (pl_duration_string, $a:ident) => {
        $crate::utils::robj_to_pl_duration_string($a)
    };
    (pl_duration, $a:ident) => {
        $crate::utils::robj_to_pl_duration_string($a).map(|s| pl::Duration::parse(s.as_str()))
    };
    (timeunit, $a:ident) => {
        $crate::rdatatype::robj_to_timeunit($a)
    };
    (ClosedWindow, $a:ident) => {
        $crate::rdatatype::robj_to_closed_window($a)
    };
    (new_quantile_interpolation_option, $a:ident) => {
        $crate::rdatatype::new_quantile_interpolation_option($a)
    };

    (bool, $a:ident) => {
        $crate::utils::robj_to_bool($a)
    };

    (Raw, $a:ident) => {
        $crate::utils::robj_to_binary_vec($a)
    };

    (Series, $a:ident) => {
        $crate::utils::robj_to_series($a)
    };

    (PLSeries, $a:ident) => {
        $crate::utils::robj_to_series($a).map(|ok| ok.0)
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

    (PLExprCol, $a:ident) => {
        $crate::utils::robj_to_rexpr($a, false).map(|ok| ok.0)
    };

    (VecPLExpr, $a:ident) => {
        $crate::utils::list_expr_to_vec_pl_expr($a, true, false)
    };

    (VecPLExprNamed, $a:ident) => {
        $crate::utils::list_expr_to_vec_pl_expr($a, true, true)
    };

    (VecPLExprCol, $a:ident) => {
        $crate::utils::list_expr_to_vec_pl_expr($a, false, false)
    };

    (VecPLExprColNamed, $a:ident) => {
        $crate::utils::list_expr_to_vec_pl_expr($a, false, true)
    };

    (RPolarsDataType, $a:ident) => {
        $crate::utils::robj_to_datatype($a)
    };
    (PLPolarsDataType, $a:ident) => {
        $crate::utils::robj_to_datatype($a).map(|dt| dt.0)
    };

    (RField, $a:ident) => {
        $crate::utils::robj_to_field($a)
    };

    (LazyFrame, $a:ident) => {
        $crate::utils::robj_to_lazyframe($a)
    };

    (PLLazyFrame, $a:ident) => {
        $crate::utils::robj_to_lazyframe($a).map(|lf| lf.0)
    };

    (DataFrame, $a:ident) => {
        $crate::utils::robj_to_dataframe($a)
    };

    (PLDataFrame, $a:ident) => {
        $crate::utils::robj_to_dataframe($a).map(|lf| lf.0)
    };

    (QuoteStyle, $a:ident) => {
        $crate::utils::robj_to_quote_style($a)
    };

    (JoinType, $a:ident) => {
        $crate::rdatatype::robj_to_join_type($a)
    };

    (PathBuf, $a:ident) => {
        $crate::utils::robj_to_pathbuf($a)
    };

    (RArrow_schema, $a:ident) => {
        $crate::utils::robj_to_rarrow_schema($a)
    };

    (RArrow_field, $a:ident) => {
        $crate::utils::robj_to_rarrow_field($a)
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
                Some(
                    $crate::robj_to_inner!($type, $a)
                        .bad_arg(stringify!($a).replace("dotdotdot", " `...` ")),
                )
                .transpose()
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
                    .bad_arg(stringify!($a).replace("dotdotdot", " `...` "))?
            } else {
                x
            };
            if x.is_list() {
                // convert each element in list to $type
                let iter =
                    x.as_list().unwrap().iter().enumerate().map(|(i, (_, $a))| {
                        robj_to!($type, $a, format!("element no. [{}] ", i + 1))
                    });

                //TODO reintroduce collect_hinted_result_rerr as trait not a generic
                //generic forces $type to be a literal type in scrop not e.g. PLExprCol
                //$crate::utils::collect_hinted_result_rerr::<$type>(x.len(), iter)
                let x: Result<_, _> = iter.collect();
                x
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
            .bad_arg(stringify!($a).replace("dotdotdot", " `...` "))
    }};

    ($type:ident, $a:ident) => {{
        use $crate::rpolarserr::WithRctx;
        $crate::robj_to_inner!($type, $a).bad_arg(stringify!($a).replace("dotdotdot", " `...` "))
    }};

    ($type:ident, $a:ident, $b:expr) => {{
        use $crate::rpolarserr::WithRctx;
        $crate::robj_to_inner!($type, $a)
            .hint($b)
            .bad_arg(stringify!($a).replace("dotdotdot", " `...` "))
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

//keep error simple to interface with other libs
pub fn robj_str_ptr_to_usize(robj: &Robj) -> RResult<usize> {
    || -> RResult<usize> {
        let str: &str = robj
            .as_str()
            .ok_or(RPolarsErr::new().plain("robj str ptr not a str".into()))?;
        let us: usize = str.parse()?;
        Ok(us)
    }()
    .when("converting robj str pointer to usize")
}

pub fn usize_to_robj_str(us: usize) -> Robj {
    format!("{us}").into()
}
