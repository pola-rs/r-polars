use crate::robj_to;

use crate::utils::wrappers::Wrap;
use extendr_api::prelude::*;
use polars::prelude::{self as pl};
use polars_core::prelude::QuantileMethod;
//expose polars DateType in R
use crate::rpolarserr::{polars_to_rpolars_err, rerr, RPolarsErr, RResult, WithRctx};
use crate::utils::collect_hinted_result;
use crate::utils::robj_to_rchoice;
use pl::UniqueKeepStrategy;
use polars::prelude::AsofStrategy;
use std::num::NonZeroUsize;

#[derive(Debug, Clone, PartialEq)]
pub struct RPolarsRField(pub pl::Field);

#[extendr]
impl RPolarsRField {
    fn new(name: String, datatype: &RPolarsDataType) -> RPolarsRField {
        let name = name.into();
        RPolarsRField(pl::Field {
            name,
            dtype: datatype.0.clone(),
        })
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self.0);
    }

    #[allow(clippy::should_implement_trait)]
    pub fn clone(&self) -> Self {
        RPolarsRField(self.0.clone())
    }

    pub fn get_name(&self) -> String {
        self.0.name.to_string()
    }
    pub fn get_datatype(&self) -> RPolarsDataType {
        RPolarsDataType(self.0.dtype.clone())
    }

    pub fn set_name_mut(&mut self, name: &str) {
        self.0.name = name.into()
    }

    pub fn set_datatype_mut(&mut self, datatype: &RPolarsDataType) {
        self.0.dtype = datatype.0.clone()
    }
}

#[derive(Debug, Clone, PartialEq)]
pub struct RPolarsDataType(pub pl::DataType);

#[extendr]
impl RPolarsDataType {
    pub fn new(s: &str) -> RPolarsDataType {
        //, inner: Nullable<&DataType>
        //let inner = Box::new(null_to_opt(inner).map_or(pl::DataType::Null, |x| x.0.clone()));

        let pl_datatype = match s {
            "Boolean" | "logical" => pl::DataType::Boolean,
            "UInt8" | "uinteger8" => pl::DataType::UInt8,
            "UInt16" | "uinteger16" => pl::DataType::UInt16,
            "UInt32" | "uinteger32" => pl::DataType::UInt32,
            "UInt64" | "uinteger64" => pl::DataType::UInt64,
            "Int8" | "integer8" => pl::DataType::Int8,
            "Int16" | "integer16" => pl::DataType::Int16,
            "Int32" | "integer32" | "integer" => pl::DataType::Int32,
            "Int64" | "integer64" => pl::DataType::Int64,
            "Float32" | "float32" | "double" => pl::DataType::Float32,
            "Float64" | "float64" => pl::DataType::Float64,

            "Utf8" | "String" | "character" => pl::DataType::String,
            "Binary" | "binary" => pl::DataType::Binary,
            "Date" | "date" => pl::DataType::Date,
            "Time" | "time" => pl::DataType::Time,
            "Null" | "null" => pl::DataType::Null,
            "Categorical" | "factor" => pl::DataType::Categorical(None, Default::default()),
            "Enum" => pl::DataType::Enum(None, Default::default()),
            "Unknown" | "unknown" => pl::DataType::Unknown(polars::datatypes::UnknownKind::Any),

            _ => panic!("data type not recgnized "),
        };
        RPolarsDataType(pl_datatype)
    }

    pub fn new_categorical(ordering: Robj) -> RResult<RPolarsDataType> {
        let ordering = robj_to!(CategoricalOrdering, ordering)?;
        Ok(RPolarsDataType(pl::DataType::Categorical(None, ordering)))
    }

    pub fn new_enum(categories: Robj) -> RResult<RPolarsDataType> {
        use crate::conversion_r_to_s::robjname2series;
        let s = robjname2series(categories, "").unwrap();
        let ca = s.str()?;
        let categories = ca.downcast_iter().next().unwrap().clone();
        Ok(RPolarsDataType(pl::datatypes::create_enum_dtype(
            categories,
        )))
    }

    pub fn new_datetime(tu: Robj, tz: Robj) -> RResult<RPolarsDataType> {
        let tz = robj_to!(Option, String, tz)?.map(|x| x.into());
        robj_to!(timeunit, tu).map(|dt| RPolarsDataType(pl::DataType::Datetime(dt, tz)))
    }

