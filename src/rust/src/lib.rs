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
pub mod rdataframe;
pub mod rdatatype;
pub mod rlazyframe;
pub mod rlib;
pub mod utils;

use extendr_api::prelude::*;
use utils::extendr_concurrent::ParRObj;

use polars::prelude::Series;
pub use polars_core;
pub use smartstring;

use crate::utils::extendr_concurrent::{Storage, ThreadCom};
static CONFIG: Storage<std::sync::RwLock<Option<ThreadCom<(ParRObj, Series), Series>>>> =
    Storage::new();

// Macro to generate exports
extendr_module! {
    mod rpolars;
    use rdataframe;
}
