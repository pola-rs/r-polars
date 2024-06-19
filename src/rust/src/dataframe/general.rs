use super::*;
use crate::{error::RPolarsErr, PlRLazyFrame, PlRSeries};
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
        Ok(df.into())
    }

    pub fn print(&self) -> savvy::Result<()> {
        r_println!("{:?}", self.df);
        Ok(())
    }

    pub fn to_struct(&self, name: &str) -> savvy::Result<PlRSeries> {
        let s = self.df.clone().into_struct(name);
        Ok(s.into_series().into())
    }

    pub fn lazy(&self) -> savvy::Result<PlRLazyFrame> {
        Ok(self.df.clone().lazy().into())
    }
}
