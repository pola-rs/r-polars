use extendr_api::prelude::*;
use polars::prelude::{self as pl};

use crate::rdataframe::DataFrame;
use pl::PolarsError as pl_error;
use polars::error::ErrString as pl_err_string;

// #[extendr]
// fn hello_bit64() -> Robj {
//     let i64_vec = vec![1i64, 2, 3, 4, 14503599627370496];
//     let robj = i64_vec
//         .into_iter()
//         .map(|x| {
//             let x = unsafe { std::mem::transmute::<i64, f64>(x) };
//             x
//         })
//         .collect_robj();

//     robj.set_class(&["integer64"]).unwrap();

//     robj
// }

//TODO throw a warning if i32 contains a lowerbound value which is the NA in R.
pub fn pl_series_to_list(
    series: &pl::Series,
    tag_structs: bool,
    bit64: bool,
) -> pl::PolarsResult<Robj> {
    use pl::DataType::*;
    fn to_list_recursive(s: &pl::Series, tag_structs: bool, bit64: bool) -> pl::PolarsResult<Robj> {
        match s.dtype() {
            Float64 => s.f64().map(|ca| ca.into_iter().collect_robj()),
            Float32 => s.f32().map(|ca| ca.into_iter().collect_robj()),

            Int8 => s.i8().map(|ca| ca.into_iter().collect_robj()),
            Int16 => s.i16().map(|ca| ca.into_iter().collect_robj()),
            Int32 => s.i32().map(|ca| ca.into_iter().collect_robj()),
            Int64 if bit64 => s.i64().map(|ca| {
                ca.into_iter()
                    .map(|opt| match opt {
                        Some(x) if x != crate::utils::BIT64_NA_ECODING => {
                            let x = unsafe { std::mem::transmute::<i64, f64>(x) };
                            Some(x)
                        }
                        _ => {
                            let x = crate::utils::BIT64_NA_ECODING;
                            let x = unsafe { std::mem::transmute::<i64, f64>(x) };
                            Some(x)
                        }
                    })
                    .collect_robj()
                    .set_class(&["integer64"])
                    .expect("internal error could not set class label 'integer64'")
            }),
            Int64 => s.i64().map(|ca| {
                ca.into_iter()
                    .map(|opt| opt.map(|val| val as f64))
                    .collect_robj()
            }),
            UInt8 => s.u8().map(|ca| {
                ca.into_iter()
                    .map(|opt| opt.map(|val| val as i32))
                    .collect_robj()
            }),
            UInt16 => s.u16().map(|ca| {
                ca.into_iter()
                    .map(|opt| opt.map(|val| val as i32))
                    .collect_robj()
            }),
            // UInt32 if bit64 => s.u32().map(|ca| {
            //     ca.into_iter()
            //         .map(|opt| match opt {
            //             Some(x) => {
            //                 let x = unsafe { std::mem::transmute::<i64, f64>(x as i64) };
            //                 Some(x)
            //             }
            //             _ => {
            //                 let x = crate::utils::BIT64_NA_ECODING;
            //                 let x = unsafe { std::mem::transmute::<i64, f64>(x) };
            //                 Some(x)
            //             }
            //         })
            //         .collect_robj()
            //         .set_class(&["integer64"])
            //         .expect("internal error could not set class label 'integer64'")
            // }),
            UInt32 => s.u32().map(|ca| {
                ca.into_iter()
                    .map(|opt| opt.map(|val| val as f64))
                    .collect_robj()
            }),
            UInt64 => s.u64().map(|ca| {
                ca.into_iter()
                    .map(|opt| opt.map(|val| val as f64))
                    .collect_robj()
            }),
            Utf8 => s.utf8().map(|ca| ca.into_iter().collect_robj()),

            Boolean => s.bool().map(|ca| ca.into_iter().collect_robj()),
            Categorical(_) => s
                .categorical()
                .map(|ca| extendr_api::call!("factor", ca.iter_str().collect_robj()).unwrap()),
            List(_) => {
                let mut v: Vec<extendr_api::Robj> = Vec::with_capacity(s.len());
                let ca = s.list().unwrap();

                for opt_s in ca.amortized_iter() {
                    match opt_s {
                        Some(s) => {
                            let s_ref = s.as_ref();
                            let inner_val = to_list_recursive(s_ref, tag_structs, bit64)?;
                            v.push(inner_val);
                        }

                        None => {
                            v.push(r!(extendr_api::NULL));
                        }
                    }
                }
                //TODO let l = extendr_api::List::from_values(v); or see if possible to skip vec allocation
                //or take ownership of vector
                let l = extendr_api::List::from_iter(v.iter());
                Ok(l.into_robj())
            }
            Struct(_) => {
                let df = s.clone().into_frame().unnest(&[s.name()]).unwrap();
                let l = DataFrame(df).to_list_result()?;

                //TODO contribute extendr_api set_attrib mutates &self, change signature to surprise anyone
                if tag_structs {
                    l.set_attrib("is_struct", true).unwrap();
                } else {
                };

                Ok(l.into_robj())
            }

            Date => Ok(s
                .cast(&Float64)?
                .f64()?
                .into_iter()
                .collect_robj()
                .set_class(&["Date"])
                .expect("internal error: class label Date failed")),
            Null => Ok((extendr_api::NULL).into_robj()),
            Time => s
                .cast(&Int64)?
                .i64()
                .map(|ca| {
                    ca.into_iter()
                        .map(|opt| opt.map(|val| val as f64))
                        .collect_robj()
                })
                // TODO set_class and set_attrib reallocates the vector, find some way to modify without.
                .map(|robj| {
                    robj.set_class(&["PTime"])
                        .expect("internal error: class label PTime failed")
                })
                .map(|robj| robj.set_attrib("tu", "ns"))
                .expect("internal error: attr tu failed")
                .map_err(|err| {
                    pl_error::ComputeError(pl_err_string::Owned(format!(
                        "when converting polars Time to R PTime: {:?}",
                        err
                    )))
                }),

            Datetime(tu, opt_tz) => {
                let tu_i64: i64 = match tu {
                    pl::TimeUnit::Nanoseconds => 1_000_000_000,
                    pl::TimeUnit::Microseconds => 1_000_000,
                    pl::TimeUnit::Milliseconds => 1_000,
                };

                //resolve timezone
                let tz = opt_tz.as_ref().map(|s| s.as_str()).unwrap_or_else(|| &"");
                s.cast(&Int64)?
                    .i64()
                    .map(|ca| {
                        ca.into_iter()
                            .map(|opt| opt.map(|val| (val / tu_i64) as f64))
                            .collect_robj()
                    })
                    // TODO set_class and set_attrib reallocates the vector, find some way to modify without.
                    .map(|robj| {
                        robj.set_class(&["POSIXct", "POSIXt"])
                            .expect("internal error: class POSIXct label failed")
                    })
                    .map(|robj| robj.set_attrib("tzone", tz))
                    .expect("internal error: attr tzone failed")
                    .map_err(|err| {
                        pl_error::ComputeError(pl_err_string::Owned(format!(
                            "when converting polars Datetime to R POSIXct: {:?}",
                            err
                        )))
                    })
            }
            _ => Err(pl::PolarsError::InvalidOperation(
                polars::error::ErrString::Owned(format!(
                    "sorry polars has not yet implemented R conversion for Series.dtype: {}",
                    s.dtype()
                )),
            )),
        }
    }

    to_list_recursive(series, tag_structs, bit64)
}
