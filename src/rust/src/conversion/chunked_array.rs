use crate::prelude::*;
use savvy::{
    OwnedIntegerSexp, OwnedListSexp, OwnedLogicalSexp, OwnedRawSexp, OwnedRealSexp,
    OwnedStringSexp, Sexp,
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

impl From<Wrap<&BinaryChunked>> for Sexp {
    fn from(ca: Wrap<&BinaryChunked>) -> Self {
        let ca = ca.0;
        let mut sexp = OwnedListSexp::new(ca.len(), false).unwrap();
        let _ = sexp.set_class(["blob", "vctrs_list_of", "vctrs_vctr", "list"]);
        let _ = sexp.set_attrib("ptype", OwnedRawSexp::new(0).unwrap().into());
        for (i, v) in ca.into_iter().enumerate() {
            unsafe {
                if let Some(v) = v {
                    sexp
                        .set_value_unchecked(i, OwnedRawSexp::try_from_slice(v).unwrap().inner());
                } else {
                    sexp.set_value_unchecked(i, savvy::sexp::null::null());
                }
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

impl From<Wrap<&Int64Chunked>> for Sexp {
    fn from(ca: Wrap<&Int64Chunked>) -> Self {
        let ca = ca.0;
        let mut sexp = OwnedRealSexp::new(ca.len()).unwrap();
        let _ = sexp.set_class(["integer64"]);
        for (i, v) in ca.into_iter().enumerate() {
            if let Some(v) = v {
                let _ = sexp.set_elt(i, f64::from_bits(v as u64));
            } else {
                let _ = sexp.set_elt(i, f64::from_bits(i64::MIN as u64));
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

// Export Arrow Date32 as R's Integer instead of Double, this means `-2147483648` is converted to `NA_integer_`,
// but `-2147483648` is the day `-5877641-06-23`, so this may not be a problem.
pub(super) fn date32_export_impl(ca: &DateChunked, classes: &[&str]) -> OwnedIntegerSexp {
    let mut sexp = OwnedIntegerSexp::new(ca.len()).unwrap();
    let _ = sexp.set_class(classes);
    for (i, v) in ca.into_iter().enumerate() {
        if let Some(v) = v {
            let _ = sexp.set_elt(i, v);
        } else {
            let _ = sexp.set_na(i);
        }
    }
    sexp
}

impl From<Wrap<&DateChunked>> for Sexp {
    fn from(ca: Wrap<&DateChunked>) -> Self {
        date32_export_impl(ca.0, &["Date"]).into()
    }
}

impl From<Wrap<&DurationChunked>> for Sexp {
    fn from(ca: Wrap<&DurationChunked>) -> Self {
        let ca = ca.0;
        let time_unit = ca.time_unit();
        let div_value: f64 = match time_unit {
            TimeUnit::Nanoseconds => 1_000_000_000.0,
            TimeUnit::Microseconds => 1_000_000.0,
            TimeUnit::Milliseconds => 1_000.0,
        };
        let mut sexp = OwnedRealSexp::new(ca.len()).unwrap();
        let _ = sexp.set_class(["difftime"]);
        sexp
            .set_attrib("units", <OwnedStringSexp>::try_from("secs").unwrap().into())
            .unwrap();
        for (i, v) in ca.into_iter().enumerate() {
            if let Some(v) = v {
                let _ = sexp.set_elt(i, v as f64 / div_value);
            } else {
                let _ = sexp.set_na(i);
            }
        }
        sexp.into()
    }
}

impl From<Wrap<&DatetimeChunked>> for Sexp {
    fn from(ca: Wrap<&DatetimeChunked>) -> Self {
        let ca = ca.0;
        let time_unit = ca.time_unit();
        let div_value: f64 = match time_unit {
            TimeUnit::Nanoseconds => 1_000_000_000.0,
            TimeUnit::Microseconds => 1_000_000.0,
            TimeUnit::Milliseconds => 1_000.0,
        };
        let tzone_attr = ca.time_zone().as_deref().unwrap_or("");

        let mut sexp = OwnedRealSexp::new(ca.len()).unwrap();
        let _ = sexp.set_class(["POSIXct", "POSIXt"]);
        sexp
            .set_attrib(
                "tzone",
                <OwnedStringSexp>::try_from(tzone_attr).unwrap().into(),
            )
            .unwrap();
        for (i, v) in ca.into_iter().enumerate() {
            if let Some(v) = v {
                let _ = sexp.set_elt(i, v as f64 / div_value);
            } else {
                let _ = sexp.set_na(i);
            }
        }
        sexp.into()
    }
}

impl From<Wrap<&TimeChunked>> for Sexp {
    fn from(ca: Wrap<&TimeChunked>) -> Self {
        let ca = ca.0;
        let mut sexp = OwnedRealSexp::new(ca.len()).unwrap();
        let _ = sexp.set_class(["hms", "difftime"]);
        sexp
            .set_attrib("units", <OwnedStringSexp>::try_from("secs").unwrap().into())
            .unwrap();
        for (i, v) in ca.into_iter().enumerate() {
            if let Some(v) = v {
                let _ = sexp.set_elt(i, v as f64 / 1_000_000_000.0);
            } else {
                let _ = sexp.set_na(i);
            }
        }
        sexp.into()
    }
}
