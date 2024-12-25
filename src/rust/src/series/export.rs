use crate::{prelude::*, PlRExpr, PlRSeries, RPolarsErr};
use savvy::{
    savvy, FunctionArgs, FunctionSexp, OwnedIntegerSexp, OwnedListSexp, OwnedLogicalSexp, Sexp,
};
use strum_macros::EnumString;

#[derive(Debug, Clone, EnumString)]
#[strum(serialize_all = "lowercase")]
enum Int64Conversion {
    Character,
    Double,
    Integer,
    Integer64,
}

#[derive(Debug, Clone, EnumString)]
#[strum(serialize_all = "lowercase")]
enum StructConversion {
    DataFrame,
    Tibble,
}

#[derive(Debug, Clone, EnumString)]
#[strum(serialize_all = "lowercase")]
enum DecimalConversion {
    Character,
    Double,
}

#[derive(Debug, Clone, EnumString)]
enum DateConversion {
    Date,
    IDate,
}

#[derive(Debug, Clone, EnumString)]
enum TimeConversion {
    #[strum(serialize = "hms")]
    HMS,
    ITime,
}

// `vctrs::unspecified` like function
fn vctrs_unspecified_sexp(n: usize) -> Sexp {
    let mut sexp = OwnedLogicalSexp::new(n).unwrap();
    let _ = sexp.set_class(["vctrs_unspecified"]);
    for i in 0..n {
        let _ = sexp.set_na(i);
    }
    sexp.into()
}

// R's `base::.set_row_names` like function
// TODO: support n > int32::MAX case
// Ref: https://github.com/apache/arrow-nanoarrow/blob/cf38896523c2407cc021f552b73cccd8f57dea83/r/src/materialize.c#L81-L104
fn set_row_names_sexp(n: usize) -> Sexp {
    let sexp = if n == 0 {
        OwnedIntegerSexp::new(0).unwrap()
    } else {
        let n = n as i32;
        OwnedIntegerSexp::try_from_slice([i32::MIN, -n]).unwrap()
    };
    sexp.into()
}

