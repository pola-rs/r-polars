use crate::{prelude::*, PlRSeries};
use polars_core::utils::arrow::{
    array::Array,
    ffi::{ArrowArrayStream, ArrowArrayStreamReader},
};
use savvy::{savvy, ExternalPointerSexp, Result, Sexp};

// TODO: implement upstream polars
#[savvy]
impl PlRSeries {
    pub fn from_arrow_c_stream(stream_ptr: Sexp) -> Result<Self> {
        let mut stream = unsafe {
            let stream_ptr = Box::new(std::ptr::replace(
                ExternalPointerSexp::try_from(stream_ptr)?.cast_mut_unchecked::<ArrowArrayStream>(),
                ArrowArrayStream::empty(),
            ));
            ArrowArrayStreamReader::try_new(stream_ptr).map_err(|e| e.to_string())?
        };
        let mut produced_arrays: Vec<Box<dyn Array>> = vec![];
        while let Some(array) = unsafe { stream.next() } {
            produced_arrays.push(array.unwrap());
        }

        let s = if produced_arrays.is_empty() {
            // TODO: Should not panic for non-supported types like UnionType
            let polars_dt = DataType::from_arrow_field(stream.field());
            Series::new_empty(stream.field().name.clone(), &polars_dt)
        } else {
            Series::try_from((stream.field(), produced_arrays)).map_err(|e| e.to_string())?
        };
        Ok(s.into())
    }
}
