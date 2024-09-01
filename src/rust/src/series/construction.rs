use crate::{prelude::*, PlRDataType, PlRSeries, RPolarsErr};
use polars_core::utils::{try_get_supertype, CustomIterTools};
use savvy::{
    savvy, sexp::na::NotAvailableValue, IntegerSexp, ListSexp, LogicalSexp, RawSexp, RealSexp,
    Result, StringSexp, TypedSexp,
};

#[savvy]
impl PlRSeries {
    fn new_empty(name: &str, dtype: Option<PlRDataType>) -> Result<Self> {
        let dtype = dtype.map(|dtype| dtype.dt).unwrap_or(DataType::Null);
        Ok(Series::new_empty(name, &dtype).into())
    }

    fn new_f64(name: &str, values: RealSexp) -> Result<Self> {
        let ca: Float64Chunked = values
            .iter()
            .map(|value| if value.is_na() { None } else { Some(*value) })
            .collect_trusted();
        Ok(ca.with_name(name).into_series().into())
    }

    fn new_i32(name: &str, values: IntegerSexp) -> Result<Self> {
        let ca: Int32Chunked = values
            .iter()
            .map(|value| if value.is_na() { None } else { Some(*value) })
            .collect_trusted();
        Ok(ca.with_name(name).into_series().into())
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
        Ok(ca.with_name(name).into_series().into())
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
        Ok(ca.with_name(name).into_series().into())
    }

    fn new_str(name: &str, values: StringSexp) -> Result<Self> {
        let ca: StringChunked = values
            .iter()
            .map(|value| if value.is_na() { None } else { Some(value) })
            .collect();
        Ok(ca.with_name(name).into_series().into())
    }

    fn new_single_binary(name: &str, values: RawSexp) -> Result<Self> {
        let ca = BinaryChunked::from_slice(name, &[values.as_slice()]);
        Ok(ca.into_series().into())
    }

    fn new_binary(name: &str, values: ListSexp) -> Result<Self> {
        let ca = BinaryChunked::new(name, <Wrap<Vec<Option<Vec<u8>>>>>::from(values).0);
        Ok(ca.into_series().into())
    }

    fn new_series_list(name: &str, values: ListSexp) -> Result<Self> {
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

        let dtype = series_vec
            .iter()
            .map(|s| {
                if let Some(s) = s {
                    s.dtype().clone()
                } else {
                    DataType::Null
                }
            })
            .reduce(|acc, b| try_get_supertype(&acc, &b).unwrap_or(DataType::String))
            .unwrap_or(DataType::Null);

        let casted_series_vec: Vec<Option<Series>> = series_vec
            .into_iter()
            .map(|s| {
                if let Some(s) = s {
                    Some(s.cast(&dtype).unwrap())
                } else {
                    None
                }
            })
            .collect();

        Ok(Series::new(name, casted_series_vec).into())
    }

    fn new_from_clock_time_point(
        name: &str,
        left: RealSexp,
        right: RealSexp,
        multiplier: i32,
        time_unit: &str,
    ) -> Result<Self> {
        let time_unit = <Wrap<TimeUnit>>::try_from(time_unit)?.0;
        let ca_i64: Int64Chunked = left
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
                        ) * (multiplier as i64),
                    )
                }
            })
            .collect_trusted();
        Ok(ca_i64
            .with_name(name)
            .into_series()
            .cast(&DataType::Datetime(time_unit, None))
            .map_err(RPolarsErr::from)?
            .into())
    }
}
