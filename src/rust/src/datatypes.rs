use crate::prelude::*;
use polars_core::utils::arrow::array::Utf8ViewArray;
use savvy::{
    r_println, savvy, EnvironmentSexp, ListSexp, NullSexp, NumericScalar, NumericSexp,
    OwnedListSexp, OwnedRealSexp, Result, Sexp, StringSexp,
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
        fn opt_usize_to_string(opt: Option<usize>) -> String {
            opt.map_or_else(|| "NULL".to_string(), |v| v.to_string())
        }

        fn opt_string_to_string(opt: Option<PlSmallStr>) -> String {
            opt.map_or_else(|| "NULL".to_string(), |v| format!("'{v}'"))
        }

        match &self.dt {
            DataType::Decimal(precision, scale) => {
                write!(
                    f,
                    "Decimal(precision={}, scale={})",
                    opt_usize_to_string(*precision),
                    opt_usize_to_string(*scale)
                )
            }
            DataType::Datetime(time_unit, time_zone) => {
                write!(
                    f,
                    "Datetime(time_unit='{}', time_zone={})",
                    time_unit,
                    opt_string_to_string(time_zone.clone())
                )
            }
            DataType::Duration(time_unit) => {
                write!(f, "Duration(time_unit='{}')", time_unit)
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
                write!(f, "Struct({})", fields)
            }
            DataType::Categorical(_, ordering) => {
                write!(
                    f,
                    "Categorical(ordering='{}')",
                    <String>::from(Wrap(ordering))
                )
            }
            DataType::Enum(categories, _) => {
                write!(
                    f,
                    "Enum(categories={})",
                    categories.as_ref().map_or_else(
                        || "NULL".to_string(),
                        |v| {
                            format!(
                                "c({})",
                                <Vec<String>>::from(Wrap(v))
                                    .iter()
                                    .map(|v| format!("'{v}'"))
                                    .collect::<Vec<_>>()
                                    .join(", ")
                            )
                        }
                    )
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

    pub fn new_decimal(scale: NumericScalar, precision: Option<NumericScalar>) -> Result<Self> {
        let precision = precision
            .map(|p| <Wrap<usize>>::try_from(p))
            .transpose()?
            .map(|p| p.0);
        let scale = Some(<Wrap<usize>>::try_from(scale)?.0);
        Ok(DataType::Decimal(precision, scale).into())
    }

    pub fn new_datetime(time_unit: &str, time_zone: Option<&str>) -> Result<Self> {
        let time_unit = <Wrap<TimeUnit>>::try_from(time_unit)?.0;
        let time_zone: Option<PlSmallStr> = time_zone.map(|s| s.into());
        Ok(DataType::Datetime(time_unit, time_zone).into())
    }

    pub fn new_duration(time_unit: &str) -> Result<Self> {
        let time_unit = <Wrap<TimeUnit>>::try_from(time_unit)?.0;
        Ok(DataType::Duration(time_unit).into())
    }

    pub fn new_categorical(ordering: &str) -> Result<Self> {
        let ordering = <Wrap<CategoricalOrdering>>::try_from(ordering)?.0;
        Ok(DataType::Categorical(None, ordering).into())
    }

    pub fn new_enum(categories: StringSexp) -> Result<Self> {
        let categories =
            Utf8ViewArray::from_slice(categories.iter().map(Some).collect::<Vec<_>>().as_slice());
        Ok(create_enum_dtype(categories).into())
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
            return Ok(DataType::Array(
                Box::new(new_array_impl(inner, shape)?),
                width,
            ));
        }

        new_array_impl(inner, &mut shape).map(|dt| dt.into())
    }

    pub fn new_struct(fields: ListSexp) -> Result<Self> {
        Ok(DataType::Struct(<Wrap<Vec<Field>>>::try_from(fields)?.0).into())
    }

    fn print(&self) -> Result<()> {
        r_println!("{}", self);
        Ok(())
    }

    fn _get_datatype_fields(&self) -> Result<Sexp> {
        match &self.dt {
            DataType::Decimal(precision, scale) => {
                let mut out = OwnedListSexp::new(2, true)?;
                let precision: Sexp =
                    precision.map_or_else(|| NullSexp.into(), |v| (v as f64).try_into())?;
                let scale: Sexp =
                    scale.map_or_else(|| NullSexp.into(), |v| (v as f64).try_into())?;
                let _ = out.set_name_and_value(0, "precision", precision);
                let _ = out.set_name_and_value(1, "scale", scale);
                Ok(out.into())
            }
            DataType::Datetime(time_unit, time_zone) => {
                let mut out = OwnedListSexp::new(2, true)?;
                let time_unit: Sexp = format!("{time_unit}").try_into()?;
                let time_zone: Sexp = time_zone
                    .as_ref()
                    .map_or_else(|| NullSexp.into(), |v| v.to_string().try_into())?;
                let _ = out.set_name_and_value(0, "time_unit", time_unit);
                let _ = out.set_name_and_value(1, "time_zone", time_zone);
                Ok(out.into())
            }
            DataType::Duration(time_unit) => {
                let mut out = OwnedListSexp::new(1, true)?;
                let time_unit: Sexp = format!("{time_unit}").try_into()?;
                let _ = out.set_name_and_value(0, "time_unit", time_unit);
                Ok(out.into())
            }
            DataType::Array(inner, _) => {
                let mut out = OwnedListSexp::new(2, true)?;
                let inner: Sexp = PlRDataType { dt: *inner.clone() }.try_into()?;
                let shape: Sexp = OwnedRealSexp::try_from_slice(
                    &self
                        .dt
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
            DataType::Categorical(_, ordering) => {
                let mut out = OwnedListSexp::new(1, true)?;
                let ordering: Sexp = <String>::from(Wrap(ordering)).try_into()?;
                let _ = out.set_name_and_value(0, "ordering", ordering);
                Ok(out.into())
            }
            DataType::Enum(categories, _) => {
                let mut out = OwnedListSexp::new(1, true)?;
                let categories: Sexp = categories.as_ref().map_or_else(
                    || NullSexp.into(),
                    |v| <Vec<String>>::from(Wrap(v)).try_into(),
                )?;
                let _ = out.set_name_and_value(0, "categories", categories);
                Ok(out.into())
            }
            _ => Ok(NullSexp.into()),
        }
    }

    fn eq(&self, other: &PlRDataType) -> Result<Sexp> {
        (self.dt == other.dt).try_into()
    }

    fn ne(&self, other: &PlRDataType) -> Result<Sexp> {
        (self.dt != other.dt).try_into()
    }

    fn is_array(&self) -> Result<Sexp> {
        self.dt.is_array().try_into()
    }

    fn is_binary(&self) -> Result<Sexp> {
        self.dt.is_binary().try_into()
    }

    fn is_bool(&self) -> Result<Sexp> {
        self.dt.is_bool().try_into()
    }

    fn is_categorical(&self) -> Result<Sexp> {
        self.dt.is_categorical().try_into()
    }

    fn is_date(&self) -> Result<Sexp> {
        self.dt.is_date().try_into()
    }

    fn is_enum(&self) -> Result<Sexp> {
        self.dt.is_enum().try_into()
    }

    fn is_float(&self) -> Result<Sexp> {
        self.dt.is_float().try_into()
    }

    fn is_integer(&self) -> Result<Sexp> {
        self.dt.is_integer().try_into()
    }

    fn is_known(&self) -> Result<Sexp> {
        self.dt.is_known().try_into()
    }

    fn is_list(&self) -> Result<Sexp> {
        self.dt.is_list().try_into()
    }

    fn is_logical(&self) -> Result<Sexp> {
        self.dt.is_bool().try_into()
    }

    fn is_nested(&self) -> Result<Sexp> {
        self.dt.is_nested().try_into()
    }

    fn is_nested_null(&self) -> Result<Sexp> {
        self.dt.is_nested_null().try_into()
    }

    fn is_null(&self) -> Result<Sexp> {
        self.dt.is_null().try_into()
    }

    fn is_numeric(&self) -> Result<Sexp> {
        self.dt.is_numeric().try_into()
    }

    fn is_ord(&self) -> Result<Sexp> {
        self.dt.is_ord().try_into()
    }

    fn is_primitive(&self) -> Result<Sexp> {
        self.dt.is_primitive().try_into()
    }

    fn is_signed_integer(&self) -> Result<Sexp> {
        self.dt.is_signed_integer().try_into()
    }

    fn is_string(&self) -> Result<Sexp> {
        self.dt.is_string().try_into()
    }

    fn is_struct(&self) -> Result<Sexp> {
        self.dt.is_struct().try_into()
    }

    fn is_temporal(&self) -> Result<Sexp> {
        self.dt.is_temporal().try_into()
    }

    fn is_unsigned_integer(&self) -> Result<Sexp> {
        self.dt.is_unsigned_integer().try_into()
    }
}
