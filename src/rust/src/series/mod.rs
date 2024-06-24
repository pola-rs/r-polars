mod arithmetic;
mod construction;
mod export;
use crate::{prelude::*, PlRDataFrame, PlRDataType, RPolarsErr};
use savvy::{r_println, savvy, EnvironmentSexp, Result, Sexp};

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

pub(crate) trait ToRSeries {
    fn to_r_series(self) -> Vec<PlRSeries>;
}

impl ToRSeries for Vec<Series> {
    fn to_r_series(self) -> Vec<PlRSeries> {
        // SAFETY: repr is transparent.
        unsafe { std::mem::transmute(self) }
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
