use crate::{PlRSeries, RPolarsErr};
use savvy::{Result, savvy};

#[savvy]
impl PlRSeries {
    fn add(&self, other: &PlRSeries) -> Result<PlRSeries> {
        Ok((&self.series + &other.series)
            .map(Into::into)
            .map_err(RPolarsErr::from)?)
    }
    fn sub(&self, other: &PlRSeries) -> Result<PlRSeries> {
        Ok((&self.series - &other.series)
            .map(Into::into)
            .map_err(RPolarsErr::from)?)
    }
    fn div(&self, other: &PlRSeries) -> Result<PlRSeries> {
        Ok((&self.series / &other.series)
            .map(Into::into)
            .map_err(RPolarsErr::from)?)
    }
    fn mul(&self, other: &PlRSeries) -> Result<PlRSeries> {
        Ok((&self.series * &other.series)
            .map(Into::into)
            .map_err(RPolarsErr::from)?)
    }
    fn rem(&self, other: &PlRSeries) -> Result<PlRSeries> {
        Ok((&self.series % &other.series)
            .map(Into::into)
            .map_err(RPolarsErr::from)?)
    }
}
