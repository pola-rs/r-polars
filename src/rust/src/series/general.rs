use crate::{PlRDataFrame, PlRDataType, PlRSeries, RPolarsErr, prelude::*};
use polars_core::series::IsSorted;
use savvy::{
    NullSexp, NumericScalar, NumericSexp, OwnedIntegerSexp, OwnedRawSexp, RawSexp, Result, Sexp,
    savvy,
};
use std::io::Cursor;

#[savvy]
impl PlRSeries {
    fn as_str(&self) -> Result<Sexp> {
        format!("{:?}", self.series).try_into()
    }

    // Similar to `__getstate__` in Python
    fn serialize(&self) -> Result<Sexp> {
        let bytes = self.series.serialize_to_bytes().map_err(RPolarsErr::from)?;
        OwnedRawSexp::try_from_iter(bytes).map(Into::into)
    }

    // Similar to `__setstate__` in Python
    fn deserialize(data: RawSexp) -> Result<Self> {
        let mut cursor = Cursor::new(data.as_slice());
        let series = Series::deserialize_from_reader(&mut cursor).map_err(|_| {
            RPolarsErr::Other("The input value is not a valid serialized Series.".to_string())
        })?;
        Ok(series.into())
    }

    fn struct_unnest(&self) -> Result<PlRDataFrame> {
        let ca = self.series.struct_().map_err(RPolarsErr::from)?;
        let df: DataFrame = ca.clone().unnest();
        Ok(df.into())
    }

    fn struct_fields(&self) -> Result<Sexp> {
        let ca = self.series.struct_().map_err(RPolarsErr::from)?;
        ca.struct_fields()
            .iter()
            .map(|s| s.name().as_str())
            .collect::<Vec<_>>()
            .try_into()
    }

    fn is_sorted_ascending_flag(&self) -> Result<Sexp> {
        matches!(self.series.is_sorted_flag(), IsSorted::Ascending).try_into()
    }

    fn is_sorted_descending_flag(&self) -> Result<Sexp> {
        matches!(self.series.is_sorted_flag(), IsSorted::Descending).try_into()
    }

    fn can_fast_explode_flag(&self) -> Result<Sexp> {
        let out = match self.series.list() {
            Err(_) => false,
            Ok(list) => list._can_fast_explode(),
        };
        out.try_into()
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

    fn chunk_lengths(&self) -> Result<Sexp> {
        let lengths: std::result::Result<Vec<i32>, _> = self
            .series
            .chunk_lengths()
            .map(|l| <i32>::try_from(l))
            .collect();
        lengths?.try_into()
    }

    pub fn rechunk(&mut self, in_place: bool) -> Result<Sexp> {
        let series = self.series.rechunk();
        if in_place {
            self.series = series;
            Ok(NullSexp.into())
        } else {
            PlRSeries::new(series).try_into()
        }
    }
}
