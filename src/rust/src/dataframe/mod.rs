mod general;

use savvy::savvy;
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
impl PlRDataFrame {
    pub(crate) fn new(df: DataFrame) -> Self {
        Self { df }
    }
}
