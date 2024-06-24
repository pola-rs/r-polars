use crate::PlRExpr;
use savvy::{savvy, NumericScalar, Result};

#[savvy]
impl PlRExpr {
    fn struct_field_by_index(&self, index: NumericScalar) -> Result<Self> {
        let index = index.as_i32()?;
        Ok(self
            .inner
            .clone()
            .struct_()
            .field_by_index(index as i64)
            .into())
    }

    fn struct_field_by_name(&self, name: &str) -> Result<Self> {
        Ok(self.inner.clone().struct_().field_by_name(name).into())
    }
}
