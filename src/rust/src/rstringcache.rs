use crate::rpolarserr::*;
use extendr_api::prelude::*;

#[extendr]
pub fn enable_string_cache() -> RResult<()> {
    polars_core::enable_string_cache();
    Ok(())
}

#[extendr]
pub fn disable_string_cache() -> RResult<()> {
    polars_core::disable_string_cache();
    Ok(())
}

#[extendr]
pub fn using_string_cache() -> bool {
    polars_core::using_string_cache()
}

extendr_module! {
    mod rstringcache;
    fn enable_string_cache;
    fn disable_string_cache;
    fn using_string_cache;
}
