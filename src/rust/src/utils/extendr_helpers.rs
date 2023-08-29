use extendr_api::{Attributes, Robj};

// this impl resembles more R side inherits() because the class string does not need to be exactly the same
// but just share a single common class
pub fn robj_inherits<const N: usize>(robj: &Robj, str_array: [&str; N]) -> bool {
    robj.class()
        .map(|si| si.into_iter().any(|s| str_array.contains(&s)))
        .unwrap_or(false)
}
