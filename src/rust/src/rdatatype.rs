use crate::utils::wrappers::Wrap;
use extendr_api::prelude::*;
use polars::prelude as pl;

//expose polars DateType in R
#[extendr]
#[derive(Debug, Clone, PartialEq)]
pub struct DataType(pub pl::DataType);

#[extendr]
impl DataType {
    pub fn new(s: &str) -> DataType {
        //2nd naming is R suggested equivalent
        let pl_datatype = match s {
            "Boolean" | "logical" => pl::DataType::Boolean,
            "Float32" | "double" => pl::DataType::Float32,
            "Float64" | "float64" => pl::DataType::Float64,
            "Int32" | "integer" => pl::DataType::Int32,
            "Int64" | "integer64" => pl::DataType::Int64,
            "Utf8" | "character" => pl::DataType::Utf8,
            "Categorical" | "factor" => pl::DataType::Categorical(None),
            _ => panic!("data type not recgnized"),
        };
        DataType(pl_datatype)
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self.0);
    }

    pub fn eq(&self, other: &DataType) -> bool {
        self.0.eq(&other.0)
    }

    pub fn ne(&self, other: &DataType) -> bool {
        self.0.ne(&other.0)
    }
}

impl From<DataType> for pl::DataType {
    fn from(x: DataType) -> Self {
        x.0
    }
}

//struct for building a vector of optional named datatype,
//if all named will become a schema and passed to polars_io.csv.csvread.with_dtypes
//if any names are missing will become slice of dtypes and passed to polars_io.csv.csvread.with_dtypes_slice
//zero length vector will neither trigger with_dtypes() or with_dtypes_slice() method calls
#[derive(Debug, Clone)]
#[extendr]
pub struct DataTypeVector(pub Vec<(Option<String>, pl::DataType)>);

#[extendr]
impl DataTypeVector {
    pub fn new() -> Self {
        DataTypeVector(Vec::new())
    }

    pub fn push(&mut self, colname: Nullable<String>, datatype: &DataType) {
        self.0.push((Wrap(colname).into(), datatype.clone().into()));
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self.0);
    }
}

pub fn dtv_to_vec(dtv: &DataTypeVector) -> Vec<pl::DataType> {
    let v: Vec<_> = dtv.0.iter().map(|(_, dt)| dt.clone()).collect();
    v
}

pub fn new_join_type(s: &str) -> pl::JoinType {
    match s {
        "cross" => pl::JoinType::Cross,
        "inner" => pl::JoinType::Inner,
        "left" => pl::JoinType::Left,
        "outer" => pl::JoinType::Outer,
        "semi" => pl::JoinType::Semi,
        "anti" => pl::JoinType::Anti,
        _ => panic!("minipolars internal error: jointype not recognized"),
    }
}

extendr_module! {
    mod rdatatype;
    impl DataType;
    impl DataTypeVector;
}
