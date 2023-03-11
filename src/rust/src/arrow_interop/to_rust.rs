use polars_core::prelude::*;
use polars_core::utils::arrow::ffi;

use extendr_api::prelude::*;
use polars::prelude as pl;
use std::result::Result;

unsafe fn wrap_make_external_ptr<T>(t: &mut T) -> Robj {
    //use extendr_api::{Integers, Rinternals};
    unsafe { <Integers>::make_external_ptr(t, r!(extendr_api::NULL)) }
}

pub fn arrow_array_to_rust(arrow_array: Robj, f: &Function) -> Result<ArrayRef, String> {
    let mut array = Box::new(ffi::ArrowArray::empty());
    let mut schema = Box::new(ffi::ArrowSchema::empty());
    let (ext_a, ext_s) = unsafe {
        (
            wrap_make_external_ptr(&mut *array),
            wrap_make_external_ptr(&mut *schema),
        )
    };

    //call!("arrow:::ExportArray", arrow_array, ext_a, ext_s)?;
    f.call(pairlist!(arrow_array, ext_a, ext_s))?;
    let array = unsafe {
        let field = ffi::import_field_from_c(schema.as_ref()).map_err(|err| err.to_string())?;
        let array =
            ffi::import_array_from_c(*array, field.data_type).map_err(|err| err.to_string())?;
        array
    };
    //dbg!(&array);
    Ok(array)
}

pub fn rb_to_rust_df(r_rb_columns: List, names: &Vec<String>) -> Result<pl::DataFrame, String> {
    let n_col = r_rb_columns.len();
    let f = R!("arrow:::ExportArray")?
        .as_function()
        .expect("could not find Arrow");
    let col_iter = r_rb_columns
        .into_iter()
        .zip(names.iter())
        .map(|((_, r_array), str)| {
            let arr = arrow_array_to_rust(r_array, &f)?;
            let s = <polars::prelude::Series>::try_from((str.as_str(), arr))
                .map_err(|err| err.to_string());
            s
        });
    let s_vec_res = crate::utils::collect_hinted_result(n_col, col_iter);

    Ok(pl::DataFrame::new_no_checks(s_vec_res?))
}
