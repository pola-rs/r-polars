use std::num::NonZeroUsize;

use crate::prelude::*;
use crate::{PlRDataFrame, PlRDataType, PlRExpr, PlRLazyFrame, PlRSeries, RPolarsErr};
use polars::prelude::cloud::CloudOptions;
use polars::series::ops::NullBehavior;
use savvy::{ListSexp, NumericScalar, NumericSexp, NumericTypedSexp, Sexp, StringSexp, TypedSexp};
use search_sorted::SearchSortedSide;
pub mod base_date;
mod chunked_array;
pub mod clock;
pub mod data_table;

// Same as savvy
const F64_MAX_SIGFIG: f64 = (2_u64.pow(53) - 1) as f64;
const F64_MIN_SIGFIG: f64 = -(2_u64.pow(53) as f64);
const F64_TOLERANCE: f64 = 0.01;

#[repr(transparent)]
pub struct Wrap<T>(pub T);

impl<T> Clone for Wrap<T>
where
    T: Clone,
{
    fn clone(&self) -> Self {
        Wrap(self.0.clone())
    }
}
impl<T> From<T> for Wrap<T> {
    fn from(t: T) -> Self {
        Wrap(t)
    }
}

impl TryFrom<&str> for PlRDataType {
    type Error = String;

    fn try_from(name: &str) -> Result<Self, String> {
        let dt = match name {
            "Int8" => DataType::Int8,
            "Int16" => DataType::Int16,
            "Int32" => DataType::Int32,
            "Int64" => DataType::Int64,
            "Int128" => DataType::Int128,
            "UInt8" => DataType::UInt8,
            "UInt16" => DataType::UInt16,
            "UInt32" => DataType::UInt32,
            "UInt64" => DataType::UInt64,
            "Float32" => DataType::Float32,
            "Float64" => DataType::Float64,
            "Boolean" => DataType::Boolean,
            "String" => DataType::String,
            "Binary" => DataType::Binary,
            "Categorical" => DataType::Categorical(None, Default::default()),
            "Enum" => DataType::Enum(None, Default::default()),
            "Date" => DataType::Date,
            "Time" => DataType::Time,
            "Datetime" => DataType::Datetime(TimeUnit::Microseconds, None),
            "Duration" => DataType::Duration(TimeUnit::Microseconds),
            "Decimal" => DataType::Decimal(None, None), // "none" scale => "infer"
            "List" => DataType::List(Box::new(DataType::Null)),
            "Array" => DataType::Array(Box::new(DataType::Null), 0),
            "Struct" => DataType::Struct(vec![]),
            "Null" => DataType::Null,
            "Unknown" => DataType::Unknown(Default::default()),
            _ => {
                return Err(format!("'{}' is not a valid data type name.", name));
            }
        };
        Ok(Self { dt })
    }
}

impl From<ListSexp> for Wrap<Vec<Option<Vec<u8>>>> {
    fn from(list: ListSexp) -> Self {
        let raw_list = list
            .values_iter()
            .map(|value| match value.into_typed() {
                TypedSexp::Raw(r) => Some(r.to_vec()),
                TypedSexp::Null(_) => None,
                _ => unreachable!("Only accept a list of Raw"),
            })
            .collect::<Vec<_>>();
        Wrap(raw_list)
    }
}

impl TryFrom<&str> for Wrap<u8> {
    type Error = String;

    fn try_from(string: &str) -> Result<Self, String> {
        let mut utf8_byte_iter = string.as_bytes().iter();
        match (utf8_byte_iter.next(), utf8_byte_iter.next()) {
            (Some(s), None) => Ok(Wrap(*s)),
            (None, None) => Err("cannot extract single byte from empty string".to_string()),
            (Some(_), Some(_)) => Err("multi byte-string not allowed".to_string()),
            (None, Some(_)) => unreachable!("the iter() cannot yield Some after None(depleted)"),
        }
    }
}

impl TryFrom<ListSexp> for Wrap<Vec<DataFrame>> {
    type Error = savvy::Error;

