use crate::prelude::*;
use crate::{PlRDataFrame, PlRDataType, PlRExpr, PlRLazyFrame, PlRSeries, RPolarsErr};
use polars::prelude::cloud::CloudOptions;
use polars::series::ops::NullBehavior;
use savvy::{ListSexp, NumericScalar, NumericSexp, NumericTypedSexp, StringSexp, TypedSexp};
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
            v => return Err(format!("unsupported value: '{v}'",)),
        };
        Ok(Wrap(time_unit))
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
            v => return Err(format!("unsupported value: '{v}'",)),
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
            v => return Err(format!("unsupported value: '{v}'",)),
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
            v => return Err(format!("unsupported value: '{v}'",)),
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
            v => return Err(format!("unsupported value: '{v}'",)),
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
            v => return Err(format!("unsupported value: '{v}'",)),
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

impl TryFrom<&str> for Wrap<ParallelStrategy> {
    type Error = String;

    fn try_from(strategy: &str) -> Result<Self, String> {
        let parsed = match strategy {
            "auto" => ParallelStrategy::Auto,
            "columns" => ParallelStrategy::Columns,
            "row_groups" => ParallelStrategy::RowGroups,
            "prefiltered" => ParallelStrategy::Prefiltered,
            "none" => ParallelStrategy::None,
            v => return Err(format!("unsupported value: '{v}'",)),
        };
        Ok(Wrap(parsed))
    }
}
