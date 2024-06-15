use crate::PlRSeries;
use polars_core::prelude::*;
use polars_core::utils::CustomIterTools;
use savvy::sexp::na::NotAvailableValue;
use savvy::{savvy, RealSexp};

#[savvy]
impl PlRSeries {
    fn new_f32(name: &str, vector: RealSexp) -> savvy::Result<Self> {
        let ca: Float64Chunked = vector
            .iter()
            .map(|value| if value.is_na() { None } else { Some(*value) })
            .collect_trusted();
        Ok(ca.with_name(name).into_series().into())
    }
}
