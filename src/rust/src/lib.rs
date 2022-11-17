pub mod concurrent;
pub mod rdataframe;
pub mod rdatatype;
pub mod rlazyframe;
pub mod rlib;
pub mod utils;

use extendr_api::prelude::*;
use rdataframe::get_rdataframe_metadata;
use utils::extendr_concurrent::ParRObj;

use polars::prelude::Series;
pub use polars_core;
pub use smartstring;

use crate::utils::extendr_concurrent::{Storage, ThreadCom};
static CONFIG: Storage<std::sync::RwLock<Option<ThreadCom<(ParRObj, Series), Series>>>> =
    Storage::new();

// Macro to generate exports
extendr_module! {
    mod minipolars;
    use rdataframe;
}
