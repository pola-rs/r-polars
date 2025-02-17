use super::*;
use crate::{PlRDataType, PlRLazyFrame, PlRSeries, RPolarsErr};
use savvy::{
    r_println, savvy, ListSexp, NumericScalar, OwnedIntegerSexp, OwnedListSexp, Result, Sexp,
    StringSexp, TypedSexp,
};

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

    pub fn print(&self) -> Result<()> {
        r_println!("{:?}", self.df);
        Ok(())
    }

    pub fn get_columns(&self) -> Result<Sexp> {
        let cols: Vec<Series> = self
            .df
            .get_columns()
            .to_vec()
            .into_iter()
            .map(|c| c.take_materialized_series())
            .collect();
        let len = cols.len();
        let mut list = OwnedListSexp::new(len, true)?;
        for i in 0..len {
            let _ = list.set_name_and_value(
                i,
                cols[i].name(),
                Sexp::try_from(PlRSeries::from(cols[i].clone()))?,
            );
        }
        Ok(list.into())
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
                .map(|x| PlSmallStr::from_str(*x))
                .collect(),
            index: index
                .to_vec()
                .iter()
                .map(|x| PlSmallStr::from_str(*x))
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
        columns: Option<StringSexp>,
        separator: Option<&str>,
    ) -> Result<Self> {
        let out = match columns {
            Some(cols) => self.df.columns_to_dummies(
                cols.iter().map(|x| x as &str).collect(),
                separator,
                drop_first,
            ),
            None => self.df.to_dummies(separator, drop_first),
        }
        .map_err(RPolarsErr::from)?;
        Ok(out.into())
    }
}
