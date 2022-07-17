
use crate::utils::wrappers::Wrap;
use extendr_api::prelude::*;
use polars::datatypes::DataType;

//expose polars DateType in R
#[extendr]
#[derive(Debug, Clone)]
pub struct Rdatatype(DataType);

#[extendr]
impl Rdatatype {
    pub fn new(s: &str) -> Rdatatype {
        //2nd naming is R suggested equivalent
        let datatype = match s {
            "Boolean" | "logical" => DataType::Boolean,
            "Float32" | "double" => DataType::Float32,
            "Float64" | "float64" => DataType::Float64,
            "Int32" | "integer" => DataType::Int32,
            "Int64" | "integer64" => DataType::Int64,
            "Utf8" | "character" => DataType::Utf8,
            _ => panic!("data type not recgnized"),
        };
        Rdatatype(datatype)
    }

    pub fn print(&self) {
        rprintln!("{:?}", self.0);
    }
}

impl From<Rdatatype> for DataType {
    fn from(x: Rdatatype) -> Self {
        x.0
    }
}

//struct for building a vector of optional named datatype,
//if all named will become a schema and passed to polars_io.csv.csvread.with_dtypes
//if any names are missing will become slice of dtypes and passed to polars_io.csv.csvread.with_dtypes_slice
//zero length vector will neither trigger with_dtypes() or with_dtypes_slice() method calls
#[derive(Debug, Clone)]
#[extendr]
pub struct Rdatatype_vector(pub Vec<(Option<String>, DataType)>);

#[extendr]
impl Rdatatype_vector {
    pub fn new() -> Self {
        Rdatatype_vector(Vec::new())
    }

    pub fn push(&mut self, colname: Nullable<String>, datatype: &Rdatatype) {
        self.0.push((Wrap(colname).into(), datatype.clone().into()));
    }

    pub fn print(&self) {
        rprintln!("{:?}", self.0);
    }
}

extendr_module! {
    mod rdatatype;
    impl Rdatatype;
    impl Rdatatype_vector;
}
