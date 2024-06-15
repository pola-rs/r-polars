mod construction;

use crate::prelude::*;
use savvy::{r_println, savvy, Sexp};

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

    fn clone(&self) -> savvy::Result<Self> {
        Ok(self.series.clone().into())
    }

    fn name(&self) -> savvy::Result<Sexp> {
        self.series.name().to_string().try_into()
    }

    fn rename(&mut self, name: &str) -> savvy::Result<()> {
        self.series.rename(name);
        Ok(())
    }
}