    fn try_from(list: ListSexp) -> Result<Self, savvy::Error> {
        let dfs = list
            .values_iter()
            .map(|sexp| match sexp.into_typed() {
                TypedSexp::Environment(e) => Ok(<&PlRDataFrame>::try_from(e)?.df.clone()),
                _ => Err("Only accept a list of polars data frames".to_string()),
            })
            .collect::<Result<Vec<_>, _>>()?;
        Ok(Wrap(dfs))
    }
}

impl TryFrom<ListSexp> for Wrap<Vec<LazyFrame>> {
    type Error = savvy::Error;

    fn try_from(list: ListSexp) -> Result<Self, savvy::Error> {
        let lfs = list
            .values_iter()
            .map(|sexp| match sexp.into_typed() {
                TypedSexp::Environment(e) => Ok(<&PlRLazyFrame>::try_from(e)?.ldf.clone()),
                _ => Err("Only accept a list of polars lazy frames".to_string()),
            })
            .collect::<Result<Vec<_>, _>>()?;
        Ok(Wrap(lfs))
    }
}

impl TryFrom<ListSexp> for Wrap<Vec<Series>> {
    type Error = savvy::Error;

    fn try_from(list: ListSexp) -> Result<Self, savvy::Error> {
        let s = list
            .values_iter()
            .map(|sexp| match sexp.into_typed() {
                TypedSexp::Environment(e) => Ok(<&PlRSeries>::from(e).series.clone()),
                _ => Err("Only accept a list of polars series".to_string()),
            })
            .collect::<Result<Vec<_>, _>>()?;
        Ok(Wrap(s))
    }
}

impl From<ListSexp> for Wrap<Vec<Expr>> {
    fn from(list: ListSexp) -> Self {
        let expr_list = list
            .iter()
            .map(|(name, value)| {
                let rexpr = match value.into_typed() {
                    TypedSexp::Environment(e) => <&PlRExpr>::from(e).clone(),
                    _ => unreachable!("Only accept a list of Expr"),
                };
                if name.is_empty() {
                    rexpr.inner
                } else {
                    rexpr.inner.alias(name)
                }
            })
            .collect();
        Wrap(expr_list)
    }
}

impl TryFrom<ListSexp> for Wrap<Vec<DataType>> {
    type Error = savvy::Error;

    fn try_from(list: ListSexp) -> Result<Self, savvy::Error> {
        let dtypes = list
            .values_iter()
            .map(|sexp| match sexp.into_typed() {
                TypedSexp::Environment(e) => Ok(<&PlRDataType>::try_from(e)?.dt.clone()),
                _ => Err("Only accept a list of polars data types".to_string()),
            })
            .collect::<Result<Vec<_>, _>>()?;
        Ok(Wrap(dtypes))
    }
}

impl TryFrom<ListSexp> for Wrap<Vec<Field>> {
    type Error = savvy::Error;

    fn try_from(list: ListSexp) -> Result<Self, savvy::Error> {
        let fields = list
            .iter()
            .map(|(name, value)| match value.into_typed() {
                TypedSexp::Environment(e) => {
                    let dtype = <&PlRDataType>::try_from(e)?.dt.clone();
                    Ok(Field::new(name.into(), dtype))
                }
                _ => Err("Only accept a list of polars data types".to_string()),
            })
            .collect::<Result<Vec<_>, _>>()?;
        Ok(Wrap(fields))
    }
}

impl TryFrom<&str> for Wrap<CategoricalOrdering> {
    type Error = String;

    fn try_from(ordering: &str) -> Result<Self, String> {
        let ordering = match ordering {
            "physical" => CategoricalOrdering::Physical,
            "lexical" => CategoricalOrdering::Lexical,
            v => {
                return Err(format!(
                    "categorical `ordering` must be one of ('physical', 'lexical'), got '{v}'"
                ))
            }
        };
        Ok(Wrap(ordering))
    }
}

