use extendr_api::prelude::*;

pub mod rdataframe;
pub mod rdatatype;
pub mod rlazyframe;
pub mod utils;

use rdataframe::get_rdataframe_metadata;

//public channel to locate main thread from any sub thread
use crate::utils::extendr_concurrent::{Storage, ThreadCom};

static CONFIG: Storage<std::sync::RwLock<ThreadCom<String, polars::prelude::Series>>> =
    Storage::new();

// Macro to generate exports
extendr_module! {
    mod minipolars;
    use rdataframe;
}
