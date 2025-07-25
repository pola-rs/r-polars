use crate::prelude::*;
use savvy::{NumericScalar, Result, Sexp, savvy};
use std::sync::Arc;

#[savvy]
#[repr(transparent)]
#[derive(Clone)]
pub struct PlRCategories {
    categories: Arc<Categories>,
}

impl PlRCategories {
    pub fn categories(&self) -> &Arc<Categories> {
        &self.categories
    }
}

impl From<Arc<Categories>> for PlRCategories {
    fn from(categories: Arc<Categories>) -> Self {
        Self { categories }
    }
}

#[savvy]
impl PlRCategories {
    pub fn init(name: &str, namespace: &str, physical: &str) -> Result<Self> {
        Ok(Self {
            categories: Categories::new(name.into(), namespace.into(), physical.parse().unwrap()),
        })
    }

    pub fn global_categories() -> Result<Self> {
        Ok(Self {
            categories: Categories::global(),
        })
    }

    pub fn random(namespace: &str, physical: &str) -> Result<Self> {
        Ok(Self {
            categories: Categories::random(namespace.into(), physical.parse().unwrap()),
        })
    }

    pub fn eq(&self, other: &PlRCategories) -> Result<Sexp> {
        Arc::ptr_eq(&self.categories, &other.categories).try_into()
    }

    pub fn hash(&self) -> Result<Sexp> {
        (self.categories.hash() as f64).try_into()
    }

    pub fn name(&self) -> Result<Sexp> {
        self.categories.name().as_str().try_into()
    }

    pub fn namespace(&self) -> Result<Sexp> {
        self.categories.namespace().as_str().try_into()
    }

    pub fn physical(&self) -> Result<Sexp> {
        self.categories.physical().as_str().try_into()
    }

    pub fn get_cat(&self, s: &str) -> Result<Sexp> {
        let opt_catsize = self.categories.mapping().get_cat(s);
        match opt_catsize {
            Some(cat) => (cat as f64).try_into(),
            None => Ok(savvy::NullSexp.into()),
        }
    }

    pub fn cat_to_str(&self, cat: NumericScalar) -> Result<Sexp> {
        let cat_size: CatSize = <Wrap<u32>>::try_from(cat)?.0;
        match self.categories.mapping().cat_to_str(cat_size) {
            Some(s) => s.try_into(),
            None => Ok(savvy::NullSexp.into()),
        }
    }

    pub fn is_global(&self) -> Result<Sexp> {
        self.categories.is_global().try_into()
    }
}
