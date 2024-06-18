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
}
