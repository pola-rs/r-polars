use crate::prelude::*;
use crate::{PlRDataFrame, PlRDataType, PlRExpr};
use polars::series::ops::NullBehavior;
use savvy::{ListSexp, NumericScalar, NumericSexp, TypedSexp};
mod chunked_array;
pub mod clock;
pub mod data_table;

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

// TODO: argument name replacement
impl TryFrom<NumericScalar> for Wrap<usize> {
    type Error = String;

    fn try_from(n: NumericScalar) -> Result<Self, String> {
        const TOLERANCE: f64 = 0.01; // same as savvy
        let n = n.as_f64();
        match n {
            _ if n.is_nan() => Err("`NaN` cannot be converted to usize".to_string()),
            _ if n < 0_f64 => Err(format!(
                "Negative value `{n:?}` cannot be converted to usize"
            )),
            _ if n > usize::MAX as f64 => Err(format!(
                "Value `{n:?}` is too large to be converted to usize"
            )),
            _ => {
                if (n - n.round()).abs() > TOLERANCE {
                    Err(format!(
                        "Value `{n:?}` is not integer-ish enough to be converted to usize"
                    ))
                } else {
                    Ok(Wrap(n as usize))
                }
            }
        }
    }
}

impl TryFrom<NumericSexp> for Wrap<Vec<usize>> {
    type Error = savvy::Error;

    fn try_from(v: NumericSexp) -> Result<Self, savvy::Error> {
        const TOLERANCE: f64 = 0.01; // same as savvy
        let v = v.as_slice_f64();
        let values = v
            .iter()
            .map(|&n| {
                if n.is_nan() {
                    Err("`NaN` cannot be converted to usize".to_string())
                } else if n < 0_f64 {
                    Err(format!(
                        "Negative value `{n:?}` cannot be converted to usize"
                    ))
                } else if n > usize::MAX as f64 {
                    Err(format!(
                        "Value `{n:?}` is too large to be converted to usize"
                    ))
                } else if (n - n.round()).abs() > TOLERANCE {
                    Err(format!(
                        "Value `{n:?}` is not integer-ish enough to be converted to usize"
                    ))
                } else {
                    Ok(n as usize)
                }
            })
            .collect::<Result<Vec<_>, _>>()?;
        Ok(Wrap(values))
    }
}

impl TryFrom<NumericScalar> for Wrap<i64> {
    type Error = savvy::Error;

    fn try_from(v: NumericScalar) -> Result<Self, savvy::Error> {
        const TOLERANCE: f64 = 0.01; // same as savvy
        let v = v.as_f64();
        if v.is_nan() {
            Err("`NaN` cannot be converted to i64".to_string())?
        } else if v < i64::MIN as f64 {
            Err(format!("Value `{v:?}` is too small to be converted to i64"))?
        } else if v > i64::MAX as f64 {
            Err(format!("Value `{v:?}` is too large to be converted to i64"))?
        } else if (v - v.round()).abs() > TOLERANCE {
            Err(format!(
                "Value `{v:?}` is not integer-ish enough to be converted to i64"
            ))?
        } else {
            Ok(Wrap(v as i64))
        }
    }
}

// TODO: update to support more bigger numeric
impl TryFrom<NumericSexp> for Wrap<Vec<i64>> {
    type Error = savvy::Error;

    fn try_from(v: NumericSexp) -> Result<Self, savvy::Error> {
        let v = v.as_slice_i32()?;
        Ok(Wrap(v.iter().map(|&x| x as i64).collect()))
    }
}

impl TryFrom<NumericScalar> for Wrap<u32> {
    type Error = savvy::Error;

    fn try_from(v: NumericScalar) -> Result<Self, savvy::Error> {
        const TOLERANCE: f64 = 0.01; // same as savvy
        let v = v.as_f64();
        if v.is_nan() {
            Err("`NaN` cannot be converted to u32".to_string())?
        } else if v < 0_f64 {
            Err(format!("Value `{v:?}` is too small to be converted to u32"))?
        } else if v > u32::MAX as f64 {
            Err(format!("Value `{v:?}` is too large to be converted to u32"))?
        } else if (v - v.round()).abs() > TOLERANCE {
            Err(format!(
                "Value `{v:?}` is not integer-ish enough to be converted to u32"
            ))?
        } else {
            Ok(Wrap(v as u32))
        }
    }
}

impl TryFrom<NumericScalar> for Wrap<u64> {
    type Error = savvy::Error;

    fn try_from(v: NumericScalar) -> Result<Self, savvy::Error> {
        const TOLERANCE: f64 = 0.01; // same as savvy
        let v = v.as_f64();
        if v.is_nan() {
            Err("`NaN` cannot be converted to u64".to_string())?
        } else if v < 0_f64 {
            Err(format!("Value `{v:?}` is too small to be converted to u64"))?
        } else if v > u64::MAX as f64 {
            Err(format!("Value `{v:?}` is too large to be converted to u64"))?
        } else if (v - v.round()).abs() > TOLERANCE {
            Err(format!(
                "Value `{v:?}` is not integer-ish enough to be converted to u64"
            ))?
        } else {
            Ok(Wrap(v as u64))
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
