use polars::export::arrow::ffi::ArrowArray;
use polars_core::export::rayon::prelude::*;
use polars_core::prelude::*;
use polars_core::utils::accumulate_dataframes_vertical_unchecked;
use polars_core::utils::arrow::ffi;
use polars_core::POOL;
//use pyo3::ffi::Py_uintptr_t;
//use pyo3::prelude::*;
//use pyo3::types::PyList;

use crate::rdatatype::RField;
use crate::robj_to;
use extendr_api::prelude::*;
use polars::prelude as pl;
use std::result::Result;

// pub fn field_to_rust(robj: Robj) -> Result<RField, String> {
//     //schema to 'read' from
//     let arrow_schema_robj = robj_to!(usize, robj)?;
//     dbg!(&arrow_schema_robj);
//     // //schema to 'write' to
//     // let schema = Box::new(ffi::ArrowSchema::empty());
//     // let schema_ptr = &*schema as *const ffi::ArrowSchema;
//     // let rschema_ptr = ExternalPtr::new(schema_ptr);
//     let field_ptr = arrow_schema_robj as *const ffi::ArrowSchema;
//     dbg!(&field_ptr);
//     let x = unsafe {
//         ffi::import_array_from_c(
//             &*field_ptr,
//             polars_core::utils::arrow::datatypes::DataType::Int32,
//         )
//     };
//     dbg!(&x);
//     // make the conversion through R Arrow's private API
//     //let out = call!("arrow:::ExportSchema", arrow_schema_robj, rschema_ptr)?;

//     //todo!("not done");

//     x.map(|ok| RField(Field::from(&ok)))
//         .map_err(|err| err.to_string())
// }

// struct MyArray {
//     array: Box<ArrowArray>,
//     schema: Box<ArrowArray>,
// }

// impl MyArray {
//     pub fn new() -> Self {
//         let arrow_schema_robj = robj_to!(usize, robj)?;

//         // prepare a pointer to receive the Array struct
//         let array = Box::new(ffi::ArrowArray::empty());
//         let schema = Box::new(ffi::ArrowSchema::empty());

//         let array_ptr = &*array as *const ffi::ArrowArray;
//         let schema_ptr = &*schema as *const ffi::ArrowSchema;

//         // make the conversion through PyArrow's private API
//         // this changes the pointer's memory and is thus unsafe. In particular, `_export_to_c` can go out of bounds

//         unsafe {
//             let field = ffi::import_field_from_c(schema.as_ref()).map_err(|err| err.to_string())?;
//             let array =
//                 ffi::import_array_from_c(*array, field.data_type).map_err(|err| err.to_string())?;
//             Ok(array)
//         }
//     }
// }
unsafe fn wrap_make_external_ptr<T>(t: &mut T) -> Robj {
    use extendr_api::{Integers, Rinternals};
    unsafe { <Integers>::make_external_ptr(t, r!(extendr_api::NULL)) }
}

pub fn arrow_array_to_rust(arrow_array: Robj) -> Result<ArrayRef, String> {
    let mut array = Box::new(ffi::ArrowArray::empty());
    let mut schema = Box::new(ffi::ArrowSchema::empty());

    let (ext_a, ext_s) = unsafe {
        (
            wrap_make_external_ptr(&mut *array),
            wrap_make_external_ptr(&mut *schema),
        )
    };
    //dbg!(&ext_s);
    //call!(r" {\(x) .Internal(inspect(x))}", ext_a.clone())?;
    //call!(r" {\(x) .Internal(inspect(x))}", ext_s.clone())?;

    //dbg!(&ext_a, &ext_s);
    call!("arrow:::ExportArray", arrow_array, ext_a, ext_s)?;

    // make the conversion through R-Arrow's private API
    // this changes the pointer's memory and is thus unsafe. In particular, `_export_to_c` can go out of bounds

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
    let columns: Result<Vec<_>, String> = r_rb_columns
        .into_iter()
        .map(|(_, r_array)| arrow_array_to_rust(r_array))
        .collect();

    let s_vec_res = columns?
        .into_iter()
        .enumerate()
        .map(|(i, arr)| {
            let str = names[i].as_str();
            let s = <polars::prelude::Series>::try_from((str, arr)).map_err(|err| err.to_string());
            Ok(s?)
        })
        .collect::<Result<Vec<_>, String>>();
    Ok(pl::DataFrame::new_no_checks(s_vec_res?))
}

// pub fn to_rust_df(rb: RObj, names: Vec<String>) -> Result<pl::DataFrame, String> {
//     let dfs = rb
//         .iter()
//         .map(|rb| {
//             let mut run_parallel = false;

//             let columns = (0..names.len())
//                 .map(|i| {
//                     let array = rb.call_method1("column", (i,))?;
//                     let arr = array_to_rust(array)?;
//                     run_parallel |= matches!(
//                         arr.data_type(),
//                         ArrowDataType::Utf8 | ArrowDataType::Dictionary(_, _, _)
//                     );
//                     Ok(arr)
//                 })
//                 .collect::<PyResult<Vec<_>>>()?;

//             // we parallelize this part because we can have dtypes that are not zero copy
//             // for instance utf8 -> large-utf8
//             // dict encoded to categorical
//             let columns = if run_parallel {
//                 POOL.install(|| {
//                     columns
//                         .into_par_iter()
//                         .enumerate()
//                         .map(|(i, arr)| {
//                             let s = Series::try_from((names[i].as_str(), arr))
//                                 .map_err(PyPolarsErr::from)?;
//                             Ok(s)
//                         })
//                         .collect::<PyResult<Vec<_>>>()
//                 })
//             } else {
//                 columns
//                     .into_iter()
//                     .enumerate()
//                     .map(|(i, arr)| {
//                         let s = Series::try_from((names[i].as_str(), arr))
//                             .map_err(PyPolarsErr::from)?;
//                         Ok(s)
//                     })
//                     .collect::<PyResult<Vec<_>>>()
//             }?;

//             // no need to check as a record batch has the same guarantees
//             Ok(DataFrame::new_no_checks(columns))
//         })
//         .collect::<PyResult<Vec<_>>>()?;

//     Ok(accumulate_dataframes_vertical_unchecked(dfs))
// }