    pub fn new_duration(tu: Robj) -> RResult<RPolarsDataType> {
        Ok(RPolarsDataType(pl::DataType::Duration(robj_to!(
            timeunit, tu
        )?)))
    }

    pub fn new_list(inner: &RPolarsDataType) -> RPolarsDataType {
        RPolarsDataType(pl::DataType::List(Box::new(inner.0.clone())))
    }

    pub fn new_array(inner: &RPolarsDataType, width: Robj) -> RResult<RPolarsDataType> {
        Ok(RPolarsDataType(pl::DataType::Array(
            Box::new(inner.0.clone()),
            robj_to!(usize, width)?,
        )))
    }

    pub fn new_object() -> RPolarsDataType {
        todo!("object not implemented")
    }

    pub fn new_struct(l: Robj) -> RResult<RPolarsDataType> {
        let len = l.len();
        //iterate over R list and collect Fields and place in a Struct-datatype
        l.as_list()
            .ok_or_else(|| {
                RPolarsErr::new()
                    .bad_arg("l".into())
                    .plain("is not a list".into())
            })
            .map(|l| {
                l.into_iter().enumerate().map(|(i, (name, robj))| {
                    let res: extendr_api::Result<ExternalPtr<RPolarsRField>> = robj.try_into();
                    res.map_err(|extendr_err| {
                        RPolarsErr::from(extendr_err).plain(format!(
                            "list element [[{}]] named {} is not a Field.",
                            i + 1,
                            name,
                        ))
                    })
                    .map(|ok| ok.0.clone())
                })
            })
            .and_then(|iter| collect_hinted_result(len, iter))
            .map(|v_field| RPolarsDataType(pl::DataType::Struct(v_field)))
    }

    pub fn get_all_simple_type_names() -> Vec<String> {
        vec![
            "Boolean".into(),
            "UInt8".into(),
            "UInt16".into(),
            "UInt32".into(),
            "UInt64".into(),
            "Int8".into(),
            "Int16".into(),
            "Int32".into(),
            "Int64".into(),
            "Float32".into(),
            "Float64".into(),
            "String".into(),
            "Binary".into(),
            "Date".into(),
            "Time".into(),
            "Null".into(),
            "Unknown".into(),
        ]
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self.0);
    }

    #[allow(clippy::should_implement_trait)]
    pub fn eq(&self, other: &RPolarsDataType) -> bool {
        self.0.eq(&other.0)
    }

    pub fn ne(&self, other: &RPolarsDataType) -> bool {
        self.0.ne(&other.0)
    }

    fn same_outer_datatype(&self, other: &RPolarsDataType) -> bool {
        std::mem::discriminant(&self.0) == std::mem::discriminant(&other.0)
    }

    pub fn get_insides(&self) -> List {
        match self.0.clone() {
            pl::DataType::Datetime(tu, tz) => list!(
                tu = tu.to_string().into_robj(),
                tz = if let Some(tz) = tz {
                    tz.into_robj()
                } else {
                    extendr_api::NULL.into_robj()
                },
            ),
            pl::DataType::List(inner) => {
                list!(RPolarsDataType(*inner).into_robj())
            }
            _ => list!(),
        }
    }

    pub fn is_temporal(&self) -> bool {
        self.0.is_temporal()
    }

    pub fn is_enum(&self) -> bool {
        self.0.is_enum()
    }

    pub fn is_categorical(&self) -> bool {
        self.0.is_categorical()
    }

    pub fn is_string(&self) -> bool {
        self.0.is_string()
    }

    pub fn is_logical(&self) -> bool {
        self.0.is_logical()
    }

    pub fn is_float(&self) -> bool {
        self.0.is_float()
    }

    pub fn is_numeric(&self) -> bool {
        self.0.is_numeric()
    }

    pub fn is_integer(&self) -> bool {
        self.0.is_integer()
    }

    pub fn is_signed_integer(&self) -> bool {
        self.0.is_signed_integer()
    }

    pub fn is_unsigned_integer(&self) -> bool {
        self.0.is_unsigned_integer()
    }

    pub fn is_null(&self) -> bool {
        self.0.is_null()
    }

    pub fn is_binary(&self) -> bool {
        self.0.is_binary()
    }

    pub fn is_primitive(&self) -> bool {
        self.0.is_primitive()
    }

    pub fn is_bool(&self) -> bool {
        self.0.is_bool()
    }

    pub fn is_array(&self) -> bool {
        self.0.is_array()
    }

    pub fn is_list(&self) -> bool {
        self.0.is_list()
    }

    pub fn is_nested(&self) -> bool {
        self.0.is_nested()
    }

    pub fn is_struct(&self) -> bool {
        self.0.is_struct()
    }

    pub fn is_ord(&self) -> bool {
        self.0.is_ord()
    }

    pub fn is_known(&self) -> bool {
        self.0.is_known()
    }

    pub fn contains_views(&self) -> bool {
        self.0.contains_views()
    }

    pub fn contains_categoricals(&self) -> bool {
        self.0.contains_categoricals()
    }
}

