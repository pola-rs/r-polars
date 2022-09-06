use extendr_api::prelude::*;
pub mod rdataframe;
pub mod rdatatype;
pub mod rlazyframe;
pub mod utils;

use rdataframe::get_rdataframe_metadata;
use utils::extendr_concurrent::ParRObj;

use polars::prelude::Series;

//public channel to locate main thread from any sub thread
use crate::utils::extendr_concurrent::{Storage, ThreadCom};

static CONFIG: Storage<std::sync::RwLock<ThreadCom<(ParRObj, Series), Series>>> = Storage::new();

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
