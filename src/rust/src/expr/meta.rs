use crate::{PlRExpr, RPolarsErr};
use savvy::{savvy, OwnedListSexp, Result, Sexp};

#[savvy]
impl PlRExpr {
    fn meta_eq(&self, other: &PlRExpr) -> Result<Sexp> {
        let out = self.inner.clone() == other.inner.clone();
        out.try_into()
    }

    fn meta_pop(&self) -> Result<Sexp> {
        let exprs = self.inner.clone().meta().pop().map_err(RPolarsErr::from)?;
        let iter = exprs.iter().map(|x| <PlRExpr>::from(x.clone()));
        let mut out = OwnedListSexp::new(exprs.len(), false)?;
        for (i, expr) in iter.enumerate() {
            unsafe {
                let _ = out.set_value_unchecked(i, Sexp::try_from(expr)?.0);
            }
        }
        out.into()
    }

    fn meta_root_names(&self) -> Result<Sexp> {
        self.inner
            .clone()
            .meta()
            .root_names()
            .iter()
            .map(|name| name.to_string())
            .collect::<Vec<String>>()
            .try_into()
    }

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

    fn meta_is_regex_projection(&self) -> Result<Sexp> {
        self.inner.clone().meta().is_regex_projection().try_into()
    }

    fn meta_is_column_selection(&self, allow_aliasing: bool) -> Result<Sexp> {
        self.inner
            .clone()
            .meta()
            .is_column_selection(allow_aliasing)
            .try_into()
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

    fn compute_tree_format(&self, display_as_dot: bool) -> Result<Sexp> {
        let e = self
            .inner
            .clone()
            .meta()
            .into_tree_formatter(display_as_dot)
            .map_err(RPolarsErr::from)?;
        format!("{e}").try_into()
    }
}