impl From<Wrap<&Arc<RevMapping>>> for Vec<String> {
    fn from(mapping: Wrap<&Arc<RevMapping>>) -> Vec<String> {
        mapping
            .0
            .get_categories()
            .into_iter()
            .map(|v| v.unwrap_or_default().to_string())
            .collect::<Vec<_>>()
    }
}

impl From<Wrap<&CategoricalOrdering>> for String {
    fn from(ordering: Wrap<&CategoricalOrdering>) -> String {
        match *ordering.0 {
            CategoricalOrdering::Physical => "physical".into(),
            CategoricalOrdering::Lexical => "lexical".into(),
        }
    }
}

impl TryFrom<&str> for Wrap<TimeUnit> {
    type Error = String;

    fn try_from(time_unit: &str) -> Result<Self, String> {
        let time_unit = match time_unit {
            "ns" => TimeUnit::Nanoseconds,
            "us" => TimeUnit::Microseconds,
            "ms" => TimeUnit::Milliseconds,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(time_unit))
    }
}

impl TryFrom<NumericScalar> for Wrap<NonZeroUsize> {
    type Error = savvy::Error;

    fn try_from(n: NumericScalar) -> Result<Self, savvy::Error> {
        let n = <Wrap<usize>>::try_from(n)?.0;
        Ok(Wrap(
            <NonZeroUsize>::try_from(n).map_err(|e| RPolarsErr::Other(e.to_string()))?,
        ))
    }
}

impl TryFrom<NumericScalar> for Wrap<usize> {
    type Error = savvy::Error;

    fn try_from(n: NumericScalar) -> Result<Self, savvy::Error> {
        let n = n.as_usize()?;
        Ok(Wrap(n))
    }
}

impl TryFrom<NumericSexp> for Wrap<Vec<usize>> {
    type Error = savvy::Error;

    fn try_from(v: NumericSexp) -> Result<Self, savvy::Error> {
        let v = v.iter_usize().collect::<Result<Vec<_>, _>>()?;
        Ok(Wrap(v))
    }
}

impl TryFrom<NumericScalar> for Wrap<i64> {
    type Error = savvy::Error;

    fn try_from(v: NumericScalar) -> Result<Self, savvy::Error> {
        match v {
            NumericScalar::Integer(i) => Ok(Wrap(i as i64)),
            NumericScalar::Real(f) => {
                if f.is_nan() {
                    Err("`NaN` cannot be converted to i64".into())
                } else if f.is_infinite() || !(F64_MIN_SIGFIG..=F64_MAX_SIGFIG).contains(&f) {
                    Err(format!("{f:?} is out of range that can be safely converted to i64").into())
                } else if (f - f.round()).abs() > F64_TOLERANCE {
                    Err(format!("{f:?} is not integer-ish").into())
                } else {
                    Ok(Wrap(f as i64))
                }
            }
        }
    }
}

impl TryFrom<NumericSexp> for Wrap<Vec<i64>> {
    type Error = savvy::Error;

    fn try_from(v: NumericSexp) -> Result<Self, savvy::Error> {
        let v = match v.into_typed() {
            NumericTypedSexp::Integer(i) => i.iter().map(|&x| x as i64).collect::<Vec<_>>(),
            NumericTypedSexp::Real(f) => {
                if f.iter().any(|&x| x.is_nan()) {
                    return Err("`NaN` cannot be converted to i64".into());
                } else if f.iter().any(|&x| x.is_infinite()) {
                    return Err("infinite values cannot be converted to i64".into());
                } else if f
                    .iter()
                    .any(|&x| !(F64_MIN_SIGFIG..=F64_MAX_SIGFIG).contains(&x))
                {
                    return Err("out of range values cannot be converted to i64".into());
                } else if f.iter().any(|&x| (x - x.round()).abs() > F64_TOLERANCE) {
                    return Err("non-integer-ish values cannot be converted to i64".into());
                } else {
                    f.iter().map(|&x| x as i64).collect::<Vec<_>>()
                }
            }
        };
        Ok(Wrap(v))
    }
}

impl TryFrom<NumericScalar> for Wrap<u8> {
    type Error = savvy::Error;

