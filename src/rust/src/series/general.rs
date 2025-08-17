use crate::{PlRDataFrame, PlRDataType, PlRSeries, RPolarsErr, prelude::*};
use polars_core::series::IsSorted;
use savvy::{NullSexp, NumericScalar, NumericSexp, OwnedRawSexp, RawSexp, Result, Sexp, savvy};
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
        true.try_into()
    }

    pub fn cat_is_local(&self) -> Result<Sexp> {
        false.try_into()
    }

    pub fn cat_to_local(&self) -> Result<Self> {
        self.clone()
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

    fn get_fmt(&self, str_len_limit: NumericScalar) -> Result<Sexp> {
        let str_len_limit = <Wrap<usize>>::try_from(str_len_limit)?.0;

        // Same as Python Polars' `PySeries::get_fmt`
        fn get_fmt_each(series: &Series, index: usize, str_len_limit: usize) -> String {
            let v = format!("{}", series.get(index).unwrap());
            if let DataType::String | DataType::Categorical(_, _) | DataType::Enum(_, _) =
                series.dtype()
            {
                let v_no_quotes = &v[1..v.len() - 1];
                let v_trunc = &v_no_quotes[..v_no_quotes
                    .char_indices()
                    .take(str_len_limit)
                    .last()
                    .map(|(i, c)| i + c.len_utf8())
                    .unwrap_or(0)];
                if v_no_quotes == v_trunc {
                    v
                } else {
                    format!("\"{v_trunc}…")
                }
            } else {
                v
            }
        }

        (0..self.series.len())
            .map(|i| get_fmt_each(&self.series, i, str_len_limit))
            .collect::<Vec<_>>()
            .try_into()
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
        let lengths: std::result::Result<Vec<i32>, _> =
            self.series.chunk_lengths().map(<i32>::try_from).collect();
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

    pub fn shrink_dtype(&self) -> Result<Self> {
        self.series
            .shrink_type()
            .map(Into::into)
            .map_err(RPolarsErr::from)
            .map_err(Into::into)
    }

    fn str_to_datetime_infer(
        &self,
        strict: bool,
        exact: bool,
        ambiguous: &PlRSeries,
        time_unit: Option<&str>,
    ) -> Result<Self> {
        let time_unit = time_unit.map(<Wrap<TimeUnit>>::try_from).transpose()?;
        let datetime_strings = self.series.str().map_err(RPolarsErr::from)?;
        let ambiguous = ambiguous.series.str().map_err(RPolarsErr::from)?;

        polars::time::prelude::string::infer::to_datetime_with_inferred_tz(
            datetime_strings,
            time_unit.map_or(TimeUnit::Microseconds, |v| v.0),
            strict,
            exact,
            ambiguous,
        )
        .map(IntoSeries::into_series)
        .map(PlRSeries::from)
        .map_err(RPolarsErr::from)
        .map_err(Into::into)
    }

    pub fn str_to_decimal_infer(&self, inference_length: NumericScalar) -> Result<Self> {
        let inference_length = <Wrap<usize>>::try_from(inference_length)?.0;
        let ca = self.series.str().map_err(RPolarsErr::from)?;
        ca.to_decimal_infer(inference_length)
            .map(Into::into)
            .map_err(RPolarsErr::from)
            .map_err(Into::into)
    }

    fn list_to_struct(
        &self,
        n_field_strategy: &str,
        name_gen: Option<savvy::FunctionSexp>,
    ) -> Result<Self> {
        let infer_field_strategy = Wrap::<ListToStructWidthStrategy>::try_from(n_field_strategy)?.0;

        #[cfg(not(target_arch = "wasm32"))]
        use crate::r_udf::RUdf;

        #[cfg(not(target_arch = "wasm32"))]
        let get_index_name = name_gen
            .map(|lambda| <PlanCallback<usize, String>>::from(RUdf::new(lambda)))
            .map(|f| NameGenerator(Arc::new(move |i| f.call(i).map(PlSmallStr::from)) as Arc<_>));
        #[cfg(target_arch = "wasm32")]
        let get_index_name = match name_gen {
            Some(_) => {
                return Err(crate::RPolarsErr::Other(
                    "Specifying a function name generator is not supported in WASM".to_string(),
                )
                .into());
            }
            None => None,
        };

        self.series
            .list()
            .map_err(RPolarsErr::from)?
            .to_struct(&ListToStructArgs::InferWidth {
                infer_field_strategy,
                get_index_name,
                max_fields: None,
            })
            .map(IntoSeries::into_series)
            .map(PlRSeries::from)
            .map_err(RPolarsErr::from)
            .map_err(Into::into)
    }

    fn str_json_decode(&self, infer_schema_length: Option<NumericScalar>) -> Result<Self> {
        #[cfg(not(target_arch = "wasm32"))]
        {
            let infer_schema_length = infer_schema_length
                .map(|l| <Wrap<usize>>::try_from(l).map(|l| l.0))
                .transpose()?;
            self.series
                .str()
                .map_err(RPolarsErr::from)?
                .json_decode(None, infer_schema_length)
                .map(|s| s.with_name(self.series.name().clone()))
                .map(PlRSeries::from)
                .map_err(RPolarsErr::from)
                .map_err(Into::into)
        }

        #[cfg(target_arch = "wasm32")]
        {
            Err(RPolarsErr::Other(format!("Not supported in WASM")).into())
        }
    }
}
