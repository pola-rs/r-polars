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

// pub fn field_to_rust(arrow_array: Robj) -> Result<String, String> {
//     // prepare a pointer to receive the Array struct

//     let array = Box::new(ffi::ArrowArray::empty());
//     let schema = Box::new(ffi::ArrowSchema::empty());
//     //let r_a_ptr = extendr_api::ExternalPtr::new(*array);
//     //let r_s_ptr = extendr_api::ExternalPtr::new(*schema);
//     let array_ptr = &*array as *const ffi::ArrowArray;
//     let schema_ptr = &*schema as *const ffi::ArrowSchema;
//     dbg!((array_ptr as usize).to_string());
//     let ext_a = call!("xptr::new_xptr", (array_ptr as usize).to_string())?;
//     let ext_s = call!("xptr::new_xptr", (schema_ptr as usize).to_string())?;
//     dbg!(&ext_a, &ext_s);
//     call!("arrow:::ExportArray", arrow_array, ext_a, ext_s)?;

//     // make the conversion through PyArrow's private API
//     // this changes the pointer's memory and is thus unsafe. In particular, `_export_to_c` can go out of bounds

//     let array = unsafe {
//         let field = ffi::import_field_from_c(schema.as_ref()).map_err(|err| err.to_string())?;
//         let array =
//             ffi::import_array_from_c(*array, field.data_type).map_err(|err| err.to_string())?;
//         array
//     };

//     dbg!(array);

//     Ok("done".to_string())
// }

pub fn field_to_rust(f_ptr: Robj) -> Result<String, String> {
    // prepare a pointer to receive the Array struct

    //let array = Box::new(ffi::ArrowArray::empty());
    //let schema = Box::new(ffi::ArrowSchema::empty());
    let f_ptr = robj_to!(usize, f_ptr)?;
    let x = f_ptr as *const ffi::ArrowArray;

    use polars_core::utils::arrow::datatypes as dt;
    let y = unsafe {
        ffi::import_array_from_c(*x, dt::DataType::Float64).map_err(|err| err.to_string())?
    };
    dbg!("to here");
    let w = y.data_type();

    dbg!(w);

    Ok("done".to_string())
}

// // PyList<Field> which you get by calling `list(schema)`
// pub fn pyarrow_schema_to_rust(obj: &PyList) -> PyResult<Schema> {
//     obj.into_iter().map(field_to_rust).collect()
// }

// pub fn array_to_rust(obj: &PyAny) -> PyResult<ArrayRef> {
//     // prepare a pointer to receive the Array struct
//     let array = Box::new(ffi::ArrowArray::empty());
//     let schema = Box::new(ffi::ArrowSchema::empty());

//     let array_ptr = &*array as *const ffi::ArrowArray;
//     let schema_ptr = &*schema as *const ffi::ArrowSchema;

//     // make the conversion through PyArrow's private API
//     // this changes the pointer's memory and is thus unsafe. In particular, `_export_to_c` can go out of bounds
//     obj.call_method1(
//         "_export_to_c",
//         (array_ptr as Py_uintptr_t, schema_ptr as Py_uintptr_t),
//     )?;

//     unsafe {
//         let field = ffi::import_field_from_c(schema.as_ref()).map_err(PyPolarsErr::from)?;
//         let array = ffi::import_array_from_c(*array, field.data_type).map_err(PyPolarsErr::from)?;
//         Ok(array)
//     }
// }

// pub fn to_rust_df(rb: &[&PyAny]) -> PyResult<DataFrame> {
//     let schema = rb
//         .get(0)
//         .ok_or_else(|| PyPolarsErr::Other("empty table".into()))?
//         .getattr("schema")?;
//     let names = schema.getattr("names")?.extract::<Vec<String>>()?;

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
