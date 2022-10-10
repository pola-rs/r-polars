//! Fast and easy queue abstraction.
//!
//! Provides an abstraction over a queue.  When the abstraction is used
//! there are these advantages:
//! - Fast
//! - [`Easy`]
//!
//! [`Easy`]: http://thatwaseasy.example.com

use extendr_api::prelude::*;
pub mod concurrent;
pub mod rdataframe;
pub mod rdatatype;
pub mod rlazyframe;
pub mod rlib;
pub mod utils;

use rdataframe::get_rdataframe_metadata;
use utils::extendr_concurrent::ParRObj;

use polars::prelude::Series;

pub use polars_core;

//pub use polars_core;

//public channel to locate main thread from any sub thread
use crate::utils::extendr_concurrent::{Storage, ThreadCom};

static CONFIG: Storage<std::sync::RwLock<Option<ThreadCom<(ParRObj, Series), Series>>>> =
    Storage::new();

// impl std::fmt::Display for (ParRObj, polars::prelude::Series) {
//     fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
//         write!(f, "probj {:?},  series {}", self.0, self.1)
//     }
// }

// Macro to generate exports
extendr_module! {
    mod minipolars;
    use rdataframe;
}
