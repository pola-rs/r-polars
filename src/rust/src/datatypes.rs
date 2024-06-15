use polars::prelude::*;
use polars_core::utils::arrow::array::Utf8ViewArray;

pub(crate) enum RPlDataType {
    Int8,
    Int16,
    Int32,
    Int64,
    UInt8,
    UInt16,
    UInt32,
    UInt64,
    Float32,
    Float64,
    Bool,
    String,
    List,
    Date,
    Datetime(TimeUnit, Option<TimeZone>),
    Duration(TimeUnit),
    Time,
    Categorical,
    Struct,
    Binary,
    Decimal(Option<usize>, usize),
    Array(usize),
    Enum(Utf8ViewArray),
}

impl From<&DataType> for RPlDataType {
    fn from(dt: &DataType) -> Self {
        use RPlDataType::*;
        match dt {
            DataType::Int8 => Int8,
            DataType::Int16 => Int16,
            DataType::Int32 => Int32,
            DataType::Int64 => Int64,
            DataType::UInt8 => UInt8,
            DataType::UInt16 => UInt16,
            DataType::UInt32 => UInt32,
            DataType::UInt64 => UInt64,
            DataType::Float32 => Float32,
            DataType::Float64 => Float64,
            DataType::Decimal(p, s) => Decimal(*p, s.expect("unexpected null decimal scale")),
            DataType::Boolean => Bool,
            DataType::String => String,
            DataType::Binary => Binary,
            DataType::Array(_, width) => Array(*width),
            DataType::List(_) => List,
            DataType::Date => Date,
            DataType::Datetime(tu, tz) => Datetime(*tu, tz.clone()),
            DataType::Duration(tu) => Duration(*tu),
            DataType::Time => Time,
            DataType::Categorical(_, _) => Categorical,
            DataType::Enum(rev_map, _) => Enum(rev_map.as_ref().unwrap().get_categories().clone()),
            DataType::Struct(_) => Struct,
            DataType::Null | DataType::Unknown(_) | DataType::BinaryOffset => {
                panic!("null or unknown not expected here")
            }
        }
    }
}

impl From<DataType> for RPlDataType {
    fn from(dt: DataType) -> Self {
        (&dt).into()
    }
}

impl From<RPlDataType> for DataType {
    fn from(rdt: RPlDataType) -> DataType {
        use DataType::*;
        match rdt {
            RPlDataType::Int8 => Int8,
            RPlDataType::Int16 => Int16,
            RPlDataType::Int32 => Int32,
            RPlDataType::Int64 => Int64,
            RPlDataType::UInt8 => UInt8,
            RPlDataType::UInt16 => UInt16,
            RPlDataType::UInt32 => UInt32,
            RPlDataType::UInt64 => UInt64,
            RPlDataType::Float32 => Float32,
            RPlDataType::Float64 => Float64,
            RPlDataType::Bool => Boolean,
            RPlDataType::String => String,
            RPlDataType::Binary => Binary,
            RPlDataType::List => List(DataType::Null.into()),
            RPlDataType::Date => Date,
            RPlDataType::Datetime(tu, tz) => Datetime(tu, tz),
            RPlDataType::Duration(tu) => Duration(tu),
            RPlDataType::Time => Time,
            RPlDataType::Categorical => Categorical(None, Default::default()),
            RPlDataType::Enum(categories) => create_enum_data_type(categories),
            RPlDataType::Struct => Struct(vec![]),
            RPlDataType::Decimal(p, s) => Decimal(p, Some(s)),
            RPlDataType::Array(width) => Array(DataType::Null.into(), width),
        }
    }
}
