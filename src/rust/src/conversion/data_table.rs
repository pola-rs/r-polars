use crate::prelude::*;
use savvy::{OwnedIntegerSexp, Sexp};

pub struct IDate {
    sexp: OwnedIntegerSexp,
}

pub struct ITime {
    sexp: OwnedIntegerSexp,
}

impl From<&Int32Chunked> for IDate {
    fn from(ca: &Int32Chunked) -> Self {
        let mut sexp = OwnedIntegerSexp::new(ca.len()).unwrap();
        let _ = sexp.set_class(&["IDate", "Date"]);
        for (i, v) in ca.into_iter().enumerate() {
            if let Some(v) = v {
                let _ = sexp.set_elt(i, v);
            } else {
                let _ = sexp.set_na(i);
            }
        }
        IDate { sexp }
    }
}

impl From<&Float64Chunked> for ITime {
    fn from(ca: &Float64Chunked) -> Self {
        let mut sexp = OwnedIntegerSexp::new(ca.len()).unwrap();
        let _ = sexp.set_class(&["ITime"]);
        for (i, v) in ca.into_iter().enumerate() {
            if let Some(v) = v {
                let _ = sexp.set_elt(i, (v / 1_000_000_000.0) as i32);
            } else {
                let _ = sexp.set_na(i);
            }
        }
        ITime { sexp }
    }
}

impl From<IDate> for Sexp {
    fn from(value: IDate) -> Self {
        value.sexp.into()
    }
}

impl From<ITime> for Sexp {
    fn from(value: ITime) -> Self {
        value.sexp.into()
    }
}
