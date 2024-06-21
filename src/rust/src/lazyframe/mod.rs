use crate::prelude::*;
use crate::{PlRDataFrame, PlRExpr, PlRLazyGroupBy, RPolarsErr};
use polars_core::prelude::*;
use savvy::{savvy, ListSexp, Result};

#[savvy]
#[repr(transparent)]
#[derive(Clone)]
pub struct PlRLazyFrame {
    pub ldf: LazyFrame,
}

impl PlRLazyFrame {
    fn get_schema(&mut self) -> Result<SchemaRef> {
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
    fn select(&mut self, exprs: ListSexp) -> Result<Self> {
        let ldf = self.ldf.clone();
        let exprs = <Wrap<Vec<Expr>>>::from(exprs).0;
        Ok(ldf.select(exprs).into())
    }

    fn group_by(&mut self, by: ListSexp, maintain_order: bool) -> Result<PlRLazyGroupBy> {
        let ldf = self.ldf.clone();
        let by = <Wrap<Vec<Expr>>>::from(by).0;
        let lazy_gb = if maintain_order {
            ldf.group_by_stable(by)
        } else {
            ldf.group_by(by)
        };

        Ok(lazy_gb.into())
    }

    fn collect(&self) -> Result<PlRDataFrame> {
        let df = self.ldf.clone().collect().map_err(RPolarsErr::from)?;
        Ok(df.into())
    }
}
