use super::*;
use crate::{PlRDataType, PlRExpr, PlRLazyFrame, PlRSeries, RPolarsErr};
use either::Either;
use polars::prelude::pivot::{pivot, pivot_stable};
use savvy::{
    ListSexp, NumericScalar, OwnedIntegerSexp, OwnedListSexp, Result, Sexp, StringSexp, TypedSexp,
    savvy,
};
use std::{cmp::Ordering, hash::BuildHasher};

#[savvy]
impl PlRDataFrame {
    pub fn init(columns: ListSexp) -> Result<Self> {
        let columns: Vec<Series> = columns
            .iter()
            .map(|(name, column)| match column.into_typed() {
                TypedSexp::Environment(e) => {
                    let series = &<&PlRSeries>::from(e).series;
                    if name.is_empty() {
                        series.clone()
                    } else {
                        series.clone().rename(name.into()).clone()
                    }
                }
                _ => unreachable!("Only accept a list of Series"),
            })
            .collect();
        let columns = columns.into_iter().map(|s| s.into()).collect();
        let df = DataFrame::new(columns).map_err(RPolarsErr::from)?;
        Ok(df.into())
    }

    pub fn as_str(&self) -> Result<Sexp> {
        format!("{:?}", self.df).try_into()
    }

    pub fn get_columns(&self) -> Result<Sexp> {
        let cols: Vec<Series> = self
            .df
            .get_columns()
            .iter()
            .cloned()
            .map(|c| c.take_materialized_series())
            .collect();
        let mut list = OwnedListSexp::new(cols.len(), true)?;
        for (i, col) in cols.iter().enumerate() {
            let _ = list.set_name_and_value(
                i,
                col.name(),
                Sexp::try_from(PlRSeries::from(col.clone()))?,
            );
        }
        Ok(list.into())
    }

    pub fn get_column(&self, name: &str) -> Result<PlRSeries> {
        let series = self
            .df
            .column(name)
            .map(|s| PlRSeries::new(s.as_materialized_series().clone()))
            .map_err(RPolarsErr::from)?;
        Ok(series)
    }

    pub fn get_column_index(&self, name: &str) -> Result<Sexp> {
        let out = self
            .df
            .try_get_column_index(name)
            .map_err(RPolarsErr::from)?;
        (out as i32).try_into()
    }

    pub fn gather_with_series(&self, indices: &PlRSeries) -> Result<Self> {
        let indices = indices.series.idx().map_err(RPolarsErr::from)?;
        self.df
            .take(indices)
            .map_err(RPolarsErr::from)
            .map(Into::into)
            .map_err(Into::into)
    }

    pub fn transpose(
        &mut self,
        column_names: StringSexp,
        keep_names_as: Option<&str>,
    ) -> Result<Self> {
        let column_names = column_names.to_vec();
        let new_col_names = match column_names.len().cmp(&1) {
            Ordering::Less => None,
            Ordering::Equal => Some(Either::Left(column_names[0].to_string())),
            Ordering::Greater => Some(Either::Right(
                column_names.iter().map(|x| x.to_string()).collect(),
            )),
        };
        let out = self
            .df
            .transpose(keep_names_as, new_col_names)
            .map_err(RPolarsErr::from)?;
        Ok(out.into())
    }

    pub fn slice(&self, offset: NumericScalar, length: Option<NumericScalar>) -> Result<Self> {
        let offset = <Wrap<i64>>::try_from(offset)?.0;
        let length = length
            .map(<Wrap<usize>>::try_from)
            .transpose()?
            .map(|w| w.0);
        Ok(self
            .df
            .slice(offset, length.unwrap_or_else(|| self.df.height()))
            .into())
    }

    pub fn head(&self, n: NumericScalar) -> Result<Self> {
        let n = <Wrap<usize>>::try_from(n)?.0;
        Ok(self.df.head(Some(n)).into())
    }

    pub fn tail(&self, n: NumericScalar) -> Result<Self> {
        let n = <Wrap<usize>>::try_from(n)?.0;
        Ok(self.df.tail(Some(n)).into())
    }

    pub fn columns(&self) -> Result<Sexp> {
        self.df.get_column_names_str().try_into()
    }