impl From<RPolarsDataType> for pl::DataType {
    fn from(x: RPolarsDataType) -> Self {
        x.0
    }
}

//struct for building a vector of optional named datatype,
//if all named will become a schema and passed to polars_io.csv.csvread.with_dtypes
//if any names are missing will become slice of dtypes and passed to polars_io.csv.csvread.with_dtypes_slice
//zero length vector will neither trigger with_dtypes() or with_dtypes_slice() method calls
#[derive(Debug, Clone, Default)]
pub struct RPolarsDataTypeVector(pub Vec<(Option<String>, pl::DataType)>);

#[extendr]
impl RPolarsDataTypeVector {
    pub fn new() -> Self {
        Self::default()
    }
    pub fn push(&mut self, colname: Nullable<String>, datatype: &RPolarsDataType) {
        self.0.push((Wrap(colname).into(), datatype.clone().into()));
    }

    pub fn print(&self) {
        rprintln!("{:#?}", self.0);
    }

    pub fn from_rlist(list: List) -> RResult<RPolarsDataTypeVector> {
        let mut dtv = RPolarsDataTypeVector(Vec::with_capacity(list.len()));
        list.iter().try_for_each(|(name, robj)| {
            dtv.push(
                extendr_api::Nullable::NotNull(name.into()),
                &crate::utils::robj_to_datatype(robj)?,
            );
            RResult::Ok(())
        })?;
        Ok(dtv)
    }
}

impl RPolarsDataTypeVector {
    pub fn dtv_to_vec(&self) -> Vec<pl::DataType> {
        let v: Vec<_> = self.0.iter().map(|(_, dt)| dt.clone()).collect();
        v
    }
}

pub fn robj_to_asof_strategy(robj: Robj) -> RResult<AsofStrategy> {
    match robj_to_rchoice(robj)?.as_str() {
        "forward" => Ok(AsofStrategy::Forward),
        "backward" => Ok(AsofStrategy::Backward),
        s => rerr().notachoice(format!(
            "asof strategy ('{s}') must be one of 'forward' or 'backward'"
        )),
    }
}

pub fn robj_to_nonzero_usize(robj: Robj) -> RResult<NonZeroUsize> {
    Ok(NonZeroUsize::new(robj_to!(usize, robj)?).unwrap())
}

pub fn robj_to_unique_keep_strategy(robj: Robj) -> RResult<UniqueKeepStrategy> {
    match robj_to_rchoice(robj)?.to_lowercase().as_str() {
        "any" => Ok(pl::UniqueKeepStrategy::Any),
        "first" => Ok(pl::UniqueKeepStrategy::First),
        "last" => Ok(pl::UniqueKeepStrategy::Last),
        "none" => Ok(pl::UniqueKeepStrategy::None),
        s => rerr().notachoice(format!(
            "keep strategy ('{s}') must be one of 'any', 'first', 'last', 'none'"
        )),
    }
}

pub fn robj_to_quantile_interpolation_option(robj: Robj) -> RResult<QuantileMethod> {
    use pl::QuantileMethod::*;
    match robj_to_rchoice(robj)?.as_str() {
        "nearest" => Ok(Nearest),
        "higher" => Ok(Higher),
        "lower" => Ok(Lower),
        "midpoint" => Ok(Midpoint),
        "linear" => Ok(Linear),
        s => rerr()
            .notachoice(format!("interpolation ('{s}') must be one of 'nearest', 'higher', 'lower', 'midpoint', 'linear'"))
     ,
    }
}

