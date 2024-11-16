use crate::{prelude::*, PlRDataFrame, PlRDataType, PlRSeries, RPolarsErr};
use savvy::{r_println, savvy, NumericScalar, NumericSexp, Result, Sexp};

#[savvy]
impl PlRSeries {
    fn print(&self) -> Result<()> {
        r_println!("{:?}", self.series);
        Ok(())
    }

    fn struct_unnest(&self) -> Result<PlRDataFrame> {
        let ca = self.series.struct_().map_err(RPolarsErr::from)?;
        let df: DataFrame = ca.clone().unnest();
        Ok(df.into())
    }

    fn struct_fields(&self) -> Result<Sexp> {
        let ca = self.series.struct_().map_err(RPolarsErr::from)?;
        Ok(ca
            .struct_fields()
            .iter()
            .map(|s| s.name().as_str())
            .collect::<Vec<_>>()
            .try_into()?)
    }

    pub fn cat_uses_lexical_ordering(&self) -> Result<Sexp> {
        let ca = self.series.categorical().map_err(RPolarsErr::from)?;
        ca.uses_lexical_ordering().try_into()
    }

    pub fn cat_is_local(&self) -> Result<Sexp> {
        let ca = self.series.categorical().map_err(RPolarsErr::from)?;
        ca.get_rev_map().is_local().try_into()
    }

    pub fn cat_to_local(&self) -> Result<Self> {
        let ca = self.series.categorical().map_err(RPolarsErr::from)?;
        Ok(ca.to_local().into_series().into())
    }

    fn reshape(&self, dimensions: NumericSexp) -> Result<Self> {
        let dimensions = <Wrap<Vec<i64>>>::try_from(dimensions)?
            .0
            .into_iter()
            .map(ReshapeDimension::new)
            .collect::<Vec<_>>();
        let out = self
            .series
            .reshape_array(&dimensions)
            .map_err(RPolarsErr::from)?;
        Ok(out.into())
    }

    fn clone(&self) -> Result<Self> {
        Ok(self.series.clone().into())
    }

    fn name(&self) -> Result<Sexp> {
        self.series.name().to_string().try_into()
    }

    fn rename(&mut self, name: &str) -> Result<()> {
        self.series.rename(name.into());
        Ok(())
    }

    fn dtype(&self) -> Result<PlRDataType> {
        Ok(self.series.dtype().clone().into())
    }

    fn equals(
        &self,
        other: &PlRSeries,
        check_dtypes: bool,
        check_names: bool,
        null_equal: bool,
    ) -> Result<Sexp> {
        if check_dtypes && (self.series.dtype() != other.series.dtype()) {
            return false.try_into();
        }
        if check_names && (self.series.name() != other.series.name()) {
            return false.try_into();
        }

        if null_equal {
            self.series.equals_missing(&other.series).try_into()
        } else {
            self.series.equals(&other.series).try_into()
        }
    }

    fn len(&self) -> Result<Sexp> {
        (self.series.len() as i32).try_into()
    }

    fn cast(&self, dtype: &PlRDataType, strict: bool) -> Result<Self> {
        let dtype = dtype.dt.clone();
        let out = if strict {
            self.series.strict_cast(&dtype)
        } else {
            self.series.cast(&dtype)
        }
        .map_err(RPolarsErr::from)?;

        Ok(out.into())
    }

    fn slice(&self, offset: NumericScalar, length: Option<NumericScalar>) -> Result<Self> {
        let offset = <Wrap<i64>>::try_from(offset)?.0;
        let length = length
            .map(|l| <Wrap<usize>>::try_from(l).map(|l| l.0))
            .unwrap_or_else(|| Ok(self.series.len()))?;
        Ok(self.series.slice(offset, length).into())
    }

    fn n_chunks(&self) -> Result<Sexp> {
        (self.series.n_chunks() as i32).try_into()
    }
}