    pub fn set_column_names(&mut self, names: StringSexp) -> Result<()> {
        self.df
            .set_column_names(names.iter())
            .map_err(RPolarsErr::from)?;
        Ok(())
    }

    pub fn dtypes(&self) -> Result<Sexp> {
        let iter = self
            .df
            .iter()
            .map(|s| <PlRDataType>::from(s.dtype().clone()));
        let mut list = OwnedListSexp::new(self.df.width(), false)?;
        for (i, dtype) in iter.enumerate() {
            unsafe {
                list.set_value_unchecked(i, Sexp::try_from(dtype)?.0);
            }
        }
        Ok(list.into())
    }

    pub fn shape(&self) -> Result<Sexp> {
        let shape = self.df.shape();
        OwnedIntegerSexp::try_from_slice([shape.0 as i32, shape.1 as i32])?.into()
    }

    pub fn height(&self) -> Result<Sexp> {
        (self.df.height() as i32).try_into()
    }

    pub fn width(&self) -> Result<Sexp> {
        (self.df.width() as i32).try_into()
    }

    pub fn to_series(&self, index: NumericScalar) -> Result<PlRSeries> {
        let df = &self.df;
        let index = index.as_i32()? as isize;

        let index_adjusted = if index < 0 {
            df.width().checked_sub(index.unsigned_abs())
        } else {
            Some(usize::try_from(index).unwrap())
        };

        let s = index_adjusted.and_then(|i| df.select_at_idx(i));
        match s {
            Some(s) => Ok(PlRSeries::new(s.as_materialized_series().clone())),
            None => Err(polars_err!(oob = index, df.width()).to_string().into()),
        }
    }

    pub fn equals(&self, other: &PlRDataFrame, null_equal: bool) -> Result<Sexp> {
        if null_equal {
            self.df.equals_missing(&other.df).try_into()
        } else {
            self.df.equals(&other.df).try_into()
        }
    }

    #[allow(clippy::should_implement_trait)]
    pub fn clone(&self) -> Result<Self> {
        Ok(self.df.clone().into())
    }

    pub fn lazy(&self) -> Result<PlRLazyFrame> {
        Ok(self.df.clone().lazy().into())
    }

    pub fn to_struct(&self, name: &str) -> Result<PlRSeries> {
        let s = self.df.clone().into_struct(name.into());
        Ok(s.into_series().into())
    }

    pub fn n_chunks(&self) -> Result<Sexp> {
        (self.df.first_col_n_chunks() as i32).try_into()
    }

    pub fn rechunk(&self) -> Result<Self> {
        let mut df = self.df.clone();
        df.as_single_chunk_par();
        Ok(df.into())
    }

    pub fn clear(&self) -> Result<Self> {
        Ok(self.df.clear().into())
    }

    pub fn unpivot(
        &self,
        on: StringSexp,
        index: StringSexp,
        value_name: Option<&str>,
        variable_name: Option<&str>,
    ) -> Result<Self> {
        let args = UnpivotArgsIR {
            on: on
                .to_vec()
                .iter()
                .map(|x| PlSmallStr::from_str(x))
                .collect(),
            index: index
                .to_vec()
                .iter()
                .map(|x| PlSmallStr::from_str(x))
                .collect(),
            value_name: value_name.map(|s| s.into()),
            variable_name: variable_name.map(|s| s.into()),
        };
        let out = self.df.unpivot2(args).map_err(RPolarsErr::from)?;

        Ok(out.into())
    }

    pub fn to_dummies(
        &self,
        drop_first: bool,
        drop_nulls: bool,
        columns: Option<StringSexp>,
        separator: Option<&str>,
    ) -> Result<Self> {
        let out = match columns {
            Some(cols) => self.df.columns_to_dummies(
                cols.iter().map(|x| x as &str).collect(),
                separator,
                drop_first,
                drop_nulls,
            ),
            None => self.df.to_dummies(separator, drop_first, drop_nulls),
        }
        .map_err(RPolarsErr::from)?;
        Ok(out.into())
    }

