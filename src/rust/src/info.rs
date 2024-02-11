use extendr_api::prelude::*;
use polars;

#[extendr]
fn cargo_rpolars_feature_info() -> List {
    list!(
        default = cfg!(feature = "default"),
        full_features = cfg!(feature = "nightly")
            & cfg!(feature = "sql")
            & cfg!(feature = "disable_limit_max_threads"),
        disable_limit_max_threads = cfg!(feature = "disable_limit_max_threads"),
        nightly = cfg!(feature = "nightly"),
        sql = cfg!(feature = "sql"),
        rpolars_debug_print = cfg!(feature = "rpolars_debug_print"),
    )
}

#[extendr]
fn rust_polars_version() -> String {
    polars::VERSION.into()
}

#[extendr]
fn thread_pool_size() -> usize {
    polars_core::POOL.current_num_threads()
}

extendr_module! {
    mod info;
    fn cargo_rpolars_feature_info;
    fn rust_polars_version;
    fn thread_pool_size;
}
