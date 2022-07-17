use extendr_api::prelude::*;

pub mod rdataframe;
pub mod rdatatype;
pub mod utils;

use rdataframe::get_rdataframe_metadata;

// Macro to generate exports
extendr_module! {
    mod minipolars;
    use rdataframe;
}
