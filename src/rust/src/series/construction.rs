use crate::{prelude::*, PlRSeries};
use polars_core::utils::{try_get_supertype, CustomIterTools};
use savvy::{
    savvy, sexp::na::NotAvailableValue, IntegerSexp, ListSexp, LogicalSexp, NumericSexp,
    NumericTypedSexp, RawSexp, RealSexp, Result, StringSexp, TypedSexp,
};

#[savvy]
impl PlRSeries {
    fn new_null(name: &str, length: i32) -> Result<Self> {
        Ok(Series::new_null(name.into(), length as usize).into())
    }

    fn new_f64(name: &str, values: RealSexp) -> Result<Self> {
        let ca: Float64Chunked = values
            .iter()
            .map(|value| if value.is_na() { None } else { Some(*value) })
            .collect_trusted();
        Ok(ca.with_name(name.into()).into_series().into())
    }

    fn new_i32(name: &str, values: IntegerSexp) -> Result<Self> {
        let ca: Int32Chunked = values
            .iter()
            .map(|value| if value.is_na() { None } else { Some(*value) })
            .collect_trusted();
        Ok(ca.with_name(name.into()).into_series().into())
    }

    // From bit64::integer64
    fn new_i64(name: &str, values: RealSexp) -> Result<Self> {
        let ca: Int64Chunked = values
            .iter()
            .map(|value| {
                let value = value.to_bits() as i64;
                if value == i64::MIN {
                    None
                } else {
                    Some(value)
                }
            })
            .collect_trusted();
        Ok(ca.with_name(name.into()).into_series().into())
    }

    fn new_bool(name: &str, values: LogicalSexp) -> Result<Self> {
        let ca: BooleanChunked = values
            .as_slice_raw()
            .iter()
            .map(|value| {
                if value.is_na() {
                    None
                } else {
                    Some(*value == 1)
                }
            })
            .collect_trusted();
        Ok(ca.with_name(name.into()).into_series().into())
    }

    fn new_str(name: &str, values: StringSexp) -> Result<Self> {
        let ca: StringChunked = values
            .iter()
            .map(|value| if value.is_na() { None } else { Some(value) })
            .collect();
        Ok(ca.with_name(name.into()).into_series().into())
    }

    fn new_single_binary(name: &str, values: RawSexp) -> Result<Self> {
        let ca = BinaryChunked::from_slice(name.into(), &[values.as_slice()]);
        Ok(ca.into_series().into())
    }

    fn new_binary(name: &str, values: ListSexp) -> Result<Self> {
        let ca = BinaryChunked::new(name.into(), <Wrap<Vec<Option<Vec<u8>>>>>::from(values).0);
        Ok(ca.into_series().into())
    }

    fn new_series_list(name: &str, values: ListSexp, strict: bool) -> Result<Self> {
        let series_vec: Vec<Option<Series>> = values
            .values_iter()
            .map(|value| match value.into_typed() {
                TypedSexp::Null(_) => None,
                TypedSexp::Environment(e) => {
                    let r_series = <&PlRSeries>::from(e);
                    Some(r_series.series.clone())
                }
                _ => unreachable!("Only accept a list of Series"),
            })
            .collect();

        if strict {
            let expected_dtype = series_vec
                .iter()
                .find(|opt_s| opt_s.is_some())
                .map(|opt_s| {
                    opt_s
                        .as_ref()
                        .map(|s| s.dtype().clone())
                        .unwrap_or(DataType::Null)
                })
                .unwrap_or(DataType::Null);
            for (i, s) in series_vec.iter().enumerate() {
                if let Some(s) = s {
                    if s.dtype() != &expected_dtype {
                        return Err(
                            format!("If `strict = TRUE`, all elements of the list except `NULL` must have the same datatype. expected: `{}`, got: `{}` at index: {}", expected_dtype, s.dtype(), i + 1).into()
                        );
                    }
                }
            }
            return Ok(Series::new(name.into(), series_vec).into());
        }

        let dtype = series_vec
            .iter()
            .map(|opt_s| {
                if let Some(s) = opt_s {
                    s.dtype().clone()
                } else {
                    DataType::Null
                }
            })
            .reduce(|acc, b| try_get_supertype(&acc, &b).unwrap_or(DataType::Null))
            .unwrap_or(DataType::Null);

        let casted_series_vec: Vec<Option<Series>> = series_vec
            .into_iter()
            .map(|opt_s| {
                if let Some(s) = opt_s {
                    Some(s.cast(&dtype).ok()?)
                } else {
                    None
                }
            })
            .collect();

        Ok(Series::new(name.into(), casted_series_vec).into())
    }