    pub fn pivot_expr(
        &self,
        on: StringSexp,
        maintain_order: bool,
        sort_columns: bool,
        aggregate_expr: Option<&PlRExpr>,
        separator: Option<&str>,
        index: Option<StringSexp>,
        values: Option<StringSexp>,
    ) -> Result<Self> {
        let fun = if maintain_order { pivot_stable } else { pivot };
        let agg_expr = aggregate_expr.map(|expr| expr.inner.clone());
        let on = on.to_vec();
        let index = index.map(|x| x.to_vec());
        let values = values.map(|x| x.to_vec());
        let out = fun(
            &self.df,
            on,
            index,
            values,
            sort_columns,
            agg_expr,
            separator,
        )
        .map_err(RPolarsErr::from)?;
        Ok(out.into())
    }

    pub fn partition_by(
        &self,
        by: StringSexp,
        maintain_order: bool,
        include_key: bool,
    ) -> Result<Sexp> {
        let by = by.to_vec();
        let res = if maintain_order {
            self.df.partition_by_stable(by, include_key)
        } else {
            self.df.partition_by(by, include_key)
        }
        .map_err(RPolarsErr::from)?;

        let mut out = OwnedListSexp::new(res.len(), false)?;
        for (i, df) in res.iter().enumerate() {
            let _ = out.set_value(i, Sexp::try_from(PlRDataFrame::from(df.clone()))?);
        }

        Ok(out.into())
    }

    pub fn is_unique(&self) -> Result<PlRSeries> {
        Ok(self
            .df
            .is_unique()
            .map_err(RPolarsErr::from)?
            .into_series()
            .into())
    }

    pub fn is_duplicated(&self) -> Result<PlRSeries> {
        Ok(self
            .df
            .is_duplicated()
            .map_err(RPolarsErr::from)?
            .into_series()
            .into())
    }

    pub fn is_empty(&self) -> Result<Sexp> {
        self.df.is_empty().try_into()
    }

    fn with_row_index(&self, name: &str, offset: Option<NumericScalar>) -> Result<Self> {
        let offset: Option<u32> = match offset {
            Some(x) => Some(<Wrap<u32>>::try_from(x)?.0),
            None => None,
        };
        Ok(self
            .df
            .with_row_index(name.into(), offset)
            .map_err(RPolarsErr::from)?
            .into())
    }

    pub fn sample_n(
        &self,
        n: &PlRSeries,
        with_replacement: bool,
        shuffle: bool,
        seed: Option<NumericScalar>,
    ) -> Result<Self> {
        let seed = match seed {
            Some(x) => Some(<Wrap<u64>>::try_from(x)?.0),
            None => None,
        };
        Ok(self
            .df
            .sample_n(&n.series, with_replacement, shuffle, seed)
            .map_err(RPolarsErr::from)?
            .into())
    }

    pub fn sample_frac(
        &self,
        frac: &PlRSeries,
        with_replacement: bool,
        shuffle: bool,
        seed: Option<NumericScalar>,
    ) -> Result<Self> {
        let seed = match seed {
            Some(x) => Some(<Wrap<u64>>::try_from(x)?.0),
            None => None,
        };
        Ok(self
            .df
            .sample_frac(&frac.series, with_replacement, shuffle, seed)
            .map_err(RPolarsErr::from)?
            .into())
    }

    pub fn hash_rows(
        &mut self,
        seed: NumericScalar,
        seed_1: NumericScalar,
        seed_2: NumericScalar,
        seed_3: NumericScalar,
    ) -> Result<PlRSeries> {
        let k0 = <Wrap<u64>>::try_from(seed)?.0;
        let k1 = <Wrap<u64>>::try_from(seed_1)?.0;
        let k2 = <Wrap<u64>>::try_from(seed_2)?.0;
        let k3 = <Wrap<u64>>::try_from(seed_3)?.0;
        let seed = PlFixedStateQuality::default().hash_one((k0, k1, k2, k3));
        let hb = PlSeedableRandomStateQuality::seed_from_u64(seed);
        let series = self
            .df
            .hash_rows(Some(hb))
            .map_err(RPolarsErr::from)?
            .into_series();
        Ok(series.into())
    }
}
