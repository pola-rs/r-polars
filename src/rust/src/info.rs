use extendr_api::prelude::*;
use polars;

#[extendr]
fn cargo_rpolars_feature_info() -> List {
    list!(
        default = cfg!(feature = "default"),
        // `full_features` is a combination of `simd` and `sql` features
        full_features = cfg!(feature = "simd")
            & cfg!(feature = "sql")
            & cfg!(feature = "disable_limit_max_threads"),
        disable_limit_max_threads = cfg!(feature = "disable_limit_max_threads"),
        simd = cfg!(feature = "simd"),
        sql = cfg!(feature = "sql"),
        rpolars_debug_print = cfg!(feature = "rpolars_debug_print"),
    )
}

#[extendr]
fn rust_polars_version() -> String {
    polars::VERSION.into()
}

#[extendr]
fn threadpool_size() -> usize {
    polars_core::POOL.current_num_threads()
}

extendr_module! {
    mod info;
    fn cargo_rpolars_feature_info;
    fn rust_polars_version;
    fn threadpool_size;
}
