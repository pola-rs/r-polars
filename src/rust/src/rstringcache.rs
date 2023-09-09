use crate::robj_to;
use crate::rpolarserr::*;
use extendr_api::prelude::*;

// public literal switch
// if toggle==True & counter.is_zero(), set counter to one
// if toggle==False & counter.is_not_zero, set counter to zero
// otherwise do leave counter as is
#[extendr]
pub fn enable_string_cache(toggle: Robj) -> RResult<()> {
    let toggle = robj_to!(bool, toggle)?;
    match (toggle, polars_core::using_string_cache()) {
        (true, false) => polars_core::enable_string_cache(true), //counter 0 -> 1
        (false, true) => {
            // counter x -> 0
            while polars_core::using_string_cache() {
                polars_core::enable_string_cache(false)
            }
        }
        _ => (), // switch already as requested
    };
    Ok(())
}

// private, convenient for implementing nested contexts in R
#[extendr]
pub fn increment_string_cache_counter(toggle: Robj) -> RResult<()> {
    polars_core::enable_string_cache(robj_to!(bool, toggle)?);
    Ok(())
}

// public, maybe?
#[extendr]
pub fn reset_string_cache(toggle: Robj) -> RResult<()> {
    polars_core::enable_string_cache(robj_to!(bool, toggle)?);
    Ok(())
}

// public
#[extendr]
pub fn using_string_cache() -> bool {
    polars_core::using_string_cache()
}

extendr_module! {
    mod rstringcache;
    fn enable_string_cache;
    fn using_string_cache;
    fn increment_string_cache_counter;
    fn reset_string_cache;
}
