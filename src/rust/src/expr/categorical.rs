use crate::{PlRExpr, expr::datatype::PlRDataTypeExpr};
use savvy::{Result, savvy};

#[savvy]
impl PlRExpr {
    pub fn cat_get_categories(&self) -> Result<Self> {
        Ok(self.inner.clone().cat().get_categories().into())
    }

    fn cat_to(&self, dtype: &PlRDataTypeExpr, strict: bool) -> Result<Self> {
        Ok(self
            .inner
            .clone()
            .cat()
            .to(dtype.inner.clone(), strict)
            .into())
    }

    fn cat_physical(&self) -> Result<Self> {
        Ok(self.inner.clone().cat().physical().into())
    }
}
