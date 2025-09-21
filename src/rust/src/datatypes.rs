use crate::{PlRCategories, PlRExpr, PlRSeries, RPolarsErr, prelude::*};
use polars::lazy::dsl;
use polars_core::utils::{arrow::array::Array, try_get_supertype};
use savvy::{
    EnvironmentSexp, ListSexp, NullSexp, NumericScalar, NumericSexp, OwnedListSexp, OwnedRealSexp,
    OwnedStringSexp, Result, Sexp, TypedSexp, savvy,
};

// As not like in Python, define the data type class in
// the Rust side, because defining class in R and converting
// it to Rust is not easy.

#[savvy]
pub(crate) struct PlRDataType {
    pub(crate) dt: DataType,
}

impl From<&DataType> for PlRDataType {
    fn from(dt: &DataType) -> Self {
        Self { dt: dt.clone() }
    }
}

impl From<DataType> for PlRDataType {
    fn from(dt: DataType) -> Self {
        Self { dt }
    }
}

impl TryFrom<EnvironmentSexp> for &PlRDataType {
    type Error = String;

    fn try_from(env: EnvironmentSexp) -> std::result::Result<Self, String> {
        let ptr = env
            .get(".ptr")
            .expect("Failed to get `.ptr` from the object")
            .ok_or("The object is not a valid polars data type")?;
        <&PlRDataType>::try_from(ptr).map_err(|e| e.to_string())
    }
}

impl std::fmt::Display for PlRDataType {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        match &self.dt {
            DataType::Decimal(precision, scale) => {
                write!(f, "Decimal(precision={}, scale={})", *precision, *scale)
            }
            DataType::Datetime(time_unit, time_zone) => {
                write!(
                    f,
                    "Datetime(time_unit='{}', time_zone={})",
                    time_unit.to_ascii(),
                    match time_zone {
                        Some(tz) => format!("'{tz}'"),
                        None => "NULL".to_string(),
                    }
                )
            }
            DataType::Duration(time_unit) => {
                write!(f, "Duration(time_unit='{}')", time_unit.to_ascii())
            }
            DataType::Array(_, _) => {
                let shape = self
                    .dt
                    .get_shape()
                    .unwrap_or(vec![0])
                    .iter()
                    .map(|v| v.to_string())
                    .collect::<Vec<_>>()
                    .join(", ");
                write!(
                    f,
                    "Array({}, shape=c({}))",
                    PlRDataType {
                        dt: self.dt.array_leaf_dtype().unwrap().clone()
                    },
                    shape
                )
            }
            DataType::List(inner) => write!(f, "List({})", PlRDataType { dt: *inner.clone() }),
            DataType::Struct(fields) => {
                let fields = fields
                    .iter()
                    .map(|field| {
                        format!(
                            "{}{}",
                            if field.name().is_empty() {
                                "".into()
                            } else {
                                format!("`{}`=", &field.name())
                            },
                            PlRDataType {
                                dt: field.dtype().clone()
                            }
                        )
                    })
                    .collect::<Vec<_>>()
                    .join(", ");
                write!(f, "Struct({fields})")
            }
            DataType::Categorical(_, _) => {
                // TODO: include categories
                write!(f, "Categorical(ordering='lexical')")
            }
            DataType::Enum(_, mapping) => {
                let categories = unsafe {
                    StringChunked::from_chunks(
                        PlSmallStr::from_static("category"),
                        vec![mapping.to_arrow(true)],
                    )
                };
                write!(
                    f,
                    "Enum(categories=c({}))",
                    categories
                        .into_iter()
                        .filter_map(|opt_v| format!("'{}'", opt_v.unwrap()).into())
                        .collect::<Vec<String>>()
                        .join(", ")
                )
            }
            _ => write!(f, "{:?}", self.dt),
        }
    }
}

#[savvy]
impl PlRDataType {
    pub fn new_from_name(name: &str) -> Result<Self> {
        name.try_into().map_err(savvy::Error::from)
    }

    pub fn new_decimal(scale: NumericScalar, precision: NumericScalar) -> Result<Self> {
        let precision = <Wrap<usize>>::try_from(precision)?.0;
        let scale = <Wrap<usize>>::try_from(scale)?.0;
        polars_compute::decimal::dec128_verify_prec_scale(precision, scale)
            .map_err(RPolarsErr::from)?;
        Ok(DataType::Decimal(precision, scale).into())
    }

    pub fn new_datetime(time_unit: &str, time_zone: Option<&str>) -> Result<Self> {
        let time_unit = <Wrap<TimeUnit>>::try_from(time_unit)?.0;
        let time_zone = <Wrap<Option<TimeZone>>>::try_from(time_zone)?.0;
        Ok(DataType::Datetime(time_unit, time_zone).into())
    }

    pub fn new_duration(time_unit: &str) -> Result<Self> {
        let time_unit = <Wrap<TimeUnit>>::try_from(time_unit)?.0;
        Ok(DataType::Duration(time_unit).into())
    }