    fn try_from(v: NumericScalar) -> Result<Self, savvy::Error> {
        match v {
            NumericScalar::Integer(i) => <u8>::try_from(i)
                .map_err(|e| e.to_string().into())
                .map(Wrap),
            NumericScalar::Real(f) => {
                if f.is_nan() {
                    Err("`NaN` cannot be converted to u8".into())
                } else if f.is_infinite() || !(0f64..=u8::MAX as f64).contains(&f) {
                    Err(format!("{f:?} is out of range that can be safely converted to u8").into())
                } else if (f - f.round()).abs() > F64_TOLERANCE {
                    Err(format!("{f:?} is not integer-ish").into())
                } else {
                    Ok(Wrap(f as u8))
                }
            }
        }
    }
}

impl TryFrom<NumericScalar> for Wrap<u32> {
    type Error = savvy::Error;

    fn try_from(v: NumericScalar) -> Result<Self, savvy::Error> {
        match v {
            NumericScalar::Integer(i) => <u32>::try_from(i)
                .map_err(|e| e.to_string().into())
                .map(Wrap),
            NumericScalar::Real(f) => {
                if f.is_nan() {
                    Err("`NaN` cannot be converted to u32".into())
                } else if f.is_infinite() || !(0f64..=u32::MAX as f64).contains(&f) {
                    Err(format!("{f:?} is out of range that can be safely converted to u32").into())
                } else if (f - f.round()).abs() > F64_TOLERANCE {
                    Err(format!("{f:?} is not integer-ish").into())
                } else {
                    Ok(Wrap(f as u32))
                }
            }
        }
    }
}

impl TryFrom<NumericScalar> for Wrap<u64> {
    type Error = savvy::Error;

    fn try_from(v: NumericScalar) -> Result<Self, savvy::Error> {
        match v {
            NumericScalar::Integer(i) => <u64>::try_from(i)
                .map_err(|e| e.to_string().into())
                .map(Wrap),
            NumericScalar::Real(f) => {
                if f.is_nan() {
                    Err("`NaN` cannot be converted to u64".into())
                } else if f.is_infinite() || !(0f64..=F64_MAX_SIGFIG).contains(&f) {
                    Err(format!("{f:?} is out of range that can be safely converted to u64").into())
                } else if (f - f.round()).abs() > F64_TOLERANCE {
                    Err(format!("{f:?} is not integer-ish").into())
                } else {
                    Ok(Wrap(f as u64))
                }
            }
        }
    }
}

impl TryFrom<&str> for Wrap<char> {
    type Error = savvy::Error;

    fn try_from(v: &str) -> Result<Self, savvy::Error> {
        let n_chars = v.len();
        if n_chars == 1 {
            Ok(Wrap(v.chars().nth(0).unwrap()))
        } else {
            Err(format!(
                "Expected a string with one character only, currently has {n_chars:?} (from {v:?})."
            ))?
        }
    }
}

impl TryFrom<StringSexp> for Wrap<Vec<(String, String)>> {
    type Error = savvy::Error;

    fn try_from(sexp: StringSexp) -> Result<Self, savvy::Error> {
        let Some(names) = sexp.get_names() else {
            return Err("Expected a named vector".to_string().into());
        };
        let out = names
            .into_iter()
            .zip(sexp.iter())
            .map(|(name, value)| (name.to_string(), value.to_string()))
            .collect::<Vec<_>>();
        Ok(Wrap(out))
    }
}

impl TryFrom<&str> for Wrap<NonExistent> {
    type Error = String;

