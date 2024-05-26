#[cfg(all(target_family = "unix", not(allocator = "mimalloc")))]
use jemallocator::Jemalloc;
#[cfg(any(not(target_family = "unix"), allocator = "mimalloc"))]
use mimalloc::MiMalloc;
#[global_allocator]
#[cfg(all(target_family = "unix", not(allocator = "mimalloc")))]
static ALLOC: Jemalloc = Jemalloc;

#[global_allocator]
#[cfg(any(not(target_family = "unix"), allocator = "mimalloc"))]
static ALLOC: MiMalloc = MiMalloc;
pub mod concurrent;
pub mod lazy;

pub mod arrow_interop;
pub mod concat;
pub mod conversion;
pub mod conversion_r_to_s;
pub mod conversion_s_to_r;
pub mod info;
pub mod rbackground;
pub mod rdataframe;
pub mod rdatatype;
pub mod rlib;
pub mod rpolarserr;
pub mod rstringcache;
pub mod series;
#[cfg(feature = "sql")]
pub mod sql;
pub mod utils;
pub use serde_json;

use extendr_api::prelude::*;
pub use polars_core;
pub use smartstring;

use crate::concurrent::{RFnOutput, RFnSignature};
use crate::utils::extendr_concurrent::{InitCell, ThreadCom};
type ThreadComStorage = InitCell<std::sync::RwLock<Option<ThreadCom<RFnSignature, RFnOutput>>>>;
static CONFIG: ThreadComStorage = InitCell::new();
pub use crate::rbackground::RBGPOOL;

// Macro to generate exports
#[cfg(not(feature = "sql"))]
extendr_module! {
    mod polars;
    use arrow_interop;
    use rlib;
    use concat;
    use rdataframe;
    use rpolarserr;
    use rbackground;
    use lazy;
    use series;
    use info;
    use rstringcache;
}

#[cfg(feature = "sql")]
extendr_module! {
    mod polars;
    use arrow_interop;
    use rlib;
    use concat;
    use rdataframe;
    use rpolarserr;
    use rbackground;
    use lazy;
    use series;
    use sql;
    use info;
    use rstringcache;
}
