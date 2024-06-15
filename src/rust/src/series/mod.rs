mod construction;

use crate::prelude::*;
use savvy::{r_println, savvy};

#[savvy]
pub struct PlRSeries {
    pub series: Series,
}

impl From<Series> for PlRSeries {
    fn from(series: Series) -> Self {
        Self { series }
    }
}

impl PlRSeries {
    pub(crate) fn new(series: Series) -> Self {
        Self { series }
    }
}

#[savvy]
impl PlRSeries {
    fn print(&self) -> savvy::Result<()> {
        r_println!("{:?}", self.series);
        Ok(())
    }
}
