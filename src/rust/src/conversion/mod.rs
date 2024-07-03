use crate::prelude::*;
use crate::{PlRDataFrame, PlRDataType, PlRExpr};
use savvy::{ListSexp, NumericScalar, NumericSexp, TypedSexp};
mod chunked_array;

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

impl TryFrom<&str> for Wrap<TimeUnit> {
    type Error = String;

    fn try_from(time_unit: &str) -> Result<Self, String> {
        let time_unit = match time_unit {
            "ns" => TimeUnit::Nanoseconds,
            "us" => TimeUnit::Microseconds,
            "ms" => TimeUnit::Milliseconds,
            v => {
                return Err(format!(
                    "`time_unit` must be one of ('ns', 'us', 'ms'), got '{v}'",
                ))
            }
        };
        Ok(Wrap(time_unit))
    }
}

impl TryFrom<NumericScalar> for Wrap<usize> {
    type Error = String;

    fn try_from(n: NumericScalar) -> Result<Self, String> {
        let n = n.as_f64();
        match n {
            _ if n.is_nan() => Err("n should not be NaN".to_string()),
            _ if n < 0_f64 => Err("n should not be negative".to_string()),
            _ if n > usize::MAX as f64 => {
                Err(format!("n should not be greater than {}", usize::MAX))
            }
            _ => Ok(Wrap(n as usize)),
        }
    }
}

impl TryFrom<NumericSexp> for Wrap<Vec<i64>> {
    type Error = savvy::Error;

    fn try_from(v: NumericSexp) -> Result<Self, savvy::Error> {
        let v = v.as_slice_i32()?;
        Ok(Wrap(v.iter().map(|&x| x as i64).collect()))
    }
}

impl TryFrom<&str> for Wrap<NonExistent> {
    type Error = String;

    fn try_from(non_existent: &str) -> Result<Self, String> {
        let parsed = match non_existent {
            "null" => NonExistent::Null,
            "raise" => NonExistent::Raise,
            v => {
                return Err(format!(
                    "`non_existent` must be one of ('null', 'raise'), got '{v}'",
                ))
            }
        };
        Ok(Wrap(parsed))
    }
}