#[savvy]
impl PlRSeries {
    // TODO: check i32::MIN etc.?
    pub fn to_r_vector(
        &self,
        ensure_vector: bool,
        int64: &str,
        date: &str,
        time: &str,
        r#struct: &str,
        decimal: &str,
        as_clock_class: bool,
        ambiguous: &PlRExpr,
        non_existent: &str,
        local_time_zone: &str,
    ) -> savvy::Result<Sexp> {
        let series = &self.series;

        let int64 = Int64Conversion::try_from(int64).map_err(RPolarsErr::from)?;
        let date = DateConversion::try_from(date).map_err(RPolarsErr::from)?;
        let time = TimeConversion::try_from(time).map_err(RPolarsErr::from)?;
        let r#struct = StructConversion::try_from(r#struct).map_err(RPolarsErr::from)?;
        let decimal = DecimalConversion::try_from(decimal).map_err(RPolarsErr::from)?;
        let ambiguous = ambiguous.inner.clone();
        let non_existent = <Wrap<NonExistent>>::try_from(non_existent)?.0;

        fn to_r_vector_recursive(
            series: &Series,
            ensure_vector: bool,
            int64: Int64Conversion,
            date: DateConversion,
            time: TimeConversion,
            r#struct: StructConversion,
            decimal: DecimalConversion,
            as_clock_class: bool,
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
                DataType::UInt32 | DataType::UInt64 | DataType::Int64 | DataType::Int128 => {
                    match int64 {
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
                        Int64Conversion::Integer64 => Ok(<Sexp>::from(Wrap(
                            series.cast(&DataType::Int64).unwrap().i64().unwrap(),
                        ))),
                    }
                }
                DataType::Float32 => Ok(<Sexp>::from(Wrap(
                    series.cast(&DataType::Float64).unwrap().f64().unwrap(),
                ))),
                DataType::Float64 => Ok(<Sexp>::from(Wrap(series.f64().unwrap()))),
                DataType::Categorical(_, _) | DataType::Enum(_, _) => {
                    let r_func: FunctionSexp =
                        <Sexp>::from(savvy::eval_parse_text("as.factor")?).try_into()?;
                    let chr_vec =
                        <Sexp>::from(Wrap(series.cast(&DataType::String).unwrap().str().unwrap()));
                    let mut args = FunctionArgs::new();
                    let _ = args.add("x", chr_vec);
                    Ok(r_func.call(args)?.into())
                }
                DataType::List(inner) => unsafe {
                    let len = series.len();
                    let mut list = OwnedListSexp::new(len, false)?;
                    let _ = list.set_class(["vctrs_list_of", "vctrs_vctr", "list"]);
                    let empty_inner_series = Series::new_empty("".into(), &inner.clone());
                    let _ = list.set_attrib(
                        "ptype",
                        to_r_vector_recursive(
                            &empty_inner_series,
                            false,
                            int64.clone(),
                            date.clone(),
                            time.clone(),
                            r#struct.clone(),
                            decimal.clone(),
                            as_clock_class,
                            ambiguous.clone(),
                            non_existent,
                            local_time_zone,
                        )?,
                    );
                    let ca = series.list().unwrap();
                    for (i, opt_s) in ca.amortized_iter().enumerate() {
                        match opt_s {
                            None => list.set_value_unchecked(i, savvy::sexp::null::null()),
                            Some(s) => list.set_value_unchecked(
                                i,
                                to_r_vector_recursive(
                                    s.as_ref(),
                                    false,
                                    int64.clone(),
                                    date.clone(),
                                    time.clone(),
                                    r#struct.clone(),
                                    decimal.clone(),
                                    as_clock_class,
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
                DataType::Array(inner, _) => unsafe {
                    let len = series.len();
                    let mut list = OwnedListSexp::new(len, false)?;
                    let _ = list.set_class(["vctrs_list_of", "vctrs_vctr", "list"]);
                    let empty_inner_series = Series::new_empty("".into(), &inner.clone());
                    let _ = list.set_attrib(
                        "ptype",
                        to_r_vector_recursive(
                            &empty_inner_series,
                            false,
                            int64.clone(),
                            date.clone(),
                            time.clone(),
                            r#struct.clone(),
                            decimal.clone(),
                            as_clock_class,
                            ambiguous.clone(),
                            non_existent,
                            local_time_zone,
                        )?,
                    );
                    let ca = series.array().unwrap();
                    for (i, opt_s) in ca.amortized_iter().enumerate() {
                        match opt_s {
                            None => list.set_value_unchecked(i, savvy::sexp::null::null()),
                            Some(s) => list.set_value_unchecked(
                                i,
                                to_r_vector_recursive(
                                    s.as_ref(),
                                    false,
                                    int64.clone(),
                                    date.clone(),
                                    time.clone(),
                                    r#struct.clone(),
                                    decimal.clone(),
                                    as_clock_class,
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
                DataType::Date => match date {
                    DateConversion::Date => Ok(<Sexp>::from(Wrap(series.date().unwrap()))),
                    DateConversion::IDate => Ok(<Sexp>::from(<data_table::IDate>::from(
                        series.date().unwrap(),
                    ))),
                },
                DataType::Time => match time {
                    TimeConversion::HMS => Ok(<Sexp>::from(Wrap(series.time().unwrap()))),
                    TimeConversion::ITime => Ok(<Sexp>::from(<data_table::ITime>::from(
                        series.cast(&DataType::Float64).unwrap().f64().unwrap(),
                    ))),
                },
                DataType::Datetime(_, opt_tz) => {
                    if as_clock_class {
                        let time_point = <clock::TimePoint>::from(series.datetime().unwrap());
                        match opt_tz {
                            None => Ok(<Sexp>::from(time_point)),
                            Some(tz) => Ok(<Sexp>::from(clock::ZonedTime {
                                time_point,
                                zone: tz.to_string(),
                            })),
                        }
                    } else {
                        match opt_tz {
                            None => Ok(<Sexp>::from(Wrap(
                                series
                                    .clone()
                                    .into_frame()
                                    .lazy()
                                    .select([col(series.name().clone())
                                        .dt()
                                        .replace_time_zone(
                                            Some(local_time_zone.into()),
                                            ambiguous.clone(),
                                            non_existent,
                                        )
                                        .dt()
                                        .convert_time_zone("UTC".into())
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
                        }
                    }
                }
                DataType::Decimal(_, _) => match decimal {
                    DecimalConversion::Character => Ok(<Sexp>::from(Wrap(
                        series.cast(&DataType::String).unwrap().str().unwrap(),
                    ))),
                    DecimalConversion::Double => Ok(<Sexp>::from(Wrap(
                        series.cast(&DataType::Float64).unwrap().f64().unwrap(),
                    ))),
                },
                DataType::String => Ok(<Sexp>::from(Wrap(series.str().unwrap()))),
                DataType::Struct(_) => {
                    let df = series
                        .clone()
                        .into_frame()
                        .unnest([series.name().clone()])
                        .unwrap();
                    let len = df.width();
                    let mut list = OwnedListSexp::new(len, true)?;
                    if !ensure_vector {
                        let _ = list.set_attrib("row.names", set_row_names_sexp(df.height()));
                        match r#struct {
                            StructConversion::DataFrame => {
                                let _ = list.set_class(["data.frame"]);
                            }
                            StructConversion::Tibble => {
                                let _ = list.set_class(["tbl_df", "tbl", "data.frame"]);
                            }
                        }
                    }
                    for (i, s) in df.iter().enumerate() {
                        list.set_name_and_value(
                            i,
                            s.name(),
                            to_r_vector_recursive(
                                s,
                                false,
                                int64.clone(),
                                date.clone(),
                                time.clone(),
                                r#struct.clone(),
                                decimal.clone(),
                                as_clock_class,
                                ambiguous.clone(),
                                non_existent,
                                local_time_zone,
                            )?,
                        )?
                    }
                    Ok(list.into())
                }
                DataType::Duration(_) => {
                    if as_clock_class {
                        let duration = <clock::Duration>::from(series.duration().unwrap());
                        Ok(<Sexp>::from(duration))
                    } else {
                        Ok(<Sexp>::from(Wrap(series.duration().unwrap())))
                    }
                }
                DataType::Binary => Ok(<Sexp>::from(Wrap(series.binary().unwrap()))),
                DataType::Null => Ok(vctrs_unspecified_sexp(series.len())),
                _ => todo!(),
            }
        }

        let r_vector = to_r_vector_recursive(
            series,
            ensure_vector,
            int64,
            date,
            time,
            r#struct,
            decimal,
            as_clock_class,
            ambiguous,
            non_existent,
            local_time_zone,
        )?;
        Ok(r_vector)
    }
}