    pub fn new_categorical(categories: &PlRCategories) -> Result<Self> {
        Ok(DataType::from_categories(categories.categories().clone()).into())
    }

    pub fn new_enum(categories: &PlRSeries) -> Result<Self> {
        let ca = categories.series.str().map_err(RPolarsErr::from)?;
        let categories = ca.downcast_iter().next().unwrap().clone();
        assert!(!categories.has_nulls());
        Ok(DataType::from_frozen_categories(
            FrozenCategories::new(categories.values_iter()).unwrap(),
        )
        .into())
    }

    pub fn new_list(inner: &PlRDataType) -> Result<Self> {
        Ok(DataType::List(Box::new(inner.dt.clone())).into())
    }

    pub fn new_array(inner: &PlRDataType, shape: NumericSexp) -> Result<Self> {
        let inner = inner.dt.clone();
        let mut shape = <Wrap<Vec<usize>>>::try_from(shape)?.0;

        fn new_array_impl(
            inner: DataType,
            shape: &mut Vec<usize>,
        ) -> std::result::Result<DataType, savvy::Error> {
            if shape.is_empty() {
                return Err(savvy::Error::from("`shape` must not be empty"));
            }
            if shape.len() == 1 {
                return Ok(DataType::Array(Box::new(inner), shape[0]));
            }
            let width = shape.remove(0);
            Ok(DataType::Array(
                Box::new(new_array_impl(inner, shape)?),
                width,
            ))
        }

        new_array_impl(inner, &mut shape).map(|dt| dt.into())
    }

    pub fn new_struct(fields: ListSexp) -> Result<Self> {
        Ok(DataType::Struct(<Wrap<Vec<Field>>>::try_from(fields)?.0).into())
    }

    // A function to get supertype of a list of data types
    pub fn infer_supertype(dtypes: ListSexp, strict: bool) -> Result<Self> {
        let dtype_vec: Vec<Option<DataType>> = dtypes
            .values_iter()
            .map(|dtype| match dtype.into_typed() {
                TypedSexp::Null(_) => None,
                TypedSexp::Environment(e) => {
                    <&PlRDataType>::try_from(e).ok().map(|dt| dt.dt.clone())
                }
                _ => unreachable!("Only accept a list of PlRDataType"),
            })
            .collect();

        if strict {
            let expected_dtype = dtype_vec
                .iter()
                .find(|opt_dt| opt_dt.is_some())
                .map(|opt_dt| opt_dt.as_ref().unwrap().clone())
                .unwrap_or(DataType::Null);
            for (i, dt) in dtype_vec.iter().enumerate() {
                if let Some(dt) = dt
                    && dt != &expected_dtype
                {
                    return Err(
                            format!("If `strict = TRUE`, all elements of the list except `NULL` must have the same datatype. expected: `{}`, got: `{}` at index: {}", expected_dtype, dt, i + 1).into()
                        );
                }
            }
            Ok(expected_dtype.into())
        } else {
            let dtype = dtype_vec
                .iter()
                .map(|opt_dt| {
                    if let Some(dt) = opt_dt {
                        dt.clone()
                    } else {
                        DataType::Null
                    }
                })
                .reduce(|acc, b| try_get_supertype(&acc, &b).unwrap_or(DataType::Null))
                .unwrap_or(DataType::Null);
            Ok(dtype.into())
        }
    }

    fn as_str(&self, abbreviated: bool) -> Result<Sexp> {
        if abbreviated {
            self.dt.clone().to_string().try_into()
        } else {
            format!("{self}").try_into()
        }
    }

    fn _get_dtype_names(&self) -> Result<Sexp> {
        let names = match &self.dt {
            DataType::Int8 => vec!["int8", "signed_integer", "integer", "numeric"],
            DataType::Int16 => vec!["int16", "signed_integer", "integer", "numeric"],
            DataType::Int32 => vec!["int32", "signed_integer", "integer", "numeric"],
            DataType::Int64 => vec!["int64", "signed_integer", "integer", "numeric"],
            DataType::Int128 => vec!["int128", "signed_integer", "integer", "numeric"],
            DataType::UInt8 => vec!["uint8", "unsigned_integer", "integer", "numeric"],
            DataType::UInt16 => vec!["uint16", "unsigned_integer", "integer", "numeric"],
            DataType::UInt32 => vec!["uint32", "unsigned_integer", "integer", "numeric"],
            DataType::UInt64 => vec!["uint64", "unsigned_integer", "integer", "numeric"],
            DataType::UInt128 => vec!["uint128", "unsigned_integer", "integer", "numeric"],
            DataType::Float32 => vec!["float32", "float", "numeric"],
            DataType::Float64 => vec!["float64", "float", "numeric"],
            DataType::Decimal(_, _) => vec!["decimal", "numeric"],
            DataType::Boolean => vec!["boolean"],
            DataType::String => vec!["string"],
            DataType::Binary => vec!["binary"],
            DataType::Date => vec!["date", "temporal"],
            DataType::Time => vec!["time", "temporal"],
            DataType::Datetime(_, _) => vec!["datetime", "temporal"],
            DataType::Duration(_) => vec!["duration", "temporal"],
            DataType::Categorical(_, _) => vec!["categorical"],
            DataType::Enum(_, _) => vec!["enum"],
            DataType::Null => vec!["null"],
            DataType::Unknown(_) => vec!["unknown"],
            DataType::List(_) => vec!["list", "nested"],
            DataType::Array(_, _) => vec!["array", "nested"],
            DataType::Struct(_) => vec!["struct", "nested"],
            // TODO: what is this? It does not seem supported by py-polars
            DataType::BinaryOffset => vec!["binary_offset"],
        }
        .iter()
        .map(|s| format!("polars_dtype_{s}"))
        .collect::<Vec<_>>();
        let out = OwnedStringSexp::try_from(names)?;
        Ok(out.into())
    }

