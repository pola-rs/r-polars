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
                    let ptr = e.get(".ptr").unwrap().unwrap();
                    let r_series = <&PlRSeries>::try_from(ptr).unwrap();
                    if name.is_empty() {
                        r_series.series.clone()
                    } else {
                        r_series.series.clone().rename(name).clone()
                    }
                }
                _ => unreachable!("Only accept a list of Series"),
            })
            .collect();
        let df = DataFrame::new(columns).map_err(RPolarsErr::from)?;
        Ok(Self { df })
    }

    pub fn as_str(&self) -> savvy::Result<()> {
        r_println!("{:?}", self.df);
        Ok(())
    }
}
