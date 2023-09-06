use extendr_api::prelude::*;
use polars;

#[extendr]
fn cargo_rpolars_feature_info() -> List {
    list!(
        default = cfg!(feature = "default"),
        full_features = cfg!(feature = "full_features"),
        simd = cfg!(feature = "simd"),
        rpolars_debug_print = cfg!(feature = "rpolars_debug_print"),
    )
}

#[extendr]
fn rust_polars_version() -> String {
    polars::VERSION.into()
}

extendr_module! {
    mod info;
    fn cargo_rpolars_feature_info;
    fn rust_polars_version;
}
