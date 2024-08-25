use crate::{prelude::*, PlRExpr, PlRSeries, RPolarsErr};
use savvy::{savvy, FunctionArgs, FunctionSexp, OwnedListSexp, Sexp};
use strum_macros::EnumString;

#[derive(Debug, Clone, Eq, PartialEq, EnumString)]
#[strum(serialize_all = "lowercase")]
pub enum Int64Conversion {
    Character,
    Double,
    Integer,
}

#[savvy]
impl PlRSeries {
    // TODO: check i32::MIN etc.?
    // TODO: export int64 as bit64::integer64
    pub fn to_r_vector(
        &self,
        int64: &str,
        ambiguous: PlRExpr,
        non_existent: &str,
        local_time_zone: &str,
    ) -> savvy::Result<Sexp> {
        let series = &self.series;

        let int64 = Int64Conversion::try_from(int64).map_err(|_| {
            savvy::Error::from(
                "Argument `int64` must be one of 'character', 'double', 'integer'".to_string(),
            )
        })?;
        let ambiguous = ambiguous.inner;
        let non_existent = <Wrap<NonExistent>>::try_from(non_existent)?.0;

        fn to_r_vector_recursive(
            series: &Series,
            int64: Int64Conversion,
            ambiguous: Expr,
            non_existent: NonExistent,
            local_time_zone: &str,
        ) -> savvy::Result<Sexp> {
            match series.dtype() {
                DataType::Boolean => Ok(<Sexp>::from(Wrap(series.bool().unwrap()))),
                DataType::UInt8 | DataType::UInt16 | DataType::Int8 | DataType::Int16 => Ok(
                    <Sexp>::from(Wrap(series.cast(&DataType::Int32).unwrap().i32().unwrap())),
                ),
                DataType::Int32 => Ok(<Sexp>::from(Wrap(series.i32().unwrap()))),
                DataType::UInt32 | DataType::UInt64 | DataType::Int64 => match int64 {
                    Int64Conversion::Character => Ok(<Sexp>::from(Wrap(
                        series.cast(&DataType::String).unwrap().str().unwrap(),
                    ))),
                    Int64Conversion::Double => Ok(<Sexp>::from(Wrap(
                        series.cast(&DataType::Float64).unwrap().f64().unwrap(),
                    ))),
                    Int64Conversion::Integer => {
                        let s = series.cast(&DataType::Int32).map_err(RPolarsErr::from)?;
                        Ok(<Sexp>::from(Wrap(s.i32().unwrap())))
                    }
                },
                DataType::Float32 => Ok(<Sexp>::from(Wrap(
                    series.cast(&DataType::Float64).unwrap().f64().unwrap(),
                ))),
                DataType::Float64 => Ok(<Sexp>::from(Wrap(series.f64().unwrap()))),
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
                            Some(s) => list.set_value_unchecked(
                                i,
                                to_r_vector_recursive(
                                    s.as_ref(),
                                    int64.clone(),
                                    ambiguous.clone(),
                                    non_existent,
                                    local_time_zone,
                                )?
                                .0,
                            ),
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
                            Some(s) => list.set_value_unchecked(
                                i,
                                to_r_vector_recursive(
                                    s.as_ref(),
                                    int64.clone(),
                                    ambiguous.clone(),
                                    non_existent,
                                    local_time_zone,
                                )?
                                .0,
                            ),
                        }
                    }
                    Ok(list.into())
                },
                DataType::Date => Ok(<Sexp>::from(Wrap(series.date().unwrap()))),
                DataType::Time => Ok(<Sexp>::from(Wrap(series.time().unwrap()))),
                DataType::Datetime(_, opt_tz) => match opt_tz {
                    None => Ok(<Sexp>::from(Wrap(
                        series
                            .clone()
                            .into_frame()
                            .lazy()
                            .select([col(series.name())
                                .dt()
                                .replace_time_zone(
                                    Some(local_time_zone.to_string()),
                                    ambiguous.clone(),
                                    non_existent,
                                )
                                .dt()
                                .convert_time_zone("UTC".to_string())
                                .dt()
                                .replace_time_zone(None, lit("raise"), NonExistent::Raise)])
                            .collect()
                            .map_err(RPolarsErr::from)?
                            .select_at_idx(0)
                            .unwrap()
                            .datetime()
                            .unwrap(),
                    ))),
                    Some(_tz) => Ok(<Sexp>::from(Wrap(series.datetime().unwrap()))),
                },
                DataType::Decimal(_, _) => Ok(<Sexp>::from(Wrap(
                    series.cast(&DataType::Float64).unwrap().f64().unwrap(),
                ))),
                DataType::String => Ok(<Sexp>::from(Wrap(series.str().unwrap()))),
                DataType::Struct(_) => {
                    let df = series.clone().into_frame().unnest([series.name()]).unwrap();
                    let len = df.width();
                    let mut list = OwnedListSexp::new(len, true)?;
                    for (i, s) in df.iter().enumerate() {
                        list.set_name_and_value(
                            i,
                            s.name(),
                            to_r_vector_recursive(
                                s,
                                int64.clone(),
                                ambiguous.clone(),
                                non_existent,
                                local_time_zone,
                            )?,
                        )?
                    }
                    Ok(list.into())
                }
                DataType::Duration(_) => Ok(<Sexp>::from(Wrap(series.duration().unwrap()))),
                DataType::Binary => Ok(<Sexp>::from(Wrap(series.binary().unwrap()))),
                DataType::Null => {
                    let len = series.len();
                    Ok(OwnedListSexp::new(len, false)?.into())
                }
                _ => todo!(),
            }
        }

        let r_vector =
            to_r_vector_recursive(series, int64, ambiguous, non_existent, local_time_zone)?;
        Ok(r_vector)
    }
}
