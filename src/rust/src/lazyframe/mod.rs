mod general;

use crate::prelude::*;
use savvy::savvy;

#[savvy]
#[repr(transparent)]
#[derive(Clone)]
pub struct PlRLazyFrame {
    pub ldf: LazyFrame,
}

impl From<LazyFrame> for PlRLazyFrame {
    fn from(ldf: LazyFrame) -> Self {
        PlRLazyFrame { ldf }
    }
}
