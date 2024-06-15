mod general;

use savvy::{savvy, EnvironmentSexp};
use crate::prelude::*;

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

impl From<EnvironmentSexp> for &PlRDataFrame {
    fn from(env: EnvironmentSexp) -> Self {
        let ptr = env.get(".ptr").unwrap().unwrap();
        <&PlRDataFrame>::try_from(ptr).unwrap()
    }
}

impl PlRDataFrame {
    pub(crate) fn new(df: DataFrame) -> Self {
        Self { df }
    }
}
