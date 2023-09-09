use super::dsl::Expr;
use crate::robj_to;
use crate::rpolarserr::RResult;
use extendr_api::prelude::*;
use polars::lazy::dsl;

#[derive(Clone)]
pub struct When {
    inner: dsl::When,
}

#[derive(Clone)]
pub struct Then {
    inner: dsl::Then,
}

#[derive(Clone)]
pub struct ChainedWhen {
    inner: dsl::ChainedWhen,
}

#[derive(Clone)]
pub struct ChainedThen {
    inner: dsl::ChainedThen,
}

#[extendr]
impl When {
    pub fn new(condition: Robj) -> RResult<When> {
        Ok(When {
            inner: dsl::when(robj_to!(PLExprCol, condition)?),
        })
    }

    fn then(&self, statement: Robj) -> RResult<Then> {
        Ok(Then {
            inner: self.inner.clone().then(robj_to!(PLExprCol, statement)?),
        })
    }
}

#[extendr]
impl Then {
    fn when(&self, condition: Robj) -> RResult<ChainedWhen> {
        Ok(ChainedWhen {
            inner: self.inner.clone().when(robj_to!(PLExprCol, condition)?),
        })
    }

    fn otherwise(&self, statement: Robj) -> RResult<Expr> {
        Ok(self
            .inner
            .clone()
            .otherwise(robj_to!(PLExprCol, statement)?)
            .into())
    }
}

#[extendr]
impl ChainedWhen {
    fn then(&self, statement: Robj) -> RResult<ChainedThen> {
        Ok(ChainedThen {
            inner: self.inner.clone().then(robj_to!(PLExprCol, statement)?),
        })
    }
}

#[extendr]
impl ChainedThen {
    fn when(&self, condition: Robj) -> RResult<ChainedWhen> {
        Ok(ChainedWhen {
            inner: self.inner.clone().when(robj_to!(PLExprCol, condition)?),
        })
    }

    fn otherwise(&self, statement: Robj) -> RResult<Expr> {
        Ok(self
            .inner
            .clone()
            .otherwise(robj_to!(PLExprCol, statement)?)
            .into())
    }
}

extendr_module! {
    mod whenthen;
    impl When;
    impl Then;
    impl ChainedWhen;
    impl ChainedThen;
}
