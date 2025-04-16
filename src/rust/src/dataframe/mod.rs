mod general;
mod io;
mod serde;

use crate::prelude::*;
use savvy::{EnvironmentSexp, savvy};

#[savvy]
#[derive(Clone)]
pub struct PlRDataFrame {
    pub df: DataFrame,
}

impl From<DataFrame> for PlRDataFrame {
    fn from(df: DataFrame) -> Self {
        Self { df }
    }
}

impl TryFrom<EnvironmentSexp> for &PlRDataFrame {
    type Error = String;

    fn try_from(env: EnvironmentSexp) -> Result<Self, String> {
        let ptr = env
            .get(".ptr")
            .expect("Failed to get `.ptr` from the object")
            .ok_or("The object is not a valid polars data frame")?;
        <&PlRDataFrame>::try_from(ptr).map_err(|e| e.to_string())
    }
}
