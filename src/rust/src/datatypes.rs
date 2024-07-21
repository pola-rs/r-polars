use crate::prelude::*;
use polars_core::utils::arrow::array::Utf8ViewArray;
use savvy::{
    r_println, savvy, EnvironmentSexp, ListSexp, NullSexp, NumericScalar, OwnedListSexp,
    OwnedRealSexp, Result, Sexp, StringSexp,
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
        let time_zone = time_zone.map(|s| s.to_string());
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
        Ok(create_enum_data_type(categories).into())
    }

    pub fn new_list(inner: PlRDataType) -> Result<Self> {
        Ok(DataType::List(Box::new(inner.dt)).into())
    }

    pub fn new_struct(fields: ListSexp) -> Result<Self> {
        Ok(DataType::Struct(<Wrap<Vec<Field>>>::try_from(fields)?.0).into())
    }

    fn print(&self) -> Result<()> {
        r_println!("{:?}", self.dt);
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
                    .map_or_else(|| NullSexp.into(), |v| v.to_owned().try_into())?;
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
            DataType::Array(inner, width) => {
                let mut out = OwnedListSexp::new(2, true)?;
                let inner: Sexp = PlRDataType { dt: *inner.clone() }.try_into()?;
                let width: Sexp = (*width as f64).try_into()?;
                let _ = out.set_name_and_value(0, "_inner", inner);
                let _ = out.set_name_and_value(1, "width", width);
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
                        dt: field.data_type().clone(),
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
                    |v| {
                        v.get_categories()
                            .into_iter()
                            .map(|v| v.unwrap_or_default().to_string())
                            .collect::<Vec<_>>()
                            .try_into()
                    },
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

    fn is_temporal(&self) -> Result<Sexp> {
        Ok(self.dt.is_temporal().try_into()?)
    }

    fn is_enum(&self) -> Result<Sexp> {
        Ok(self.dt.is_enum().try_into()?)
    }

    fn is_categorical(&self) -> Result<Sexp> {
        Ok(self.dt.is_categorical().try_into()?)
    }

    fn is_string(&self) -> Result<Sexp> {
        Ok(self.dt.is_string().try_into()?)
    }

    fn is_logical(&self) -> Result<Sexp> {
        Ok(self.dt.is_bool().try_into()?)
    }

    fn is_float(&self) -> Result<Sexp> {
        Ok(self.dt.is_float().try_into()?)
    }

    fn is_numeric(&self) -> Result<Sexp> {
        Ok(self.dt.is_numeric().try_into()?)
    }

    fn is_integer(&self) -> Result<Sexp> {
        Ok(self.dt.is_integer().try_into()?)
    }

    fn is_signed_integer(&self) -> Result<Sexp> {
        Ok(self.dt.is_signed_integer().try_into()?)
    }

    fn is_unsigned_integer(&self) -> Result<Sexp> {
        Ok(self.dt.is_unsigned_integer().try_into()?)
    }

    fn is_null(&self) -> Result<Sexp> {
        Ok(self.dt.is_null().try_into()?)
    }

    fn is_binary(&self) -> Result<Sexp> {
        Ok(self.dt.is_binary().try_into()?)
    }

    fn is_primitive(&self) -> Result<Sexp> {
        Ok(self.dt.is_primitive().try_into()?)
    }

    fn is_bool(&self) -> Result<Sexp> {
        Ok(self.dt.is_bool().try_into()?)
    }

    fn is_array(&self) -> Result<Sexp> {
        Ok(self.dt.is_list().try_into()?)
    }

    fn is_list(&self) -> Result<Sexp> {
        Ok(self.dt.is_list().try_into()?)
    }

    fn is_nested(&self) -> Result<Sexp> {
        Ok(self.dt.is_nested().try_into()?)
    }

    fn is_struct(&self) -> Result<Sexp> {
        Ok(self.dt.is_struct().try_into()?)
    }

    fn is_ord(&self) -> Result<Sexp> {
        Ok(self.dt.is_ord().try_into()?)
    }

    fn is_known(&self) -> Result<Sexp> {
        Ok(self.dt.is_known().try_into()?)
    }
}
