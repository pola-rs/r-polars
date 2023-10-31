use crate::rpolarserr::*;
use extendr_api::prelude::*;
use polars_core::StringCacheHolder;

struct RPolarsStringCacheHolder(Option<StringCacheHolder>);

#[extendr]
impl RPolarsStringCacheHolder {
    fn hold() -> RPolarsStringCacheHolder {
        RPolarsStringCacheHolder(Some(StringCacheHolder::hold()))
    }

    // R Garbage collection is not deterministic. Deleting all references to RPolarsStringCacheHolder
    // will cause it to be dropped eventually. Calling release ensures immediate drop, leave back a None.
    fn release(&mut self) -> () {
        let _opt_sch = self.0.take();
    }
}
// No need for "impl Drop for RPolarsStringCacheHolder" as Drop::<StringCacheHolder> will be called at R gc().

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
    impl RPolarsStringCacheHolder;
    fn enable_string_cache;
    fn disable_string_cache;
    fn using_string_cache;
}
