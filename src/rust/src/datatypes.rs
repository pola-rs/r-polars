use crate::Wrap;
use polars::prelude::*;
use savvy::{r_println, savvy};

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
        let ordering = TryInto::<Wrap<CategoricalOrdering>>::try_into(ordering)?.0;
        Ok(DataType::Categorical(None, ordering).into())
    }

    pub fn new_datetime(time_unit: &str, time_zone: Option<&str>) -> savvy::Result<Self> {
        let time_unit = TryInto::<Wrap<TimeUnit>>::try_into(time_unit)?.0;
        let time_zone = time_zone.map(|s| s.to_string());
        Ok(DataType::Datetime(time_unit, time_zone).into())
    }

    pub fn new_duration(time_unit: &str) -> savvy::Result<Self> {
        let time_unit = TryInto::<Wrap<TimeUnit>>::try_into(time_unit)?.0;
        Ok(DataType::Duration(time_unit).into())
    }
}