    fn try_from(non_existent: &str) -> Result<Self, String> {
        let parsed = match non_existent {
            "null" => NonExistent::Null,
            "raise" => NonExistent::Raise,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<NullBehavior> {
    type Error = String;

    fn try_from(null_behavior: &str) -> Result<Self, String> {
        let parsed = match null_behavior {
            "drop" => NullBehavior::Drop,
            "ignore" => NullBehavior::Ignore,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<WindowMapping> {
    type Error = String;

    fn try_from(mapping_strategy: &str) -> Result<Self, String> {
        let parsed = match mapping_strategy {
            "group_to_rows" => WindowMapping::GroupsToRows,
            "join" => WindowMapping::Join,
            "explode" => WindowMapping::Explode,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<SetOperation> {
    type Error = String;

    fn try_from(operation: &str) -> Result<Self, String> {
        let parsed = match operation {
            "union" => SetOperation::Union,
            "intersection" => SetOperation::Intersection,
            "difference" => SetOperation::Difference,
            "symmetric_difference" => SetOperation::SymmetricDifference,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<ListToStructWidthStrategy> {
    type Error = String;

    fn try_from(operation: &str) -> Result<Self, String> {
        let parsed = match operation {
            "first_non_null" => ListToStructWidthStrategy::FirstNonNull,
            "max_width" => ListToStructWidthStrategy::MaxWidth,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<ClosedWindow> {
    type Error = String;

    fn try_from(closed: &str) -> Result<Self, String> {
        let parsed = match closed {
            "both" => ClosedWindow::Both,
            "left" => ClosedWindow::Left,
            "none" => ClosedWindow::None,
            "right" => ClosedWindow::Right,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<ClosedInterval> {
    type Error = String;

    fn try_from(closed: &str) -> Result<Self, String> {
        let parsed = match closed {
            "both" => ClosedInterval::Both,
            "left" => ClosedInterval::Left,
            "right" => ClosedInterval::Right,
            "none" => ClosedInterval::None,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<RankMethod> {
    type Error = String;

    fn try_from(method: &str) -> Result<Self, String> {
        let parsed = match method {
            "average" => RankMethod::Average,
            "min" => RankMethod::Min,
            "max" => RankMethod::Max,
            "dense" => RankMethod::Dense,
            "ordinal" => RankMethod::Ordinal,
            "random" => RankMethod::Random,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<SearchSortedSide> {
    type Error = String;

    fn try_from(method: &str) -> Result<Self, String> {
        let parsed = match method {
            "any" => SearchSortedSide::Any,
            "left" => SearchSortedSide::Left,
            "right" => SearchSortedSide::Right,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<InterpolationMethod> {
    type Error = String;

    fn try_from(method: &str) -> Result<Self, String> {
        let parsed = match method {
            "linear" => InterpolationMethod::Linear,
            "nearest" => InterpolationMethod::Nearest,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

pub(crate) fn parse_fill_null_strategy(
    strategy: &str,
    limit: FillNullLimit,
) -> Result<FillNullStrategy, String> {
    let parsed = match strategy {
        "forward" => FillNullStrategy::Forward(limit),
        "backward" => FillNullStrategy::Backward(limit),
        "min" => FillNullStrategy::Min,
        "max" => FillNullStrategy::Max,
        "mean" => FillNullStrategy::Mean,
        "zero" => FillNullStrategy::Zero,
        "one" => FillNullStrategy::One,
        _ => return Err("unreachable".to_string()),
    };
    Ok(parsed)
}

impl TryFrom<&str> for Wrap<Roll> {
    type Error = String;

    fn try_from(roll: &str) -> Result<Self, String> {
        let parsed = match roll {
            "raise" => Roll::Raise,
            "forward" => Roll::Forward,
            "backward" => Roll::Backward,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<QuantileMethod> {
    type Error = String;

    fn try_from(roll: &str) -> Result<Self, String> {
        let parsed = match roll {
            "nearest" => QuantileMethod::Nearest,
            "higher" => QuantileMethod::Higher,
            "lower" => QuantileMethod::Lower,
            "midpoint" => QuantileMethod::Midpoint,
            "linear" => QuantileMethod::Linear,
            "equiprobable" => QuantileMethod::Equiprobable,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<UniqueKeepStrategy> {
    type Error = String;

    fn try_from(strategy: &str) -> Result<Self, String> {
        let parsed = match strategy {
            "first" => UniqueKeepStrategy::First,
            "last" => UniqueKeepStrategy::Last,
            "none" => UniqueKeepStrategy::None,
            "any" => UniqueKeepStrategy::Any,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<JoinType> {
    type Error = String;

    fn try_from(how: &str) -> Result<Self, String> {
        let parsed = match how {
            "cross" => JoinType::Cross,
            "inner" => JoinType::Inner,
            "left" => JoinType::Left,
            "right" => JoinType::Right,
            "full" => JoinType::Full,
            "semi" => JoinType::Semi,
            "anti" => JoinType::Anti,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<JoinValidation> {
    type Error = String;

    fn try_from(validation: &str) -> Result<Self, String> {
        let parsed = match validation {
            "m:m" => JoinValidation::ManyToMany,
            "1:m" => JoinValidation::OneToMany,
            "1:1" => JoinValidation::OneToOne,
            "m:1" => JoinValidation::ManyToOne,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<Label> {
    type Error = String;

    fn try_from(label: &str) -> Result<Self, String> {
        let parsed = match label {
            "left" => Label::Left,
            "right" => Label::Right,
            "datapoint" => Label::DataPoint,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<StartBy> {
    type Error = String;

    fn try_from(start_by: &str) -> Result<Self, String> {
        let parsed = match start_by {
            "window" => StartBy::WindowBound,
            "datapoint" => StartBy::DataPoint,
            "monday" => StartBy::Monday,
            "tuesday" => StartBy::Tuesday,
            "wednesday" => StartBy::Wednesday,
            "thursday" => StartBy::Thursday,
            "friday" => StartBy::Friday,
            "saturday" => StartBy::Saturday,
            "sunday" => StartBy::Sunday,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<QuoteStyle> {
    type Error = String;

    fn try_from(quote_style: &str) -> Result<Self, String> {
        let parsed = match quote_style {
            "always" => QuoteStyle::Always,
            "necessary" => QuoteStyle::Necessary,
            "non_numeric" => QuoteStyle::NonNumeric,
            "never" => QuoteStyle::Never,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<AsofStrategy> {
    type Error = String;

    fn try_from(strategy: &str) -> Result<Self, String> {
        let parsed = match strategy {
            "forward" => AsofStrategy::Forward,
            "backward" => AsofStrategy::Backward,
            "nearest" => AsofStrategy::Nearest,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<CsvEncoding> {
    type Error = String;

    fn try_from(encoding: &str) -> Result<Self, String> {
        let parsed = match encoding {
            "utf8" => CsvEncoding::Utf8,
            "utf8-lossy" => CsvEncoding::LossyUtf8,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<StringSexp> for Wrap<NullValues> {
    type Error = String;

    fn try_from(null_values: StringSexp) -> Result<Self, String> {
        let has_names = null_values.get_names().is_some();
        if has_names {
            let values = null_values.to_vec();
            let names = null_values.get_names().unwrap();
            let res = names
                .into_iter()
                .zip(values)
                .map(|(xi, yi)| (xi.into(), yi.into()))
                .collect::<Vec<(PlSmallStr, PlSmallStr)>>();
            Ok(Wrap(NullValues::Named(res)))
        } else if null_values.len() == 1 {
            let vals = null_values.to_vec();
            let val = *(vals.first().unwrap());
            return Ok(Wrap(NullValues::AllColumnsSingle(val.into())));
        } else {
            let vals = null_values
                .to_vec()
                .into_iter()
                .map(|x| x.into())
                .collect::<Vec<PlSmallStr>>();
            return Ok(Wrap(NullValues::AllColumns(vals)));
        }
    }
}

impl TryFrom<ListSexp> for Wrap<Schema> {
    type Error = savvy::Error;

    fn try_from(dtypes: ListSexp) -> Result<Self, savvy::Error> {
        let fields = <Wrap<Vec<Field>>>::try_from(dtypes)?.0;
        let mut schema = Schema::with_capacity(fields.len());
        for field in fields {
            schema.with_column(field.name, field.dtype);
        }
        Ok(Wrap(schema))
    }
}

pub(crate) fn parse_cloud_options(
    uri: &str,
    kv: Vec<(String, String)>,
) -> savvy::Result<CloudOptions> {
    let out = CloudOptions::from_untyped_config(uri, kv).map_err(RPolarsErr::from)?;
    Ok(out)
}

// TODO: Refactor with adding `parquet` feature as like Python Polars
#[cfg(not(target_arch = "wasm32"))]
impl TryFrom<&str> for Wrap<ParallelStrategy> {
    type Error = String;

    fn try_from(strategy: &str) -> Result<Self, String> {
        let parsed = match strategy {
            "auto" => ParallelStrategy::Auto,
            "columns" => ParallelStrategy::Columns,
            "row_groups" => ParallelStrategy::RowGroups,
            "prefiltered" => ParallelStrategy::Prefiltered,
            "none" => ParallelStrategy::None,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<&str> for Wrap<MaintainOrderJoin> {
    type Error = String;

    fn try_from(maintain_order: &str) -> Result<Self, String> {
        let parsed = match maintain_order {
            "none" => MaintainOrderJoin::None,
            "left" => MaintainOrderJoin::Left,
            "right" => MaintainOrderJoin::Right,
            "left_right" => MaintainOrderJoin::LeftRight,
            "right_left" => MaintainOrderJoin::RightLeft,
            _ => return Err("unreachable".to_string()),
        };
        Ok(Wrap(parsed))
    }
}

impl TryFrom<NumericScalar> for Wrap<CompatLevel> {
    type Error = savvy::Error;

    fn try_from(value: NumericScalar) -> Result<Self, Self::Error> {
        // CompatLevel is u16, but currently only use 0 and 1, so u8 is enough
        let level = <Wrap<u8>>::try_from(value)?.0 as u16;
        let compat_level = CompatLevel::with_level(level).map_err(RPolarsErr::from)?;
        Ok(Wrap(compat_level))
    }
}

impl TryFrom<&str> for Wrap<CompatLevel> {
    type Error = savvy::Error;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        let compat_level = match value {
            "newest" => CompatLevel::newest(),
            "oldest" => CompatLevel::oldest(),
            _ => return Err("unreachable".to_string().into()),
        };
        Ok(Wrap(compat_level))
    }
}

impl TryFrom<Sexp> for Wrap<CompatLevel> {
    type Error = savvy::Error;

    fn try_from(value: Sexp) -> Result<Self, Self::Error> {
        if value.is_numeric() {
            <NumericScalar>::try_from(value).and_then(|v| <Wrap<CompatLevel>>::try_from(v))
        } else if value.is_string() {
            <&str>::try_from(value).and_then(|v| <Wrap<CompatLevel>>::try_from(v))
        } else {
            Err("Invalid compat level".to_string().into())
        }
    }
}

#[cfg(not(target_arch = "wasm32"))]
pub(crate) fn parse_parquet_compression(
    compression: &str,
    compression_level: Option<i32>,
) -> savvy::Result<ParquetCompression> {
    let parsed = match compression {
        "uncompressed" => ParquetCompression::Uncompressed,
        "snappy" => ParquetCompression::Snappy,
        "gzip" => ParquetCompression::Gzip(
            compression_level
                .map(|lvl| {
                    GzipLevel::try_new(lvl as u8)
                        .map_err(|e| savvy::Error::new(format!("{e:?}").as_str()))
                })
                .transpose()?,
        ),
        "lzo" => ParquetCompression::Lzo,
        "brotli" => ParquetCompression::Brotli(
            compression_level
                .map(|lvl| {
                    BrotliLevel::try_new(lvl as u32)
                        .map_err(|e| savvy::Error::new(format!("{e:?}").as_str()))
                })
                .transpose()?,
        ),
        "lz4" => ParquetCompression::Lz4Raw,
        "zstd" => ParquetCompression::Zstd(
            compression_level
                .map(|lvl| {
                    ZstdLevel::try_new(lvl)
                        .map_err(|e| savvy::Error::new(format!("{e:?}").as_str()))
                })
                .transpose()?,
        ),
        _ => return Err(RPolarsErr::Other("unreachable".to_string()).into()),
    };
    Ok(parsed)
}
