//! Fast and easy queue abstraction.
//!
//! Provides an abstraction over a queue.  When the abstraction is used
//! there are these advantages:
//! - Fast
//! - [`Easy`]
//!
//! [`Easy`]: http://thatwaseasy.example.com

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

// struct MyStroke {
//     s: f64,
//     s2: String,
// }

// #[extendr(r_name = "RStruct")]
// impl MyStroke {
//     pub fn new() -> Self {
//         MyStroke {
//             s: 42.0,
//             s2: "hej".into(),
//         }
//     }

//     pub fn edit(&mut self, s: f64) {
//         self.s = s
//     }

//     pub fn get(&self) -> f64 {
//         self.s.clone()
//     }
// }

// #[extendr(r_name = "r_fun")]
// pub fn my_fun() -> String {
//     "hello from me".into()
// }

// Macro to generate exports
extendr_module! {
    mod minipolars;
    use rdataframe;
}
