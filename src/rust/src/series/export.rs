use crate::{error::RPolarsErr, prelude::*, PlRSeries};
use polars_core::prelude::*;
use savvy::{
    savvy, ExternalPointerSexp, FunctionArgs, FunctionSexp, ListSexp, OwnedIntegerSexp,
    OwnedListSexp, OwnedLogicalSexp, OwnedRealSexp, OwnedStringSexp, Sexp,
};

#[savvy]
impl PlRSeries {
    // TODO: check i32::MIN etc.?
    // TODO: export int64 as string, bit64::integer64
    pub fn to_r_vector(&self) -> savvy::Result<Sexp> {
        let series = &self.series;

        fn to_r_vector_recursive(series: &Series) -> savvy::Result<Sexp> {
            match series.dtype() {
                DataType::Boolean => Ok(<Sexp>::from(Wrap(series.bool().unwrap()))),
                DataType::UInt8 | DataType::UInt16 | DataType::Int8 | DataType::Int16 => Ok(
                    <Sexp>::from(Wrap(series.cast(&DataType::Int32).unwrap().i32().unwrap())),
                ),
                DataType::Int32 => Ok(<Sexp>::from(Wrap(series.i32().unwrap()))),
                DataType::UInt64 | DataType::Int64 => Ok(<Sexp>::from(Wrap(
                    series.cast(&DataType::Float64).unwrap().f64().unwrap(),
                ))),
                DataType::Float64 => Ok(<Sexp>::from(Wrap(series.f64().unwrap()))),
                DataType::String => Ok(<Sexp>::from(Wrap(series.str().unwrap()))),
                DataType::Categorical(_, _) | DataType::Enum(_, _) => {
                    let r_func: FunctionSexp =
                        <Sexp>::try_from(savvy::eval_parse_text("as.factor")?)?.try_into()?;
                    let chr_vec =
                        <Sexp>::from(Wrap(series.cast(&DataType::String).unwrap().str().unwrap()));
                    let mut args = FunctionArgs::new();
                    let _ = args.add("x", chr_vec);
                    Ok(r_func.call(args)?.into())
                }
                DataType::List(_) => unsafe {
                    let len = series.len();
                    let mut list = OwnedListSexp::new(len, false)?;
                    let ca = series.list().unwrap();
                    for (i, opt_s) in ca.amortized_iter().enumerate() {
                        match opt_s {
                            None => list.set_value_unchecked(i, savvy::sexp::null::null()),
                            Some(s) => {
                                list.set_value_unchecked(i, to_r_vector_recursive(s.as_ref())?.0)
                            }
                        }
                    }
                    Ok(list.into())
                },
                DataType::Array(_, _) => unsafe {
                    let len = series.len();
                    let mut list = OwnedListSexp::new(len, false)?;
                    let ca = series.array().unwrap();
                    for (i, opt_s) in ca.amortized_iter().enumerate() {
                        match opt_s {
                            None => list.set_value_unchecked(i, savvy::sexp::null::null()),
                            Some(s) => {
                                list.set_value_unchecked(i, to_r_vector_recursive(s.as_ref())?.0)
                            }
                        }
                    }
                    Ok(list.into())
                },
                DataType::Struct(_) => {
                    let df = series.clone().into_frame().unnest([series.name()]).unwrap();
                    let len = df.width();
                    let mut list = OwnedListSexp::new(len, true)?;
                    for (i, s) in df.iter().enumerate() {
                        list.set_name_and_value(i, s.name(), to_r_vector_recursive(s)?)?
                    }
                    Ok(list.into())
                }
                DataType::Null => {
                    let len = series.len();
                    Ok(OwnedListSexp::new(len, false)?.into())
                }
                _ => todo!(),
            }
        }

        let r_vector = to_r_vector_recursive(series)?;
        Ok(r_vector)
    }
}
