use extendr_api::{extendr, prelude::*, Deref, DerefMut, Error, List, Rinternals};
use polars::prelude::{self as pl, IntoLazy, NamedFrom};
use std::result::Result;

#[extendr]
pub struct Rexpr {
    pub e: pl::Expr,
}

impl Deref for Rexpr {
    type Target = pl::Expr;
    fn deref(&self) -> &pl::Expr {
        &self.e
    }
}

impl DerefMut for Rexpr {
    fn deref_mut(&mut self) -> &mut pl::Expr {
        &mut self.e
    }
}

#[extendr]
impl Rexpr {
    pub fn abs(&self) -> Rexpr {
        Rexpr {
            e: self.e.clone().abs(),
        }
    }

    pub fn agg_groups(&self) -> Rexpr {
        Rexpr {
            e: self.e.clone().agg_groups(),
        }
    }

    pub fn alias(&self, s: &str) -> Rexpr {
        Rexpr {
            e: self.e.clone().alias(s),
        }
    }

    pub fn all(&self) -> Rexpr {
        Rexpr {
            e: self.e.clone().all(),
        }
    }
    pub fn any(&self) -> Rexpr {
        Rexpr {
            e: self.e.clone().any(),
        }
    }

    pub fn col(name: &str) -> Self {
        Rexpr { e: pl::col(name) }
    }

    pub fn over(&self, vs: Vec<String>) -> Rexpr {
        let vs2: Vec<&str> = vs.iter().map(|x| x.as_str()).collect();

        Rexpr {
            e: self.e.clone().over(vs2),
        }
    }

    pub fn print(&self) {
        println!("{:#?}", self.e);
    }

    pub fn sum(&self) -> Rexpr {
        Rexpr {
            e: self.e.clone().sum(),
        }
    }
}

extendr_module! {
    mod rexpr;
    impl Rexpr;
}
