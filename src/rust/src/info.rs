use extendr_api::prelude::*;

struct FeatureInfo {
    simd: bool,
}

#[extendr]
impl FeatureInfo {
    fn new() -> FeatureInfo {
        FeatureInfo {
            simd: cfg!(feature = "simd"),
        }
    }
    fn to_r(&self) -> List {
        list!(simd = self.simd)
    }
}

extendr_module! {
    mod info;
    impl FeatureInfo;
}
