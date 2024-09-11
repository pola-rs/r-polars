use crate::{PlRExpr, RPolarsErr};
use savvy::{savvy, Result};

#[savvy]
impl PlRExpr {
    fn meta_selector_add(&self, other: &PlRExpr) -> Result<Self> {
        let out = self
            .inner
            .clone()
            .meta()
            ._selector_add(other.inner.clone())
            .map_err(RPolarsErr::from)?;
        Ok(out.into())
    }

    fn meta_selector_and(&self, other: &PlRExpr) -> Result<Self> {
        let out = self
            .inner
            .clone()
            .meta()
            ._selector_and(other.inner.clone())
            .map_err(RPolarsErr::from)?;
        Ok(out.into())
    }

    fn meta_selector_sub(&self, other: &PlRExpr) -> Result<Self> {
        let out = self
            .inner
            .clone()
            .meta()
            ._selector_sub(other.inner.clone())
            .map_err(RPolarsErr::from)?;
        Ok(out.into())
    }

    // TODO: enable after polars update
    // fn meta_selector_xor(&self, other: &PlRExpr) -> Result<Self> {
    //     let out = self
    //         .inner
    //         .clone()
    //         .meta()
    //         ._selector_xor(other.inner.clone())
    //         .map_err(RPolarsErr::from)?;
    //     Ok(out.into())
    // }

    fn meta_as_selector(&self) -> Result<Self> {
        Ok(self.inner.clone().meta()._into_selector().into())
    }
}
