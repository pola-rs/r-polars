mod arithmetic;
mod construction;
mod export;
use crate::{prelude::*, PlRDataFrame, PlRDataType, RPolarsErr};
use savvy::{r_println, savvy, EnvironmentSexp, NumericSexp, Result, Sexp};

#[savvy]
#[repr(transparent)]
#[derive(Clone)]
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

impl From<EnvironmentSexp> for &PlRSeries {
    fn from(env: EnvironmentSexp) -> Self {
        let ptr = env.get(".ptr").unwrap().unwrap();
        <&PlRSeries>::try_from(ptr).unwrap()
    }
}

#[savvy]
impl PlRSeries {
    fn print(&self) -> Result<()> {
        r_println!("{:?}", self.series);
        Ok(())
    }

    fn struct_unnest(&self) -> Result<PlRDataFrame> {
        let ca = self.series.struct_().map_err(RPolarsErr::from)?;
        let df: DataFrame = ca.clone().into();
        Ok(df.into())
    }

    fn struct_fields(&self) -> Result<Sexp> {
        let ca = self.series.struct_().map_err(RPolarsErr::from)?;
        Ok(ca
            .fields()
            .iter()
            .map(|s| s.name())
            .collect::<Vec<_>>()
            .try_into()?)
    }

    fn reshape(&self, dimensions: NumericSexp) -> Result<Self> {
        let dimensions: Vec<i64> = <Wrap<Vec<i64>>>::try_from(dimensions)?.0;
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
        self.series.rename(name);
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

    fn cast(&self, dtype: PlRDataType, strict: bool) -> Result<Self> {
        let dtype = dtype.dt;
        let out = if strict {
            self.series.strict_cast(&dtype)
        } else {
            self.series.cast(&dtype)
        }
        .map_err(RPolarsErr::from)?;

        Ok(out.into())
    }
}
