use crate::utils::r_result_list;
use crate::utils::wrappers::Wrap;
use extendr_api::prelude::*;
use polars::prelude as pl;
use polars_core::prelude::QuantileInterpolOptions;

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
            "UInt32" | "uinteger" => pl::DataType::UInt32,
            "UInt64" | "uinteger64" => pl::DataType::UInt64,
            "Utf8" | "character" => pl::DataType::Utf8,
            "Categorical" | "factor" => pl::DataType::Categorical(None),
            _ => panic!("data type not recgnized"),
        };
        DataType(pl_datatype)
    }

    pub fn get_all_type_names() -> Vec<String> {
        vec![
            "Boolean".into(),
            "Float32".into(),
            "Float64".into(),
            "Int32".into(),
            "Int64".into(),
            "UInt32".into(),
            "UInt64".into(),
            "Utf8".into(),
            "Categorical".into(),
        ]
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

    pub fn from_rlist(list: List) -> List {
        let mut dtv = DataTypeVector(Vec::with_capacity(list.len()));

        let result: std::result::Result<(), String> = list
            .iter()
            .map(|(name, robj)| -> std::result::Result<(), String> {
                if !robj.inherits("DataType") || robj.rtype() != extendr_api::Rtype::ExternalPtr {
                    return Err("Internal error: Object is not a DataType".into());
                }
                //safety checks class and type before conversion
                let dt: DataType = unsafe { &mut *robj.external_ptr_addr::<DataType>() }.clone();
                let name = extendr_api::Nullable::NotNull(name.to_string());
                dtv.push(name, &dt);
                Ok(())
            })
            .collect();

        r_result_list(result.map(|_| dtv))
    }
}

impl DataTypeVector {
    pub fn dtv_to_vec(&self) -> Vec<pl::DataType> {
        let v: Vec<_> = self.0.iter().map(|(_, dt)| dt.clone()).collect();
        v
    }
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

pub fn new_quantile_interpolation_option(
    s: &str,
) -> std::result::Result<QuantileInterpolOptions, String> {
    use pl::QuantileInterpolOptions::*;
    match s {
        "nearest" => Ok(Nearest),
        "higher" => Ok(Higher),
        "lower" => Ok(Lower),
        "midpoint" => Ok(Midpoint),
        "linear" => Ok(Linear),
        _ => Err(format!("interpolation choice: [{}] is not any of 'nearest', 'higher', 'lower', 'midpoint', 'linear'",s))
    }
}

pub fn new_closed_window(s: &str) -> std::result::Result<pl::ClosedWindow, String> {
    use pl::ClosedWindow as CW;
    match s {
        "both" => Ok(CW::Both),
        "left" => Ok(CW::Left),
        "none" => Ok(CW::None),
        "right" => Ok(CW::Right),
        _ => Err(format!(
            "ClosedWindow choice: [{}] is not any of 'both', 'left', 'none' or 'right'",
            s
        )),
    }
}

extendr_module! {
    mod rdatatype;
    impl DataType;
    impl DataTypeVector;
}
