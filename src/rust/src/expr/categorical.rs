use crate::PlRExpr;
use savvy::{Result, savvy};

#[savvy]
impl PlRExpr {
    pub fn cat_get_categories(&self) -> Result<Self> {
        Ok(self.inner.clone().cat().get_categories().into())
    }
}
