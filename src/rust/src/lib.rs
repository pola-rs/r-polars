use extendr_api::prelude::*;

pub mod datatype;
pub mod rdataframe;
pub mod utils;

use rdataframe::get_rdataframe_metadata;

// Macro to generate exports
extendr_module! {
    mod minipolars;
    use rdataframe;
}
