use crate::PlRSeries;
use polars_core::prelude::*;
use polars_core::utils::{try_get_supertype, CustomIterTools};
use savvy::sexp::na::NotAvailableValue;
use savvy::{savvy, IntegerSexp, ListSexp, LogicalSexp, RealSexp, StringSexp, TypedSexp};

#[savvy]
impl PlRSeries {
    fn new_f64(name: &str, values: RealSexp) -> savvy::Result<Self> {
        let ca: Float64Chunked = values
            .iter()
            .map(|value| if value.is_na() { None } else { Some(*value) })
            .collect_trusted();
        Ok(ca.with_name(name).into_series().into())
    }

    fn new_i32(name: &str, values: IntegerSexp) -> savvy::Result<Self> {
        let ca: Int32Chunked = values
            .iter()
            .map(|value| if value.is_na() { None } else { Some(*value) })
            .collect_trusted();
        Ok(ca.with_name(name).into_series().into())
    }

    fn new_bool(name: &str, values: LogicalSexp) -> savvy::Result<Self> {
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

    fn new_str(name: &str, values: StringSexp) -> savvy::Result<Self> {
        let ca: StringChunked = values
            .iter()
            .map(|value| if value.is_na() { None } else { Some(value) })
            .collect();
        Ok(ca.with_name(name).into_series().into())
    }

    fn new_series_list(name: &str, values: ListSexp) -> savvy::Result<Self> {
        let series_vec: Vec<Option<Series>> = values
            .values_iter()
            .map(|value| match value.into_typed() {
                TypedSexp::Null(_) => None,
                TypedSexp::Environment(e) => {
                    let ptr = e.get(".ptr").unwrap().unwrap();
                    let r_series = <&PlRSeries>::try_from(ptr).unwrap();
                    Some(r_series.series.clone())
                }
                _ => panic!("Expected a list of Series"),
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
}