pub fn robj_to_interpolation_method(robj: Robj) -> RResult<pl::InterpolationMethod> {
    use pl::InterpolationMethod as IM;
    match robj_to_rchoice(robj)?.as_str() {
        "linear" => Ok(IM::Linear),
        "nearest" => Ok(IM::Nearest),
        s => rerr().notachoice(format!(
            "InterpolationMethod ('{s}') must be one of 'linear' or 'nearest'",
        )),
    }
}

pub fn robj_to_cloud_options(url: &str, robj: &Robj) -> RResult<Option<pl::cloud::CloudOptions>> {
    if robj.is_null() {
        return Ok(None);
    }
    if let (Some(names), Some(values)) = (robj.as_str_iter(), robj.names()) {
        Ok(Some(pl::cloud::CloudOptions::from_untyped_config(
            url,
            values.zip(names),
        )?))
    } else {
        Ok(None)
    }
}

pub fn robj_to_rank_method(robj: Robj) -> RResult<pl::RankMethod> {
    use pl::RankMethod as RM;
    match robj_to_rchoice(robj)?.to_lowercase().as_str() {
        "average" => Ok(RM::Average),
        "dense" => Ok(RM::Dense),
        "max" => Ok(RM::Max),
        "min" => Ok(RM::Min),
        "ordinal" => Ok(RM::Ordinal),
        "random" => Ok(RM::Random),
        s =>  rerr()
        .notachoice(format!(
            "RankMethod ('{s}') must be one of 'average', 'dense', 'min', 'max', 'ordinal', 'random'"
        )),
    }
}

pub fn robj_to_non_existent(robj: Robj) -> RResult<pl::NonExistent> {
    use pl::NonExistent as NE;
    match robj_to_rchoice(robj)?.to_lowercase().as_str() {
        "null" => Ok(NE::Null),
        "raise" => Ok(NE::Raise),
        s => rerr().notachoice(format!(
            "NonExistent ('{s}') must be one of 'null' or 'raise'"
        )),
    }
}

pub fn robj_to_window_mapping(robj: Robj) -> RResult<pl::WindowMapping> {
    use pl::WindowMapping as WM;
    match robj_to_rchoice(robj)?.to_lowercase().as_str() {
        "group_to_rows" => Ok(WM::GroupsToRows),
        "join" => Ok(WM::Join),
        "explode" => Ok(WM::Explode),
        s => rerr().notachoice(format!(
            "WindowMapping ('{s}') must be one of 'group_to_rows', 'join', 'explode'"
        )),
    }
}

pub fn literal_to_any_value(litval: pl::LiteralValue) -> RResult<pl::AnyValue<'static>> {
    use pl::AnyValue as av;
    use pl::LiteralValue as lv;
    match litval {
        lv::Boolean(x) => Ok(av::Boolean(x)),
        //lv::Datetime(datetime, unit) => Ok(av::Datetime(datetime, unit, &None)), #check how to convert
        //lv::Duration(duration, unit) => Ok(av::Duration(duration, unit)), #check how to convert
        lv::Float32(x) => Ok(av::Float32(x)),
        lv::Float64(x) => Ok(av::Float64(x)),
        lv::Int16(x) => Ok(av::Int16(x)),
        lv::Int32(x) => Ok(av::Int32(x)),
        lv::Int64(x) => Ok(av::Int64(x)),
        lv::Int8(x) => Ok(av::Int8(x)),
        lv::Null => Ok(av::Null),
        // lv::Range {
        //     low,
        //     high,
        //     data_type,
        // } => Ok(av::(low, high, data_type)),
        //lv::Series(s) => no counter part
        lv::UInt16(x) => Ok(av::UInt16(x)),
        lv::UInt32(x) => Ok(av::UInt32(x)),
        lv::UInt64(x) => Ok(av::UInt64(x)),
        lv::UInt8(x) => Ok(av::UInt8(x)),
        // lv::Utf8(x) => Ok(av::Utf8(x.as_str())),
        lv::String(x) => Ok(av::StringOwned(x)),
        x => rerr().notachoice(format!("cannot convert LiteralValue {:?} to AnyValue", x)),
    }
}

pub fn expr_to_any_value(e: pl::Expr) -> std::result::Result<pl::AnyValue<'static>, String> {
    use pl::*;
    let av = pl::DataFrame::default()
        .lazy()
        .select(&[e])
        .collect()
        .map_err(|err| err.to_string())?
        .iter()
        .next()
        .ok_or_else(|| String::from("expr made no series"))?
        .iter()
        .next()
        .ok_or_else(|| String::from("series had no first value"))?
        .into_static();
    Ok(av)
}

