use extendr_api::prelude::*;
use polars_core::prelude::*;
use polars_core::utils::arrow::ffi;
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
