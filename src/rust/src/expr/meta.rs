use crate::{PlRExpr, RPolarsErr, prelude::*};
use savvy::{ListSexp, OwnedListSexp, Result, Sexp, savvy};

#[savvy]
impl PlRExpr {
    fn meta_eq(&self, other: &PlRExpr) -> Result<Sexp> {
        let out = self.inner.clone() == other.inner.clone();
        out.try_into()
    }

    fn meta_pop(&self, schema: Option<ListSexp>) -> Result<Sexp> {
        let schema = match schema {
            Some(s) => Some(<Wrap<Schema>>::try_from(s)?.0),
            None => None,
        };
        let exprs = self
            .inner
            .clone()
            .meta()
            .pop(schema.as_ref())
            .map_err(RPolarsErr::from)?;
        let iter = exprs.iter().map(|x| <PlRExpr>::from(x.clone()));
        let mut out = OwnedListSexp::new(exprs.len(), false)?;
        for (i, expr) in iter.enumerate() {
            unsafe {
                out.set_value_unchecked(i, Sexp::try_from(expr)?.0);
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

    fn compute_tree_format(&self, as_dot: bool, schema: Option<ListSexp>) -> Result<Sexp> {
        let schema = match schema {
            Some(s) => Some(<Wrap<Schema>>::try_from(s)?.0),
            None => None,
        };
        let e = self
            .inner
            .clone()
            .meta()
            .into_tree_formatter(as_dot, schema.as_ref())
            .map_err(RPolarsErr::from)?;
        format!("{e}").try_into()
    }

    fn meta_is_column(&self) -> Result<Sexp> {
        self.inner.clone().meta().is_column().try_into()
    }
}
