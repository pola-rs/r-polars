use super::*;
use crate::{error::RPolarsErr, series::ToRSeries, PlRLazyFrame, PlRSeries};
use savvy::{r_println, savvy, ListSexp, OwnedListSexp, Sexp, StringSexp, TypedSexp};

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

    pub fn get_columns(&self) -> savvy::Result<Sexp> {
        let cols = self.df.get_columns().to_owned().to_r_series();
        let len = cols.len();
        let mut list = OwnedListSexp::new(len, true)?;
        for i in 0..len {
            let _ = list.set_name_and_value(
                i,
                cols[i].series.name(),
                Sexp::try_from(cols[i].clone()?)?,
            );
        }
        Ok(list.into())
    }

    pub fn to_struct(&self, name: &str) -> savvy::Result<PlRSeries> {
        let s = self.df.clone().into_struct(name);
        Ok(s.into_series().into())
    }

    pub fn lazy(&self) -> savvy::Result<PlRLazyFrame> {
        Ok(self.df.clone().lazy().into())
    }
}
