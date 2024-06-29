use crate::prelude::*;
use savvy::{
    OwnedIntegerSexp, OwnedListSexp, OwnedLogicalSexp, OwnedRealSexp, OwnedStringSexp, Sexp,
};

impl From<Wrap<&BooleanChunked>> for Sexp {
    fn from(ca: Wrap<&BooleanChunked>) -> Self {
        let ca = ca.0;
        let mut sexp = OwnedLogicalSexp::new(ca.len()).unwrap();
        for (i, v) in ca.into_iter().enumerate() {
            if let Some(v) = v {
                let _ = sexp.set_elt(i, v);
            } else {
                let _ = sexp.set_na(i);
            }
        }
        sexp.into()
    }
}

impl From<Wrap<&Int32Chunked>> for Sexp {
    fn from(ca: Wrap<&Int32Chunked>) -> Self {
        let ca = ca.0;
        let mut sexp = OwnedIntegerSexp::new(ca.len()).unwrap();
        for (i, v) in ca.into_iter().enumerate() {
            if let Some(v) = v {
                let _ = sexp.set_elt(i, v);
            } else {
                let _ = sexp.set_na(i);
            }
        }
        sexp.into()
    }
}

impl From<Wrap<&Float64Chunked>> for Sexp {
    fn from(ca: Wrap<&Float64Chunked>) -> Self {
        let ca = ca.0;
        let mut sexp = OwnedRealSexp::new(ca.len()).unwrap();
        for (i, v) in ca.into_iter().enumerate() {
            if let Some(v) = v {
                let _ = sexp.set_elt(i, v);
            } else {
                let _ = sexp.set_na(i);
            }
        }
        sexp.into()
    }
}

impl From<Wrap<&StringChunked>> for Sexp {
    fn from(ca: Wrap<&StringChunked>) -> Self {
        let ca = ca.0;
        let mut sexp = OwnedStringSexp::new(ca.len()).unwrap();
        for (i, v) in ca.into_iter().enumerate() {
            if let Some(v) = v {
                let _ = sexp.set_elt(i, v);
            } else {
                let _ = sexp.set_na(i);
            }
        }
        sexp.into()
    }
}

impl From<Wrap<&DateChunked>> for Sexp {
    fn from(ca: Wrap<&DateChunked>) -> Self {
        let ca = ca.0;
        let mut sexp = OwnedRealSexp::new(ca.len()).unwrap();
        let _ = sexp.set_class(&["Date"]);
        for (i, v) in ca.into_iter().enumerate() {
            if let Some(v) = v {
                let _ = sexp.set_elt(i, v as f64);
            } else {
                let _ = sexp.set_na(i);
            }
        }
        sexp.into()
    }
}