pub fn robj_to_width_strategy(robj: Robj) -> RResult<pl::ListToStructWidthStrategy> {
    use pl::ListToStructWidthStrategy as WS;
    match robj_to_rchoice(robj)?.to_lowercase().as_str() {
        "first_non_null" => Ok(WS::FirstNonNull),
        "max_width" => Ok(WS::MaxWidth),
        s => rerr().notachoice(format!(
            "n_field_strategy ('{s}') must be one of 'first_non_null' or 'max_width'"
        )),
    }
}

pub fn robj_to_timeunit(robj: Robj) -> RResult<pl::TimeUnit> {
    let s = robj_to!(str, robj)?;

    match s {
        "ns" => Ok(pl::TimeUnit::Nanoseconds),
        "us" | "μs" => Ok(pl::TimeUnit::Microseconds),
        "ms" => Ok(pl::TimeUnit::Milliseconds),

        _ => rerr().notachoice(format!(
            "str to polars TimeUnit ('{s}') must be one of 'ns', 'us/μs', 'ms'"
        )),
    }
}

pub fn time_unit_converson(tu: pl::TimeUnit) -> i64 {
    let tu_i64: i64 = match tu {
        pl::TimeUnit::Nanoseconds => 1_000_000_000,
        pl::TimeUnit::Microseconds => 1_000_000,
        pl::TimeUnit::Milliseconds => 1_000,
    };
    tu_i64
}

pub fn robj_to_categorical_ordering(robj: Robj) -> RResult<pl::CategoricalOrdering> {
    use pl::CategoricalOrdering as CO;
    let s = robj_to_rchoice(robj)?;
    match s.as_str() {
        "physical" => Ok(CO::Physical),
        "lexical" => Ok(CO::Lexical),
        _ => rerr().notachoice(format!(
            "CategoricalOrdering ('{s}') must be one of 'physical' or 'lexical'"
        )),
    }
}

pub fn new_parquet_compression(
    compression_method: Robj,
    compression_level: Robj,
) -> RResult<pl::ParquetCompression> {
    use pl::ParquetCompression::*;
    match robj_to!(String, compression_method)?.as_str() {
        "uncompressed" => Ok(Uncompressed),
        "snappy" => Ok(Snappy),
        "gzip" => robj_to!(Option, u8, compression_level)?
            .map(polars::prelude::GzipLevel::try_new)
            .transpose()
            .map(Gzip),
        "lzo" => Ok(Lzo),
        "brotli" => robj_to!(Option, u32, compression_level)?
            .map(polars::prelude::BrotliLevel::try_new)
            .transpose()
            .map(Brotli),
        "zstd" => robj_to!(Option, i32, compression_level)?
            .map(polars::prelude::ZstdLevel::try_new)
            .transpose()
            .map(Zstd),
        m => Err(polars::prelude::PolarsError::ComputeError(
            format!("Failed to set parquet compression method as [{m}]").into(),
        )),
    }
    .map_err(polars_to_rpolars_err)
    .misvalued("must be one of 'uncompressed', 'snappy', 'gzip', 'brotli', 'zstd'")
}

pub fn new_ipc_compression(robj: Robj) -> RResult<Option<pl::IpcCompression>> {
    match robj_to_rchoice(robj)?.as_str() {
        "uncompressed" => Ok(None),
        "lz4" => Ok(Some(pl::IpcCompression::LZ4)),
        "zstd" => Ok(Some(pl::IpcCompression::ZSTD)),
        s => rerr().notachoice(format!(
            "IpcCompression ('{s}') must be one of 'uncompressed', 'lz4', 'zstd'"
        )),
    }
}

pub fn new_rolling_cov_options(
    window_size: Robj,
    min_periods: Robj,
    ddof: Robj,
) -> RResult<pl::RollingCovOptions> {
    Ok(pl::RollingCovOptions {
        window_size: robj_to!(u32, window_size)?,
        min_periods: robj_to!(u32, min_periods)?,
        ddof: robj_to!(u8, ddof)?,
    })
}

