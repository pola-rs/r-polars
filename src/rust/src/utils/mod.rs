pub mod extendr_concurrent;

pub mod wrappers;

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
                            |x| $rfun.call(pairlist!(x = x))
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

    // (str_spec: $r_iter:expr, $strict_downcast:expr, $allow_fail_eval:expr, $dc_type:ident, $ca_type:ty) => {
    //     //across all inputs
    //     $r_iter
    //         .map(|res_robj: Option<Robj>| {

    //             //for those with non failed R evaluation
    //             res_robj.map_or_else(
    //                 || {
    //                     if($allow_fail_eval) {
    //                         Ok(None)
    //                     } else {
    //                         Err(extendr_api::Error::Other("minipolars fail because lambda evaluation failed".to_string()))
    //                     }

    //                 },

    //                 //unpack a return value from R
    //                 |robj| {

    //                     //downcast into expected type
    //                     let opt_vals: Option<Rstr> = robj.try_into().ok();

    //                     //check if successful downcast
    //                     if opt_vals.is_none() {
    //                         if $strict_downcast {
    //                             return Err(extendr_api::Error::Other(
    //                                 format!("a lambda returned {} and not the expected {} .  Try strict=FALSE, or change expected output type or rewrite lambda", "print rtype".to_string() ,stringify!($dc_type))
    //                             ))
    //                         } else {
    //                             //return null to polars
    //                             return Ok(None);
    //                         }
    //                     }

    //                     let rstr = opt_vals.unwrap();
    //                     if rstr.is_na() {
    //                         Ok(None)
    //                     } else {
    //                         Ok(Some(rstr.as_str().to_string()))
    //                     }

    //                 }
    //             )
    //         })
    //         //collect evaluation return on first error or all values ok
    //         .collect::<Result<$ca_type>>()
    //         //if all ok collect into serias and rename
    //         .map(|ca| {
    //             Series(ca.into_series())
    //         })
    // };


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

//Unwrap result and throw r error instead of panic!. This leaks memory big time.
//panic! unwinds all objects, throwing R error will most times result in leaving behind
//rust 'instance' with all allocated mem unrecoverable.
pub unsafe fn r_unwrap<T, E>(x: Result<T, E>) -> T
where
    T: std::fmt::Debug,
    E: std::fmt::Debug + std::fmt::Display,
{
    x.map_err(|err| extendr_api::throw_r_error(err.to_string()))
        .unwrap()
}

//convert rust Result into either list(ok=ok_value,err=NULL) or list(ok=NULL,err=err_string)
//use custom unwrap-function on R side or any custom code to read results and/or throw errors.
use extendr_api::prelude::IntoRobj;
pub fn r_result_list<T, E>(x: Result<T, E>) -> extendr_api::prelude::list::List
where
    T: std::fmt::Debug + IntoRobj,
    E: std::fmt::Debug + std::fmt::Display,
{
    if x.is_ok() {
        extendr_api::prelude::list!(ok = x.unwrap().into_robj(), err = extendr_api::NULL)
    } else {
        extendr_api::prelude::list!(ok = extendr_api::NULL, err = x.unwrap_err().to_string())
    }
}

pub fn r_result_list_no_debug<T, E>(x: Result<T, E>) -> extendr_api::prelude::list::List
where
    T: IntoRobj,
    E: std::fmt::Display,
{
    if x.is_ok() {
        if let Ok(okx) = x {
            extendr_api::prelude::list!(ok = okx.into_robj(), err = extendr_api::NULL)
        } else {
            unreachable!()
        }
    } else {
        if let Err(errx) = x {
            extendr_api::prelude::list!(ok = extendr_api::NULL, err = errx.to_string())
        } else {
            unreachable!()
        }
    }
}
