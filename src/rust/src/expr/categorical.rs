use crate::{PlRExpr, prelude::*};
use savvy::{Result, savvy};

#[savvy]
impl PlRExpr {
    pub fn cat_get_categories(&self) -> Result<Self> {
        Ok(self.inner.clone().cat().get_categories().into())
    }

    fn cat_set_ordering(&self, ordering: &str) -> Result<Self> {
        let ordering = <Wrap<CategoricalOrdering>>::try_from(ordering)?.0;
        Ok(self
            .inner
            .clone()
            .cast(DataType::Categorical(None, ordering))
            .into())
    }
}