pub fn robj_to_join_type(robj: Robj) -> RResult<pl::JoinType> {
    let s = robj_to_rchoice(robj)?;
    match s.as_str() {
        "cross" => Ok(pl::JoinType::Cross),
        "inner" => Ok(pl::JoinType::Inner),
        "left" => Ok(pl::JoinType::Left),
        "right" => Ok(pl::JoinType::Right),
        "full" => Ok(pl::JoinType::Full),
        "semi" => Ok(pl::JoinType::Semi),
        "anti" => Ok(pl::JoinType::Anti),
        s => rerr().notachoice(format!(
            "JoinType ('{s}') must be one of 'cross', 'inner', 'left', 'right', 'full', 'semi', 'anti'"
        )),
    }
}

pub fn robj_to_closed_window(robj: Robj) -> RResult<pl::ClosedWindow> {
    use pl::ClosedWindow as CW;
    match robj_to_rchoice(robj)?.as_str() {
        "both" => Ok(CW::Both),
        "left" => Ok(CW::Left),
        "none" => Ok(CW::None),
        "right" => Ok(CW::Right),
        s => rerr().notachoice(format!(
            "ClosedWindow ('{s}') must be one of 'both', 'left', 'none', 'right'"
        )),
    }
}

pub fn robj_to_closed_interval(robj: Robj) -> RResult<pl::ClosedInterval> {
    use pl::ClosedInterval as CI;
    match robj_to_rchoice(robj)?.as_str() {
        "both" => Ok(CI::Both),
        "left" => Ok(CI::Left),
        "none" => Ok(CI::None),
        "right" => Ok(CI::Right),
        s => rerr().notachoice(format!(
            "ClosedInterval ('{s}') must be one of 'both', 'left', 'none', 'right'"
        )),
    }
}

pub fn robj_to_set_operation(robj: Robj) -> RResult<pl::SetOperation> {
    use pl::SetOperation as SO;
    match robj_to_rchoice(robj)?.as_str() {
        "union" => Ok(SO::Union),
        "intersection" => Ok(SO::Intersection),
        "difference" => Ok(SO::Difference),
        "symmetric_difference" => Ok(SO::SymmetricDifference),
        s => rerr().notachoice(format!(
            "SetOperation ('{s}') must be one of 'union', 'intersection', 'difference', 'symmetric_difference'"
        )),
    }
}

pub fn robj_to_join_validation(robj: Robj) -> RResult<pl::JoinValidation> {
    use pl::JoinValidation as JV;
    match robj_to_rchoice(robj)?.as_str() {
        "m:m" => Ok(JV::ManyToMany),
        "1:m" => Ok(JV::OneToMany),
        "1:1" => Ok(JV::OneToOne),
        "m:1" => Ok(JV::ManyToOne),
        s => rerr().notachoice(format!(
            "JoinValidation ('{s}') must be one of 'm:m', '1:m', '1:1', 'm:1'"
        )),
    }
}

pub fn robj_to_label(robj: Robj) -> RResult<pl::Label> {
    use pl::Label;
    match robj_to_rchoice(robj)?.as_str() {
        "left" => Ok(Label::Left),
        "right" => Ok(Label::Right),
        "datapoint" => Ok(Label::DataPoint),
        s => rerr().notachoice(format!(
            "Label ('{s}') must be one of 'left', 'right', 'datapoint'"
        )),
    }
}

pub fn robj_to_start_by(robj: Robj) -> RResult<pl::StartBy> {
    use pl::StartBy as SB;
    match robj_to_rchoice(robj)?.as_str() {
        "window" => Ok(SB::WindowBound),
        "datapoint" => Ok(SB::DataPoint),
        "monday" => Ok(SB::Monday),
        "tuesday" => Ok(SB::Tuesday),
        "wednesday" => Ok(SB::Wednesday),
        "thursday" => Ok(SB::Thursday),
        "friday" => Ok(SB::Friday),
        "saturday" => Ok(SB::Saturday),
        "sunday" => Ok(SB::Sunday),
        s => rerr().notachoice(format!(
            "StartBy ('{s}') must be one of 'window', 'datapoint', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'"
        )),
    }
}

pub fn robj_to_parallel_strategy(robj: extendr_api::Robj) -> RResult<pl::ParallelStrategy> {
    match robj_to_rchoice(robj)?.as_str() {
        "auto" => Ok(pl::ParallelStrategy::Auto),
        "columns" => Ok(pl::ParallelStrategy::Columns),
        "row_groups" => Ok(pl::ParallelStrategy::RowGroups),
        "prefiltered" => Ok(pl::ParallelStrategy::Prefiltered),
        "none" => Ok(pl::ParallelStrategy::None),
        s => rerr().notachoice(format!(
            "ParallelStrategy ('{s}') must be one of 'auto', 'columns', 'row_groups', 'prefiltered', 'none'"
        )),
    }
}

