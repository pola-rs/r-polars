use extendr_api::prelude::*;
use polars;

#[extendr]
fn cargo_rpolars_feature_info() -> List {
    list!(
        default = cfg!(feature = "default"),
        // `full_features` is a combination of `simd` and `sql` features
        full_features = cfg!(feature = "simd") & cfg!(feature = "sql"),
        simd = cfg!(feature = "simd"),
        sql = cfg!(feature = "sql"),
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
