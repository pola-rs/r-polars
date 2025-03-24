use crate::PlRExpr;
use savvy::{Result, savvy};

#[savvy]
impl PlRExpr {
    fn name_keep(&self) -> Result<Self> {
        Ok(self.inner.clone().name().keep().into())
    }

    fn name_prefix(&self, prefix: &str) -> Result<Self> {
        Ok(self.inner.clone().name().prefix(prefix).into())
    }

    fn name_suffix(&self, suffix: &str) -> Result<Self> {
        Ok(self.inner.clone().name().suffix(suffix).into())
    }

    fn name_to_lowercase(&self) -> Result<Self> {
        Ok(self.inner.clone().name().to_lowercase().into())
    }

    fn name_to_uppercase(&self) -> Result<Self> {
        Ok(self.inner.clone().name().to_uppercase().into())
    }

    fn name_prefix_fields(&self, prefix: &str) -> Result<Self> {
        Ok(self.inner.clone().name().prefix_fields(prefix).into())
    }

    fn name_suffix_fields(&self, suffix: &str) -> Result<Self> {
        Ok(self.inner.clone().name().suffix_fields(suffix).into())
    }
}
