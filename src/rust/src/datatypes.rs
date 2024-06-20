use crate::Wrap;
use polars::prelude::*;
use savvy::{r_println, savvy, Sexp};

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

#[savvy]
impl PlRDataType {
    fn print(&self) -> savvy::Result<()> {
        r_println!("{:?}", self.dt);
        Ok(())
    }

    pub fn new_from_name(name: &str) -> savvy::Result<Self> {
        name.try_into().map_err(savvy::Error::from)
    }

    pub fn new_categorical(ordering: &str) -> savvy::Result<Self> {
        let ordering = <Wrap<CategoricalOrdering>>::try_from(ordering)?.0;
        Ok(DataType::Categorical(None, ordering).into())
    }

    pub fn new_datetime(time_unit: &str, time_zone: Option<&str>) -> savvy::Result<Self> {
        let time_unit = <Wrap<TimeUnit>>::try_from(time_unit)?.0;
        let time_zone = time_zone.map(|s| s.to_string());
        Ok(DataType::Datetime(time_unit, time_zone).into())
    }

    pub fn new_duration(time_unit: &str) -> savvy::Result<Self> {
        let time_unit = <Wrap<TimeUnit>>::try_from(time_unit)?.0;
        Ok(DataType::Duration(time_unit).into())
    }

    fn is_temporal(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_temporal().try_into()?)
    }

    fn is_enum(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_enum().try_into()?)
    }

    fn is_categorical(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_categorical().try_into()?)
    }

    fn is_string(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_string().try_into()?)
    }

    fn is_logical(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_bool().try_into()?)
    }

    fn is_float(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_float().try_into()?)
    }

    fn is_numeric(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_numeric().try_into()?)
    }

    fn is_integer(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_integer().try_into()?)
    }

    fn is_signed_integer(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_signed_integer().try_into()?)
    }

    fn is_unsigned_integer(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_unsigned_integer().try_into()?)
    }

    fn is_null(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_null().try_into()?)
    }

    fn is_binary(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_binary().try_into()?)
    }

    fn is_primitive(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_primitive().try_into()?)
    }

    fn is_bool(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_bool().try_into()?)
    }

    fn is_array(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_list().try_into()?)
    }

    fn is_list(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_list().try_into()?)
    }

    fn is_nested(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_nested().try_into()?)
    }

    fn is_struct(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_struct().try_into()?)
    }

    fn is_ord(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_ord().try_into()?)
    }

    fn is_known(&self) -> savvy::Result<Sexp> {
        Ok(self.dt.is_known().try_into()?)
    }
}
