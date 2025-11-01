mod general;
mod optflags;
mod serde;
mod sink;

use crate::prelude::*;
use parking_lot::RwLock;
use savvy::{EnvironmentSexp, savvy};

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

impl TryFrom<EnvironmentSexp> for &PlRLazyFrame {
    type Error = String;

    fn try_from(env: EnvironmentSexp) -> Result<Self, String> {
        let ptr = env
            .get(".ptr")
            .expect("Failed to get `.ptr` from the object")
            .ok_or("The object is not a valid polars lazy frame")?;
        <&PlRLazyFrame>::try_from(ptr).map_err(|e| e.to_string())
    }
}

#[repr(transparent)]
pub struct PlROptFlags {
    pub inner: RwLock<OptFlags>,
}

impl Clone for PlROptFlags {
    fn clone(&self) -> Self {
        Self {
            inner: RwLock::new(*self.inner.read()),
        }
    }
}

impl From<OptFlags> for PlROptFlags {
    fn from(inner: OptFlags) -> Self {
        PlROptFlags {
            inner: RwLock::new(inner),
        }
    }
}
