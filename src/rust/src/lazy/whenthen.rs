use crate::lazy::dsl::RPolarsExpr;
use crate::robj_to;
use crate::rpolarserr::RResult;
use extendr_api::prelude::*;
use polars::lazy::dsl;
use polars::prelude as pl;

#[derive(Clone)]
pub struct RPolarsWhen {
    inner: dsl::When,
}

#[derive(Clone)]
pub struct RPolarsThen {
    inner: dsl::Then,
}

#[derive(Clone)]
pub struct RPolarsChainedWhen {
    inner: dsl::ChainedWhen,
}

#[derive(Clone)]
pub struct RPolarsChainedThen {
    inner: dsl::ChainedThen,
}

#[extendr]
impl RPolarsWhen {
    pub fn new(condition: Robj) -> RResult<RPolarsWhen> {
        Ok(RPolarsWhen {
            inner: dsl::when(robj_to!(PLExprCol, condition)?),
        })
    }

    fn then(&self, statement: Robj) -> RResult<RPolarsThen> {
        Ok(RPolarsThen {
            inner: self.inner.clone().then(robj_to!(PLExprCol, statement)?),
        })
    }
}

#[extendr]
impl RPolarsThen {
    fn when(&self, condition: Robj) -> RResult<RPolarsChainedWhen> {
        Ok(RPolarsChainedWhen {
            inner: self.inner.clone().when(robj_to!(PLExprCol, condition)?),
        })
    }

    fn otherwise(&self, statement: Robj) -> RResult<RPolarsExpr> {
        Ok(self
            .inner
            .clone()
            .otherwise(robj_to!(PLExprCol, statement)?)
            .into())
    }

    fn alias(&self, name: &str) -> RResult<RPolarsExpr> {
        Ok(self
            .inner
            .clone()
            .otherwise(dsl::lit(pl::NULL))
            .alias(name)
            .into())
    }
}

#[extendr]
impl RPolarsChainedWhen {
    fn then(&self, statement: Robj) -> RResult<RPolarsChainedThen> {
        Ok(RPolarsChainedThen {
            inner: self.inner.clone().then(robj_to!(PLExprCol, statement)?),
        })
    }
}

#[extendr]
impl RPolarsChainedThen {
    fn when(&self, condition: Robj) -> RResult<RPolarsChainedWhen> {
        Ok(RPolarsChainedWhen {
            inner: self.inner.clone().when(robj_to!(PLExprCol, condition)?),
        })
    }

    fn otherwise(&self, statement: Robj) -> RResult<RPolarsExpr> {
        Ok(self
            .inner
            .clone()
            .otherwise(robj_to!(PLExprCol, statement)?)
            .into())
    }

    fn alias(&self, name: &str) -> RResult<RPolarsExpr> {
        Ok(self
            .inner
            .clone()
            .otherwise(dsl::lit(pl::NULL))
            .alias(name)
            .into())
    }
}

extendr_module! {
    mod whenthen;
    impl RPolarsWhen;
    impl RPolarsThen;
    impl RPolarsChainedWhen;
    impl RPolarsChainedThen;
}
