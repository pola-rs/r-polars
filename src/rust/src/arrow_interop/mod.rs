pub mod to_rust;

use polars_core::utils::arrow;

use extendr_api::prelude::*;

#[derive(Debug)]
pub enum RArrowArrayClass {
    ArrowArray,
    NanoArrowArray,
}

impl TryFrom<&Robj> for RArrowArrayClass {
    type Error = extendr_api::Error;

    fn try_from(robj: &Robj) -> Result<Self> {
        if robj.inherits("nanoarrow_array") {
            Ok(RArrowArrayClass::NanoArrowArray)
        } else if robj.inherits("Array") {
            Ok(RArrowArrayClass::ArrowArray)
        } else {
            Err(Error::Other(
                "Robj does not inherit from Array or nanoarrow_array".into(),
            ))
        }
    }
}

#[derive(Debug)]
pub struct ArrowRPackage;
#[derive(Debug)]
pub struct NanoArrowRPackage;

impl RArrowArrayClass {
    pub fn get_package(&self) -> Box<dyn RPackage> {
        match self {
            RArrowArrayClass::ArrowArray => Box::new(ArrowRPackage),
            RArrowArrayClass::NanoArrowArray => Box::new(NanoArrowRPackage),
        }
    }
}

pub trait RPackage {
    fn get_export_array_func(&self) -> Result<Robj>;
}

impl RPackage for ArrowRPackage {
    fn get_export_array_func(&self) -> Result<Robj> {
        R!(r#"
        function(array, exportable_array, exportable_schema) {
            array$export_to_c(exportable_array, exportable_schema)
        }"#)
    }
}

impl RPackage for NanoArrowRPackage {
    fn get_export_array_func(&self) -> Result<Robj> {
        R!(r#"
        function(array, exportable_array, exportable_schema) {
            nanoarrow::nanoarrow_pointer_export(
                nanoarrow::infer_nanoarrow_schema(array),
                exportable_schema
            )
            nanoarrow::nanoarrow_pointer_export(array, exportable_array)
        }
        "#)
    }
}

#[extendr]
pub fn polars_allocate_array_stream() -> Robj {
    let aas = Box::new(arrow::ffi::ArrowArrayStream::empty());
    let x = Box::into_raw(aas);
    format!("{:?}", x as usize).into()
}

extendr_module! {
    mod arrow_interop;
    fn polars_allocate_array_stream;
}
