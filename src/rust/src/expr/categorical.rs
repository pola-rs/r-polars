use crate::PlRExpr;
use savvy::{savvy, Result};

#[savvy]
impl PlRExpr {
    pub fn cat_get_categories(&self) -> Result<PlRExpr> {
        Ok(self.inner.clone().cat().get_categories().into())
    }
}
