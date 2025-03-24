use crate::{PlRLazyFrame, Wrap, prelude::*};
use savvy::{ListSexp, NumericScalar, Result, savvy};

#[savvy]
#[repr(transparent)]
pub struct PlRLazyGroupBy {
    pub lgb: Option<LazyGroupBy>,
}

impl From<LazyGroupBy> for PlRLazyGroupBy {
    fn from(lgb: LazyGroupBy) -> Self {
        PlRLazyGroupBy { lgb: Some(lgb) }
    }
}

#[savvy]
impl PlRLazyGroupBy {
    fn agg(&mut self, aggs: ListSexp) -> Result<PlRLazyFrame> {
        let lgb = self.lgb.clone().unwrap();
        let aggs = <Wrap<Vec<Expr>>>::from(aggs).0;
        Ok(lgb.agg(aggs).into())
    }

    fn head(&mut self, n: NumericScalar) -> Result<PlRLazyFrame> {
        let lgb = self.lgb.clone().unwrap();
        let n = <Wrap<usize>>::try_from(n)?.0;
        Ok(lgb.head(Some(n)).into())
    }

    fn tail(&mut self, n: NumericScalar) -> Result<PlRLazyFrame> {
        let lgb = self.lgb.clone().unwrap();
        let n = <Wrap<usize>>::try_from(n)?.0;
        Ok(lgb.tail(Some(n)).into())
    }
}
