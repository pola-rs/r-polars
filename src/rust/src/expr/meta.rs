use crate::{PlRExpr, RPolarsErr};
use savvy::{savvy, Result, Sexp};

#[savvy]
impl PlRExpr {
    fn meta_output_name(&self) -> Result<Sexp> {
        let name = self
            .inner
            .clone()
            .meta()
            .output_name()
            .map_err(RPolarsErr::from)?;
        name.to_string().try_into()
    }

    fn meta_undo_aliases(&self) -> Result<Self> {
        Ok(self.inner.clone().meta().undo_aliases().into())
    }

    fn meta_has_multiple_outputs(&self) -> Result<Sexp> {
        self.inner.clone().meta().has_multiple_outputs().try_into()
    }

    fn _meta_selector_add(&self, other: &PlRExpr) -> Result<Self> {
        let out = self
            .inner
            .clone()
            .meta()
            ._selector_add(other.inner.clone())
            .map_err(RPolarsErr::from)?;
        Ok(out.into())
    }

    fn _meta_selector_and(&self, other: &PlRExpr) -> Result<Self> {
        let out = self
            .inner
            .clone()
            .meta()
            ._selector_and(other.inner.clone())
            .map_err(RPolarsErr::from)?;
        Ok(out.into())
    }

    fn _meta_selector_sub(&self, other: &PlRExpr) -> Result<Self> {
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

    fn _meta_as_selector(&self) -> Result<Self> {
        Ok(self.inner.clone().meta()._into_selector().into())
    }
}
