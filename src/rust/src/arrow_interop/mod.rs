pub mod to_rust;

use extendr_api::prelude::*;
use std::result::Result;

#[derive(Debug)]
pub enum RArrowArrayClass {
    ArrowArray,
    NanoArrowArray,
}

impl<'a> FromRobj<'a> for RArrowArrayClass {
    fn from_robj(robj: &Robj) -> std::result::Result<Self, &'static str> {
        if robj.inherits("nanoarrow_array") {
            Ok(RArrowArrayClass::NanoArrowArray)
        } else if robj.inherits("Array") {
            Ok(RArrowArrayClass::ArrowArray)
        } else {
            Err("Robj does not inherit from Array or nanoarrow_array")
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
    fn get_export_array_func(&self) -> Result<Robj, Error>;
}

impl RPackage for ArrowRPackage {
    fn get_export_array_func(&self) -> Result<Robj, Error> {
        R!(r#"
        function(array, exportable_array, exportable_schema) {
            array$export_to_c(exportable_array, exportable_schema)
        }"#)
    }
}

impl RPackage for NanoArrowRPackage {
    fn get_export_array_func(&self) -> Result<Robj, Error> {
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
