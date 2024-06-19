use crate::error::RPolarsErr;
use crate::prelude::*;
use crate::{PlRDataFrame, PlRExpr};
use polars_core::prelude::*;
use savvy::{savvy, ListSexp};

#[savvy]
#[repr(transparent)]
#[derive(Clone)]
pub struct PlRLazyFrame {
    pub ldf: LazyFrame,
}

impl PlRLazyFrame {
    fn get_schema(&mut self) -> savvy::Result<SchemaRef> {
        let schema = self.ldf.schema().map_err(RPolarsErr::from)?;
        Ok(schema)
    }
}

impl From<LazyFrame> for PlRLazyFrame {
    fn from(ldf: LazyFrame) -> Self {
        PlRLazyFrame { ldf }
    }
}

#[savvy]
impl PlRLazyFrame {
    fn select(&mut self, exprs: ListSexp) -> savvy::Result<Self> {
        let ldf = self.ldf.clone();
        let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
        Ok(ldf.select(exprs).into())
    }

    fn collect(&self) -> savvy::Result<PlRDataFrame> {
        let df = self.ldf.clone().collect().map_err(RPolarsErr::from)?;
        Ok(df.into())
    }
}
