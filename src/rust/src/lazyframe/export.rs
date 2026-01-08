use crate::{PlRLazyFrame, RPolarsErr, prelude::*};
use parking_lot::Mutex;
use polars_core::utils::arrow::ffi::{ArrowArrayStream, export_iterator};
use savvy::{ExternalPointerSexp, NumericScalar, Result, Sexp, savvy};
use std::num::NonZeroUsize;

#[savvy]
impl PlRLazyFrame {
    // TODO: move to upstream polars
    pub fn to_arrow_c_stream(
        &self,
        stream_ptr: Sexp,
        polars_compat_level: Sexp,
        engine: &str,
        maintain_order: bool,
        chunk_size: Option<NumericScalar>,
    ) -> Result<()> {
        let stream_ptr = unsafe {
            ExternalPointerSexp::try_from(stream_ptr)?.cast_mut_unchecked::<ArrowArrayStream>()
        };

        let compat_level = <Wrap<CompatLevel>>::try_from(polars_compat_level)?.0;
        let engine = <Wrap<Engine>>::try_from(engine)?.0;
        let chunk_size = match chunk_size {
            Some(cs) => Some(<Wrap<NonZeroUsize>>::try_from(cs)?.0),
            None => None,
        };

        let schema = self
            .ldf
            .clone()
            .collect_schema()
            .map_err(RPolarsErr::from)?
            .to_arrow(compat_level);
        let dtype = ArrowDataType::Struct(schema.clone().into_iter_values().collect());

        let batches = self
            .ldf
            .clone()
            .collect_batches(engine, maintain_order, chunk_size, true)
            .map_err(RPolarsErr::from)?;
        let iter = Box::new(ArrowStreamIterator::new(batches, compat_level, dtype));
        let field = iter.field();
        let stream = export_iterator(iter, field);
        unsafe {
            std::ptr::replace(stream_ptr, stream);
        }
        Ok(())
    }
}

pub struct ArrowStreamIterator {
    inner: Mutex<CollectBatches>,
    compat_level: CompatLevel,
    dtype: ArrowDataType,
}

impl ArrowStreamIterator {
    fn new(iter: CollectBatches, compat_level: CompatLevel, dtype: ArrowDataType) -> Self {
        Self {
            inner: Mutex::new(iter),
            compat_level,
            dtype,
        }
    }

    fn field(&self) -> ArrowField {
        ArrowField::new(PlSmallStr::EMPTY, self.dtype.clone(), false)
    }
}

impl Iterator for ArrowStreamIterator {
    type Item = PolarsResult<ArrayRef>;

    fn next(&mut self) -> Option<Self::Item> {
        let next = self.inner.lock().next();

        match next {
            None => None,
            Some(Err(err)) => Some(Err(err)),
            Some(Ok(df)) => {
                let series = df.clone().into_struct(PlSmallStr::EMPTY).into_series();
                let batch = series.rechunk().to_arrow(0, self.compat_level);
                Some(Ok(batch))
            }
        }
    }
}
