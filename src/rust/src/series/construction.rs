use crate::PlRSeries;
use polars_core::prelude::*;
use savvy::{savvy, RealSexp};

#[savvy]
impl PlRSeries {
    fn new_f32(name: &str, vector: RealSexp) -> savvy::Result<Self> {
        let vals = vector.as_slice();
        Ok(Series::new(name, vals).into())
    }
}
