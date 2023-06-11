#[cfg(all(target_os = "linux", not(use_mimalloc)))]
use jemallocator::Jemalloc;
#[cfg(any(not(target_os = "linux"), use_mimalloc))]
use mimalloc::MiMalloc;
#[global_allocator]
#[cfg(all(target_os = "linux", not(use_mimalloc)))]
static ALLOC: Jemalloc = Jemalloc;

#[global_allocator]
#[cfg(any(not(target_os = "linux"), use_mimalloc))]
static ALLOC: MiMalloc = MiMalloc;
pub mod concurrent;
pub mod lazy;

pub mod arrow_interop;
pub mod conversion;
pub mod conversion_r_to_s;
pub mod conversion_s_to_r;
pub mod rdataframe;
pub mod rdatatype;
pub mod rlib;
pub mod series;
pub mod utils;

pub use serde_json;

use extendr_api::prelude::*;
use utils::extendr_concurrent::ParRObj;

use polars::prelude::Series;
pub use polars_core;
pub use smartstring;

use crate::utils::extendr_concurrent::{Storage, ThreadCom};
type ThreadComStorage = Storage<std::sync::RwLock<Option<ThreadCom<(ParRObj, Series), Series>>>>;
static CONFIG: ThreadComStorage = Storage::new();

// Macro to generate exports
extendr_module! {
    mod polars;
    use rdataframe;
    use lazy;
    use series;
    use concurrent;
}