    fn _get_datatype_fields(&self) -> Result<Sexp> {
        match &self.dt {
            DataType::Decimal(precision, scale) => {
                let mut out = OwnedListSexp::new(2, true)?;
                let precision: Sexp = (*precision as i32).try_into()?;
                let scale: Sexp = (*scale as i32).try_into()?;
                let _ = out.set_name_and_value(0, "precision", precision);
                let _ = out.set_name_and_value(1, "scale", scale);
                Ok(out.into())
            }
            DataType::Datetime(time_unit, time_zone) => {
                let mut out = OwnedListSexp::new(2, true)?;
                let time_unit: Sexp = time_unit.to_ascii().try_into()?;
                let time_zone: Sexp = time_zone
                    .as_ref()
                    .map_or_else(|| NullSexp.into(), |v| v.to_string().try_into())?;
                let _ = out.set_name_and_value(0, "time_unit", time_unit);
                let _ = out.set_name_and_value(1, "time_zone", time_zone);
                Ok(out.into())
            }
            DataType::Duration(time_unit) => {
                let mut out = OwnedListSexp::new(1, true)?;
                let time_unit: Sexp = time_unit.to_ascii().try_into()?;
                let _ = out.set_name_and_value(0, "time_unit", time_unit);
                Ok(out.into())
            }
            DataType::Array(inner, _) => {
                let mut out = OwnedListSexp::new(2, true)?;
                let inner: Sexp = PlRDataType { dt: *inner.clone() }.try_into()?;
                let shape: Sexp = OwnedRealSexp::try_from_slice(
                    self.dt
                        .get_shape()
                        .unwrap_or(vec![0])
                        .iter()
                        .map(|v| *v as f64)
                        .collect::<Vec<_>>(),
                )?
                .into();
                let _ = out.set_name_and_value(0, "_inner", inner);
                let _ = out.set_name_and_value(1, "shape", shape);
                Ok(out.into())
            }
            DataType::List(inner) => {
                let mut out = OwnedListSexp::new(1, true)?;
                let inner: Sexp = PlRDataType { dt: *inner.clone() }.try_into()?;
                let _ = out.set_name_and_value(0, "_inner", inner);
                Ok(out.into())
            }
            DataType::Struct(fields) => {
                let mut out = OwnedListSexp::new(1, true)?;
                let mut list = OwnedListSexp::new(fields.len(), true)?;
                for (i, field) in fields.iter().enumerate() {
                    let name = field.name().as_str();
                    let value: Sexp = PlRDataType {
                        dt: field.dtype().clone(),
                    }
                    .try_into()?;
                    let _ = list.set_name_and_value(i, name, value);
                }
                let _ = out.set_name_and_value(0, "_fields", list);
                Ok(out.into())
            }
            DataType::Categorical(_, _) => {
                // TODO: return categories
                let mut out = OwnedListSexp::new(1, true)?;
                let ordering: Sexp = "lexical".try_into()?;
                let _ = out.set_name_and_value(0, "ordering", ordering);
                Ok(out.into())
            }
            DataType::Enum(_, mapping) => {
                let mut out = OwnedListSexp::new(1, true)?;
                let categories = unsafe {
                    StringChunked::from_chunks(
                        PlSmallStr::from_static("category"),
                        vec![mapping.to_arrow(true)],
                    )
                };
                let sexp: Sexp = Wrap(&categories).into();
                let _ = out.set_name_and_value(0, "categories", sexp);
                Ok(out.into())
            }
            _ => Ok(NullSexp.into()),
        }
    }

    fn max(&self) -> Result<PlRExpr> {
        let v = self.dt.max().map_err(RPolarsErr::from)?;
        Ok(dsl::lit(v).into())
    }

    fn min(&self) -> Result<PlRExpr> {
        let v = self.dt.min().map_err(RPolarsErr::from)?;
        Ok(dsl::lit(v).into())
    }

    fn eq(&self, other: &PlRDataType) -> Result<Sexp> {
        (self.dt == other.dt).try_into()
    }

    fn ne(&self, other: &PlRDataType) -> Result<Sexp> {
        (self.dt != other.dt).try_into()
    }
}
