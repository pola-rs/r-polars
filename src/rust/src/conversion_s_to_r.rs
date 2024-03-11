use crate::{rdataframe::RPolarsDataFrame, robj_to};
use extendr_api::prelude::*;
use pl::PolarsError as pl_error;
use polars::prelude::{self as pl};
use polars_core::datatypes::DataType;
use polars_lazy::{dsl::col, frame::IntoLazy};

//TODO throw a warning if i32 contains a lowerbound value which is the NA in R.
pub fn pl_series_to_list(
    series: &pl::Series,
    tag_structs: bool,
    int64_conversion: &str,
) -> pl::PolarsResult<Robj> {
    use pl::DataType::*;
    fn to_list_recursive(
        s: &pl::Series,
        tag_structs: bool,
        int64_conversion: &str,
    ) -> pl::PolarsResult<Robj> {
        match s.dtype() {
            Float64 => s.f64().map(|ca| ca.into_iter().collect_robj()),
            Float32 => s.f32().map(|ca| ca.into_iter().collect_robj()),

            Int8 => s.i8().map(|ca| ca.into_iter().collect_robj()),
            Int16 => s.i16().map(|ca| ca.into_iter().collect_robj()),
            Int32 => s.i32().map(|ca| ca.into_iter().collect_robj()),
            Int64 => match int64_conversion {
                "double" => s
                    .cast(&DataType::Float64)?
                    .f64()
                    .map(|ca| ca.into_iter().collect_robj()),
                "string" => s
                    .cast(&DataType::String)?
                    .str()
                    .map(|ca| ca.into_iter().collect_robj()),
                "bit64" => s.i64().map(|ca| {
                    ca.into_iter()
                        .map(|opt| match opt {
                            Some(x) if x != crate::utils::BIT64_NA_ENCODING => {
                                let x = f64::from_bits(x as u64);
                                Some(x)
                            }
                            _ => {
                                let x = crate::utils::BIT64_NA_ENCODING;
                                let x = f64::from_bits(x as u64);
                                Some(x)
                            }
                        })
                        .collect_robj()
                        .set_class(&["integer64"])
                        .expect("internal error could not set class label 'integer64'")
                }),
                _ => Err(pl::PolarsError::InvalidOperation(
                    "`int64_conversion ` must be one of 'float', 'string', 'bit64'".into(),
                )),
            },
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
            //                 let x = crate::utils::BIT64_NA_ENCODING;
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
            String => s.str().map(|ca| ca.into_iter().collect_robj()),

            Boolean => s.bool().map(|ca| ca.into_iter().collect_robj()),
            Binary => s.binary().map(|ca| {
                let x: Vec<_> = ca
                    .into_iter()
                    .map(|opt_slice_binary| {
                        if let Some(slice_binary) = opt_slice_binary {
                            r!(Raw::from_bytes(slice_binary))
                        } else {
                            r!(extendr_api::NULL)
                        }
                    })
                    .collect();
                extendr_api::List::from_values(x)
                    .into_robj()
                    .set_class(["rpolars_raw_list", "list"])
                    .expect("this class label is always valid")
            }),
            Categorical(_, _) => s
                .categorical()
                .map(|ca| extendr_api::call!("factor", ca.iter_str().collect_robj()).unwrap()),
            List(_) => {
                let mut v: Vec<extendr_api::Robj> = Vec::with_capacity(s.len());
                let ca = s.list().unwrap();

                // Safty:amortized_iter()  The returned should never be cloned or taken longer than a single iteration,
                // as every call on next of the iterator will change the contents of that Series.
                unsafe {
                    for opt_s in ca.amortized_iter() {
                        match opt_s {
                            Some(s) => {
                                let s_ref = s.as_ref();
                                // is safe because s is read to generate new Robj, then discarded.
                                let inner_val =
                                    to_list_recursive(s_ref, tag_structs, int64_conversion)?;
                                v.push(inner_val);
                            }

                            None => {
                                v.push(r!(extendr_api::NULL));
                            }
                        }
                    }
                }
                //TODO let l = extendr_api::List::from_values(v); or see if possible to skip vec allocation
                //or take ownership of vector
                let l = extendr_api::List::from_iter(v.iter());
                Ok(l.into_robj())
            }
            Array(_, _) => {
                let mut v: Vec<extendr_api::Robj> = Vec::with_capacity(s.len());
                let ca = s.array().unwrap();

                for opt_s in ca.amortized_iter() {
                    match opt_s {
                        Some(s) => {
                            let s_ref = s.as_ref();
                            // is safe because s is read to generate new Robj, then discarded.
                            let inner_val =
                                to_list_recursive(s_ref, tag_structs, int64_conversion)?;
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
                let df = s.clone().into_frame().unnest([s.name()]).unwrap();
                let mut l = RPolarsDataFrame(df).to_list_result(int64_conversion)?;

                //TODO contribute extendr_api set_attrib mutates &self, change signature to surprise anyone
                if tag_structs {
                    l.set_attrib("is_struct", true).unwrap();
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
                .map(|mut robj| {
                    robj.set_class(&["PTime"])
                        .expect("internal error: class label PTime failed")
                })
                .map(|mut robj| robj.set_attrib("tu", "ns"))
                .expect("internal error: attr tu failed")
                .map_err(|err| {
                    pl_error::ComputeError(
                        format!("when converting polars Time to R PTime: {:?}", err).into(),
                    )
                }),

            Datetime(tu, opt_tz) => {
                let tu_f64: f64 = match tu {
                    pl::TimeUnit::Nanoseconds => 1_000_000_000.0,
                    pl::TimeUnit::Microseconds => 1_000_000.0,
                    pl::TimeUnit::Milliseconds => 1_000.0,
                };

                let zoned_s: pl::Series = match opt_tz {
                    Some(_tz) => {
                        // zoned time
                        s.clone()
                    }
                    None => {
                        // naive time
                        let sys_tz_robj = R!("Sys.timezone()")
                            .map_err(|err| pl::PolarsError::ComputeError(err.to_string().into()))?;
                        let sys_tz = robj_to!(String, sys_tz_robj)
                            .map_err(|err| pl::PolarsError::ComputeError(err.to_string().into()))?;
                        let s_name = s.name();
                        pl::DataFrame::new(vec![s.clone()])?
                            .lazy()
                            .select([col(s_name)
                                .dt()
                                .replace_time_zone(Some(sys_tz), pl::lit("raise"))])
                            .collect()?
                            .column(s_name)?
                            .clone()
                    }
                };

                zoned_s
                    .cast(&Float64)?
                    .f64()
                    .map(|ca| {
                        ca.into_iter()
                            .map(|opt| opt.map(|val| val / tu_f64))
                            .collect_robj()
                    })
                    // TODO set_class and set_attrib reallocates the vector, find some way to modify without.
                    .map(|mut robj| {
                        robj.set_class(&["POSIXct", "POSIXt"])
                            .expect("internal error: class POSIXct label failed")
                    })
                    .map(|mut robj| {
                        robj.set_attrib("tzone", opt_tz.as_ref().map(|s| s.as_str()).unwrap_or(""))
                    })
                    .expect("internal error: attr tzone failed")
                    .map_err(|err| {
                        pl_error::ComputeError(
                            format!("when converting polars Datetime to R POSIXct: {:?}", err)
                                .into(),
                        )
                    })
            }
            _ => Err(pl::PolarsError::InvalidOperation(
                format!(
                    "sorry polars has not yet implemented R conversion for Series.dtype: {}",
                    s.dtype()
                )
                .into(),
            )),
        }
    }

    to_list_recursive(series, tag_structs, int64_conversion)
}
