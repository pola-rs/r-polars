pub mod extendr_concurrent;

pub mod wrappers;
use extendr_api::prelude::list;
use extendr_api::prelude::IntoRobj;
use extendr_api::Attributes;
use extendr_api::Conversions;
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
                            Err(extendr_api::Error::Other("minipolars fail because lambda evaluation failed".to_string()))
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
            return Err(pl::PolarsError::NotFound(polars::error::ErrString::Owned(
                format!("Strategy named not found: {}", e),
            )))
        }
    };
    Ok(parsed)
}

//R encodes i64/u64 as f64 ...
pub fn try_f64_into_usize(x: f64, no_zero: bool) -> std::result::Result<usize, String> {
    if x.is_nan() {
        return Err(String::from("the value cannot be NaN"));
    };
    if no_zero && x < 1.0 {
        return Err(format!("the value {} cannot be less than one", x));
    };
    if x < 0.0 {
        return Err(format!("the value {} cannot be less than zero", x));
    };
    if x > (2f64.powf(52.0f64)) {
        return Err(format!(
            "the value {} exceeds double->integer unambigious conversion bound of 2^52",
            x
        ));
    };
    if x > usize::MAX as f64 {
        return Err(format!(
            "the value {} cannot exceed usize::MAX {}",
            x,
            usize::MAX
        ));
    };
    Ok(x as usize)
}

pub fn try_f64_into_u32(x: f64, no_zero: bool) -> std::result::Result<u32, String> {
    if x.is_nan() {
        return Err(String::from("the value cannot be NaN"));
    };
    if no_zero && x < 1.0 {
        return Err(format!("the value {} cannot be less than one", x));
    };
    if x < 0.0 {
        return Err(format!("the value {} cannot be less than zero", x));
    };
    if x > u32::MAX as f64 {
        return Err(format!(
            "the value {} cannot exceed u32::MAX {}",
            x,
            u32::MAX
        ));
    };
    Ok(x as u32)
}

pub fn try_i64_into_usize(x: i64, no_zero: bool) -> std::result::Result<usize, String> {
    if no_zero && x < 1 {
        return Err(format!("the value {} cannot be less than one", x));
    };
    if x < 0 {
        return Err(format!("the value {} cannot be less than zero", x));
    };
    Ok(x as usize)
}

pub fn r_result_list<T, E>(result: Result<T, E>) -> list::List
where
    T: IntoRobj,
    E: std::fmt::Display,
{
    match result {
        Ok(x) => list!(ok = x.into_robj(), err = extendr_api::NULL),
        Err(x) => list!(ok = extendr_api::NULL, err = x.to_string()),
    }
    .set_class(&["Result"])
    .unwrap()
    .as_list()
    .unwrap()
}

pub fn r_error_list<E>(err: E) -> list::List
where
    E: std::fmt::Display,
{
    list!(ok = extendr_api::NULL, err = err.to_string())
        .set_class(&["Result"])
        .unwrap()
        .as_list()
        .unwrap()
}

pub fn r_ok_list<T>(result: T) -> list::List
where
    T: IntoRobj,
{
    list!(ok = result.into_robj(), err = extendr_api::NULL)
        .set_class(&["Result"])
        .unwrap()
        .as_list()
        .unwrap()
}