    // from Date class
    fn new_i32_from_date(name: &str, values: NumericSexp) -> Result<Self> {
        let ca: Int32Chunked = match values.into_typed() {
            NumericTypedSexp::Integer(i) => i
                .iter()
                .map(|value| if value.is_na() { None } else { Some(*value) })
                .collect_trusted(),
            NumericTypedSexp::Real(r) => r
                .iter()
                .map(|value| {
                    if value.is_na() {
                        None
                    } else {
                        Some(value.floor() as i32)
                    }
                })
                .collect_trusted(),
        };
        Ok(ca.with_name(name.into()).into_series().into())
    }

    // from numeric and integer multiplier
    fn new_i64_from_numeric_and_multiplier(
        name: &str,
        values: NumericSexp,
        multiplier: i32,
        rounding: &str,
    ) -> Result<Self> {
        let ca: Int64Chunked = match values.into_typed() {
            NumericTypedSexp::Integer(i) => i
                .iter()
                .map(|value| {
                    if value.is_na() {
                        None
                    } else {
                        Some((*value as i64) * multiplier as i64)
                    }
                })
                .collect_trusted(),
            NumericTypedSexp::Real(r) => r
                .iter()
                .map(|value| {
                    if value.is_na() {
                        None
                    } else {
                        match rounding {
                            "floor" => Some((value * (multiplier as f64)) as i64),
                            "round" => Some((value * (multiplier as f64)).round_ties_even() as i64),
                            _ => unreachable!("`rounding` must be either `floor` or `round`"),
                        }
                    }
                })
                .collect_trusted(),
        };
        Ok(ca.with_name(name.into()).into_series().into())
    }

    // from clock classes
    fn new_i64_from_clock_pair(
        name: &str,
        left: RealSexp,
        right: RealSexp,
        precision: &str,
    ) -> Result<Self> {
        // Polars only supports nanosecond, microsecond, and millisecond precisions.
        // So we need to convert other precisions to millisecond precision.
        // https://github.com/r-lib/clock/blob/7bc03674f56bf1d4f850b0b1ab8d7d924a85e34a/R/duration.R#L32-L56
        let multiplier = match precision {
            "nanosecond" | "microsecond" | "millisecond" => 1,
            "second" => 1_000,
            "minute" => 60_000,
            "hour" => 3_600_000,
            "day" => 86_400_000,
            "week" => 604_800_000,
            "month" => 2_629_746_000,
            "quarter" => 7_889_238_000,
            "year" => 31_556_952_000,
            _ => unreachable!("Invalid precision"),
        };
        let ca: Int64Chunked = left
            .iter()
            .zip(right.iter())
            .map(|(l, r)| {
                if l.is_na() || r.is_na() {
                    None
                } else {
                    let left_u32 = *l as u32;
                    let right_u32 = *r as u32;
                    let out_u64 = (left_u32 as u64) << 32 | right_u32 as u64;
                    Some(
                        i64::from_ne_bytes(
                            (out_u64.wrapping_sub(9_223_372_036_854_775_808u64)).to_ne_bytes(),
                        ) * multiplier,
                    )
                }
            })
            .collect_trusted();
        Ok(ca.with_name(name.into()).into_series().into())
    }
}