pub fn robj_new_null_behavior(robj: Robj) -> RResult<polars::series::ops::NullBehavior> {
    use polars::series::ops::NullBehavior as NB;
    match robj_to_rchoice(robj)?.to_lowercase().as_str() {
        "ignore" => Ok(NB::Ignore),
        "drop" => Ok(NB::Drop),
        s => rerr().notachoice(format!(
            "NullBehavior ('{s}') must be one of 'drop' or 'ignore'"
        )),
    }
}

pub fn robj_to_statistics_options(robj: Robj) -> RResult<pl::StatisticsOptions> {
    use pl::StatisticsOptions as SO;
    let hm = robj
        .as_list()
        .unwrap()
        .into_hashmap()
        .into_iter()
        .map(|xi| (xi.0, xi.1.as_bool().unwrap()))
        .collect::<std::collections::HashMap<&str, bool>>();
    let mut out = SO::default();
    out.min_value = *hm.get(&"min").unwrap();
    out.max_value = *hm.get(&"max").unwrap();
    out.distinct_count = *hm.get(&"distinct_count").unwrap();
    out.null_count = *hm.get(&"null_count").unwrap();
    Ok(out)
}

pub fn robj_to_wrap_schema(robj: Robj) -> RResult<Wrap<pl::Schema>> {
    use pl::Schema;
    let hm = robj.as_list().unwrap().into_hashmap();
    let mut schema = Schema::with_capacity(hm.capacity());

    for (key, value) in hm.into_iter() {
        let dt = crate::utils::robj_to_datatype(value)?;
        schema.with_column(key.into(), dt.into());
    }

    let schema: Wrap<Schema> = schema.into();

    Ok(schema)
}

pub fn robj_to_compat_level(robj: Robj) -> RResult<pl::CompatLevel> {
    use pl::CompatLevel;
    let out;
    if robj.is_real() {
        if let Ok(compat_level) = CompatLevel::with_level(robj.as_real().unwrap() as u16) {
            out = compat_level;
        } else {
            return Err(polars::prelude::PolarsError::ComputeError(
                format!("invalid compat level").into(),
            )
            .into());
        }
    } else if robj.is_integer() {
        if let Ok(compat_level) = CompatLevel::with_level(robj.as_integer().unwrap() as u16) {
            out = compat_level;
        } else {
            return Err(polars::prelude::PolarsError::ComputeError(
                format!("invalid compat level").into(),
            )
            .into());
        }
    } else if robj.is_logical() {
        if robj.as_bool().unwrap() {
            out = CompatLevel::newest();
        } else {
            out = CompatLevel::oldest();
        }
    } else {
        return Err(polars::prelude::PolarsError::ComputeError(
            format!("'compat_level' argument accepts int or bool").into(),
        )
        .into());
    }

    Ok(out)
}

pub fn parse_fill_null_strategy(
    strategy: &str,
    limit: Option<u32>,
) -> RResult<pl::FillNullStrategy> {
    use pl::FillNullStrategy::*;
    match strategy {
        "forward" => Ok(Forward(limit)),
        "backward" => Ok(Backward(limit)),
        "min" => Ok(Min),
        "max" => Ok(Max),
        "mean" => Ok(Mean),
        "zero" => Ok(Zero),
        "one" => Ok(One),
        s => rerr().notachoice(format!(
            "FillNullStrategy ('{s}') must be one of 'forward', 'backward', 'min', 'max', 'mean', 'zero', 'one'"
        )),
    }
}

pub fn robjs_to_ewm_options(
    alpha: Robj,
    adjust: Robj,
    bias: Robj,
    min_periods: Robj,
    ignore_nulls: Robj,
) -> RResult<pl::EWMOptions> {
    Ok(pl::EWMOptions {
        alpha: robj_to!(f64, alpha)?,
        adjust: robj_to!(bool, adjust)?,
        bias: robj_to!(bool, bias)?,
        min_periods: robj_to!(usize, min_periods)?,
        ignore_nulls: robj_to!(bool, ignore_nulls)?,
    })
}

extendr_module! {
    mod rdatatype;
    impl RPolarsDataType;
    impl RPolarsDataTypeVector;
    impl RPolarsRField;
}
