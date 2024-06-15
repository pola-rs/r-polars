use super::*;
use crate::{error::RPolarsErr, PlRSeries};
use savvy::{r_println, savvy, ListSexp, TypedSexp};

#[savvy]
impl PlRDataFrame {
    pub fn init(columns: ListSexp) -> savvy::Result<Self> {
        let columns: Vec<Series> = columns
            .iter()
            .map(|(name, column)| match column.into_typed() {
                TypedSexp::Environment(e) => {
                    let series = &<&PlRSeries>::from(e).series;
                    if name.is_empty() {
                        series.clone()
                    } else {
                        series.clone().rename(name).clone()
                    }
                }
                _ => unreachable!("Only accept a list of Series"),
            })
            .collect();
        let df = DataFrame::new(columns).map_err(RPolarsErr::from)?;
        Ok(Self { df })
    }

    pub fn print(&self) -> savvy::Result<()> {
        r_println!("{:?}", self.df);
        Ok(())
    }
}
