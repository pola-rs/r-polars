use extendr_api::prelude::*;
use polars::prelude as pl;
use polars_core::export::rayon::prelude::*;
use polars_core::prelude::*;
use polars_core::utils::accumulate_dataframes_vertical_unchecked;
use polars_core::utils::arrow::ffi;
use polars_core::POOL;
use std::result::Result;

//does not support chunked array
pub fn arrow_array_to_rust(
    arrow_array: Robj,
    opt_f: Option<&Function>,
) -> Result<ArrayRef, String> {
    let mut array = Box::new(ffi::ArrowArray::empty());
    let mut schema = Box::new(ffi::ArrowSchema::empty());
    let (ext_a, ext_s) = unsafe {
        (
            wrap_make_external_ptr(&mut *array),
            wrap_make_external_ptr(&mut *schema),
        )
    };

    if let Some(f) = opt_f {
        f.call(pairlist!(arrow_array, ext_a, ext_s))?;
    } else {
        call!("arrow:::ExportArray", arrow_array, ext_a, ext_s)?;
    };

    let array = unsafe {
        let field = ffi::import_field_from_c(schema.as_ref()).map_err(|err| err.to_string())?;
        ffi::import_array_from_c(*array, field.data_type).map_err(|err| err.to_string())?
    };
    //dbg!(&array);
    Ok(array)
}

unsafe fn wrap_make_external_ptr<T>(t: &mut T) -> Robj {
    //use extendr_api::{Integers, Rinternals};
    unsafe { <Integers>::make_external_ptr(t, r!(extendr_api::NULL)) }
}
//does not support chunked array
pub fn arrow_array_stream_to_rust(
    arrow_stream_reader: Robj,
    opt_f: Option<&Function>,
) -> Result<ArrayRef, String> {
    let mut stream = Box::new(ffi::ArrowArrayStream::empty());
    //let mut schema = Box::new(ffi::ArrowSchema::empty());
    let ext_stream = unsafe { wrap_make_external_ptr(&mut *stream) };

    if let Some(f) = opt_f {
        f.call(pairlist!(arrow_stream_reader, ext_stream))?;
    } else {
        call!(r"\(x,y) x$export_to_c(y)", arrow_stream_reader, ext_stream)?;
    };
    dbg!("after export");

    let mut iter =
        unsafe { ffi::ArrowArrayStreamReader::try_new(stream) }.map_err(|err| err.to_string())?;
    dbg!("after reader");

    while let Some(array_res) = unsafe { iter.next() } {
        let array = array_res.map_err(|err| err.to_string())?;
        dbg!(&array);
    }

    todo!("not  more for now");
}

pub fn rb_to_rust_df(r_rb_columns: List, names: &[String]) -> Result<pl::DataFrame, String> {
    let n_col = r_rb_columns.len();
    let f = R!("arrow:::ExportArray")?
        .as_function()
        .expect("could not find Arrow");
    let col_iter = r_rb_columns
        .into_iter()
        .zip(names.iter())
        .map(|((_, r_array), str)| {
            let arr = arrow_array_to_rust(r_array, Some(&f))?;
            let s = <polars::prelude::Series>::try_from((str.as_str(), arr))
                .map_err(|err| err.to_string());
            s
        });
    let s_vec_res = crate::utils::collect_hinted_result(n_col, col_iter);

    Ok(pl::DataFrame::new_no_checks(s_vec_res?))
}

pub fn to_rust_df(rb: Robj) -> Result<pl::DataFrame, String> {
    let rb = rb.as_list().ok_or("arrow record batches is not a List")?;

    //prepare function calls to R package arrow
    let export_array_f = R!("arrow:::ExportArray")?.as_function().ok_or_else(|| {
        "could not find arrow:::ExportArray is R package arrow installed?".to_string()
    })?;
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
            let arr = arrow_array_to_rust(column, Some(&export_array_f))?;
            run_parallel |= matches!(
                arr.data_type(),
                ArrowDataType::Utf8 | ArrowDataType::Dictionary(_, _, _)
            );
            let arr_res: Result<_, String> = Ok(arr);
            arr_res
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
        let df_res: Result<_, String> = Ok(DataFrame::new_no_checks(series_vec));
        df_res
    });
    let dfs = crate::utils::collect_hinted_result(rb_len, dfs_iter)?;
    Ok(accumulate_dataframes_vertical_unchecked(dfs))
}

pub fn arrow2_array_stream_to_rust(str_ptr: &str) -> std::result::Result<pl::Series, String> {
    dbg!(str_ptr);
    let x: usize = str_ptr.parse().expect("input is a pointer value");
    dbg!(x);
    //let stream = x as *mut ffi::ArrowArrayStream;
    //let boxed_stream = Box::new(unsafe { *stream });
    let y = x as *mut ffi::ArrowArrayStream;

    let boxed_stream = unsafe { Box::from_raw(y) };
    dbg!("before reader");

    let mut iter = unsafe { ffi::ArrowArrayStreamReader::try_new(boxed_stream) }
        .map_err(|err| err.to_string())?;
    dbg!("after reader");

    let mut s = if let Some(array_res) = unsafe { iter.next() } {
        let array = array_res.map_err(|err| err.to_string())?;
        dbg!(&array);
        let series_res: pl::PolarsResult<pl::Series> =
            std::convert::TryFrom::try_from(("df", array));
        dbg!(&series_res);
        let series = series_res.map_err(|err| err.to_string())?;
        series
    } else {
        Err("no array to import!".to_string())?;
        unreachable!();
    };
    while let Some(array_res) = unsafe { iter.next() } {
        let array = array_res.map_err(|err| err.to_string())?;
        dbg!(&array);

        let series_res: pl::PolarsResult<pl::Series> =
            std::convert::TryFrom::try_from(("df", array));

        dbg!(&series_res);

        let series = series_res.map_err(|err| err.to_string())?;

        s.append(&series).map_err(|err| err.to_string())?;
    }

    std::mem::forget(iter);
    Ok(s)
}

pub fn arrow3_array_stream_to_rust(export_f: Robj) -> std::result::Result<(), String> {
    let mut stream = Box::new(ffi::ArrowArrayStream::empty());
    //let mut schema = Box::new(ffi::ArrowSchema::empty());
    let ext_stream = unsafe { wrap_make_external_ptr(&mut *stream) };

    //export
    export_f
        .as_function()
        .unwrap()
        .call(pairlist!(ext_stream))
        .unwrap();

    let mut iter =
        unsafe { ffi::ArrowArrayStreamReader::try_new(stream) }.map_err(|err| err.to_string())?;
    dbg!("after reader");

    while let Some(array_res) = unsafe { iter.next() } {
        let array = array_res.map_err(|err| err.to_string())?;
        dbg!(&array);
    }

    todo!("not  more for now");
}
