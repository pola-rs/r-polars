use crate::error::RPolarsErr;
use crate::PlRSeries;
use savvy::savvy;

#[savvy]
impl PlRSeries {
    fn add(&self, other: &PlRSeries) -> savvy::Result<PlRSeries> {
        let out = self
            .series
            .try_add(&other.series)
            .map_err(RPolarsErr::from)?;
        Ok(out.into())
    }
    fn sub(&self, other: &PlRSeries) -> savvy::Result<PlRSeries> {
        Ok((&self.series - &other.series).into())
    }
    fn div(&self, other: &PlRSeries) -> savvy::Result<PlRSeries> {
        Ok((&self.series / &other.series).into())
    }
    fn mul(&self, other: &PlRSeries) -> savvy::Result<PlRSeries> {
        Ok((&self.series * &other.series).into())
    }
    fn rem(&self, other: &PlRSeries) -> savvy::Result<PlRSeries> {
        Ok((&self.series % &other.series).into())
    }
}
