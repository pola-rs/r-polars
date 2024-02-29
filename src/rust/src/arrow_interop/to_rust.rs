use crate::rpolarserr::*;
use extendr_api::prelude::*;
use polars::prelude as pl;
use polars_core::export::rayon::prelude::*;
use polars_core::prelude::*;
use polars_core::utils::accumulate_dataframes_vertical_unchecked;
use polars_core::utils::arrow::ffi;
use polars_core::POOL;
use std::result::Result;

use super::RArrowArrayClass;

pub fn arrow_array_to_rust(arrow_array: Robj) -> Result<ArrayRef, String> {
    let mut array = Box::new(ffi::ArrowArray::empty());
    let mut schema = Box::new(ffi::ArrowSchema::empty());
    let (ext_a, ext_s) = unsafe {
        (
            wrap_make_external_ptr(&mut *array),
            wrap_make_external_ptr(&mut *schema),
        )
    };

    RArrowArrayClass::from_robj(&arrow_array)?
        .get_package()
        .get_export_array_func()?
        .call(pairlist!(&arrow_array, ext_a, ext_s))?;

    let array = unsafe {
        let field = ffi::import_field_from_c(schema.as_ref()).map_err(|err| err.to_string())?;
        ffi::import_array_from_c(*array, field.data_type).map_err(|err| err.to_string())?
    };
    Ok(array)
}

unsafe fn wrap_make_external_ptr<T>(t: &mut T) -> Robj {
    unsafe { <Integers>::make_external_ptr(t, r!(extendr_api::NULL)) }
}

pub fn to_rust_df(rb: Robj) -> Result<pl::DataFrame, String> {
    let rb = rb.as_list().ok_or("arrow record batches is not a List")?;
    let get_columns_f = R!(r"\(x) x$columns")?.as_function().unwrap();

    //read columns names of first batch, if not any batches return empty DataFrame
    let robj_record_batch_names = if let Ok(first_rb) = rb.elt(0) {
        call!(r"\(x) x$schema$names", first_rb).map_err(|err| format!("internal error: {}", err))?
    } else {
        return Ok(pl::DataFrame::default());
    };
    let names = robj_record_batch_names
        .as_str_vector()
        .ok_or_else(|| "internal error: Robj$schema$names is not a char vec".to_string())?;

    //iterate over record batches
    let rb_len = rb.len();
    let dfs_iter = rb.iter().map(|(_, rb)| {
        //do not run parallel unless data.type matches ...
        let mut run_parallel = false;

        //get list of columns for this record batch
        let columns_list = get_columns_f
            .call(pairlist!(rb))?
            .as_list()
            .expect("arrow columns always wrapped in list");
        let n_columns = columns_list.len();

        //collect vector of exported arrow arrays, one for each column
        let array_iter = columns_list.into_iter().map(|(_, column)| {
            let arr = arrow_array_to_rust(column)?;
            run_parallel |= matches!(
                arr.data_type(),
                ArrowDataType::Utf8 | ArrowDataType::Dictionary(_, _, _)
            );
            let list_res: Result<_, String> = Ok(arr);
            list_res
        });
        let arrays_vec = crate::utils::collect_hinted_result(n_columns, array_iter)?;

        // we parallelize this part because we can have dtypes that are not zero copy
        // for instance utf8 -> large-utf8
        // dict encoded to categorical

        let series_vec = if run_parallel {
            POOL.install(|| {
                arrays_vec
                    .into_par_iter()
                    .zip(names.par_iter())
                    .map(|(arr, name)| {
                        let s = Series::try_from((*name, arr)).map_err(|err| err.to_string())?;
                        Ok(s)
                    })
                    .collect::<Result<Vec<_>, String>>()
            })
        } else {
            let iter = arrays_vec.into_iter().zip(names.iter()).map(|(arr, name)| {
                let s = Series::try_from((*name, arr)).map_err(|err| err.to_string())?;
                Ok(s)
            });
            crate::utils::collect_hinted_result(n_columns, iter)
        }?;

        // no need to check as a record batch has the same guarantees
        let df_res: Result<_, String> = Ok(DataFrame::new(series_vec).unwrap());
        df_res
    });
    let dfs = crate::utils::collect_hinted_result(rb_len, dfs_iter)?;
    Ok(accumulate_dataframes_vertical_unchecked(dfs))
}

// r-polars as consumer 1: create a new stream and wrap pointer in Robj as str.
pub fn new_arrow_stream_internal() -> Robj {
    let aas = Box::new(ffi::ArrowArrayStream::empty());
    let x = Box::leak(aas); // leak box to make lifetime static
    let x = x as *mut ffi::ArrowArrayStream;
    crate::utils::usize_to_robj_str(x as usize)
}

// r-polars as consumer 2: recieve to pointer to own stream, which producer has exported to. Consume it. Return Series.
pub fn arrow_stream_to_series_internal(robj_str: Robj) -> RResult<pl::Series> {
    // reclaim ownership of leaked box, and then drop/release it when consumed.
    let us = crate::utils::robj_str_ptr_to_usize(&robj_str)?;
    let boxed_stream = unsafe { Box::from_raw(us as *mut ffi::ArrowArrayStream) };

    //consume stream and produce a r-polars Series return as Robj
    let s = consume_arrow_stream_to_series(boxed_stream)?;
    Ok(s)
}

// implementation of consuming stream to Series. Stream is drop/released hereafter.
fn consume_arrow_stream_to_series(boxed_stream: Box<ffi::ArrowArrayStream>) -> RResult<pl::Series> {
    let mut iter = unsafe { ffi::ArrowArrayStreamReader::try_new(boxed_stream) }?;

    //import first array into pl::Series
    let mut s = if let Some(array_res) = unsafe { iter.next() } {
        let array = array_res?;
        let series_res: pl::PolarsResult<pl::Series> =
            std::convert::TryFrom::try_from(("df", array));

        series_res.map_err(polars_to_rpolars_err)?
    } else {
        rerr()
            .plain("Arrow array stream was empty")
            .hint("producer did not export to stream")
            .when("consuming arrow array stream")?;
        unreachable!();
    };

    // append any other arrays to Series
    while let Some(array_res) = unsafe { iter.next() } {
        let array = array_res?;
        let series_res: pl::PolarsResult<pl::Series> =
            std::convert::TryFrom::try_from(("df", array));
        let series = series_res.map_err(polars_to_rpolars_err)?;
        s.append(&series).map_err(polars_to_rpolars_err)?;
    }
    Ok(s)
}

pub unsafe fn export_df_as_stream(df: pl::DataFrame, robj_str_ref: &Robj) -> RResult<()> {
    let stream_ptr =
        crate::utils::robj_str_ptr_to_usize(robj_str_ref)? as *mut ffi::ArrowArrayStream;
    let schema = df.schema().to_arrow(true);
    let data_type = pl::ArrowDataType::Struct(schema.fields);
    let field = pl::ArrowField::new("", data_type, false);
    let iter_boxed = Box::new(crate::rdataframe::OwnedDataFrameIterator::new(df));
    unsafe { *stream_ptr = ffi::export_iterator(iter_boxed, field) };
    Ok(())
}
