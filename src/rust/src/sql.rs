use extendr_api::prelude::*;
use polars::sql::SQLContext;

use crate::{rdataframe::LazyFrame, robj_to, rpolarserr::*};

#[cfg(feature = "sql")]
#[derive(Clone)]
pub struct RPolarsSQLContext {
    pub context: SQLContext,
}

#[cfg(feature = "sql")]
#[extendr]
impl RPolarsSQLContext {
    pub fn new() -> Self {
        Self {
            context: SQLContext::new(),
        }
    }

    pub fn execute(&mut self, query: &str) -> RResult<LazyFrame> {
        Ok(self
            .context
            .execute(query)
            .map_err(RPolarsErr::from)?
            .into())
    }

    pub fn get_tables(&self) -> RResult<Vec<String>> {
        Ok(self.context.get_tables())
    }

    pub fn register(&mut self, name: Robj, lf: Robj) -> RResult<()> {
        Ok(self
            .context
            .register(&robj_to!(str, name)?, robj_to!(LazyFrame, lf)?.0))
    }

    pub fn unregister(&mut self, name: Robj) -> RResult<()> {
        Ok(self.context.unregister(&robj_to!(str, name)?))
    }
}

#[cfg(feature = "sql")]
extendr_module! {
    mod sql;
    impl RPolarsSQLContext;
}
