use crate::prelude::*;
use savvy::{OwnedIntegerSexp, OwnedListSexp, OwnedRealSexp, OwnedStringSexp, Sexp};

struct Float64Pair {
    pub left: OwnedRealSexp,
    pub right: OwnedRealSexp,
}

pub struct Duration {
    value: Float64Pair,
    precision: i32,
}

pub struct TimePoint {
    value: Float64Pair,
    precision: i32,
}

pub struct ZonedTime {
    pub time_point: TimePoint,
    pub zone: String,
}

// https://github.com/r-lib/vctrs/blob/c27b6988bd2f02aa970b6d14a640eccb299e03bb/src/type-integer64.c#L117-L156
impl From<&Int64Chunked> for Float64Pair {
    fn from(ca: &Int64Chunked) -> Self {
        let mut left = OwnedRealSexp::new(ca.len()).unwrap();
        let mut right = OwnedRealSexp::new(ca.len()).unwrap();
        for (i, v) in ca.into_iter().enumerate() {
            if let Some(v) = v {
                let x_u64 =
                    u64::from_ne_bytes(v.to_ne_bytes()).wrapping_add(9_223_372_036_854_775_808u64);
                let left_u32 = (x_u64 >> 32) as u32;
                let right_u32 = x_u64 as u32;
                let _ = left.set_elt(i, left_u32 as f64);
                let _ = right.set_elt(i, right_u32 as f64);
            } else {
                let _ = left.set_na(i);
                let _ = right.set_na(i);
            }
        }
        Float64Pair { left, right }
    }
}

impl From<&DurationChunked> for Duration {
    fn from(ca: &DurationChunked) -> Self {
        let ca_i64 = &ca.0;
        let value = Float64Pair::from(ca_i64);
        let precision: i32 = match ca.time_unit() {
            TimeUnit::Nanoseconds => 10,
            TimeUnit::Microseconds => 9,
            TimeUnit::Milliseconds => 8,
        };
        Duration { value, precision }
    }
}

impl From<&DatetimeChunked> for TimePoint {
    fn from(ca: &DatetimeChunked) -> Self {
        let ca_i64 = &ca.0;
        let value = Float64Pair::from(ca_i64);
        let precision: i32 = match ca.time_unit() {
            TimeUnit::Nanoseconds => 10,
            TimeUnit::Microseconds => 9,
            TimeUnit::Milliseconds => 8,
        };
        TimePoint { value, precision }
    }
}

// Export as clock_duration
impl From<Duration> for Sexp {
    fn from(d: Duration) -> Self {
        let mut sexp = OwnedListSexp::new(2, true).unwrap();
        let _ = sexp.set_class(["clock_duration", "clock_rcrd", "vctrs_rcrd", "vctrs_vctr"]);
        let _ = sexp.set_attrib(
            "precision",
            <OwnedIntegerSexp>::try_from_scalar(d.precision)
                .unwrap()
                .into(),
        );
        sexp.set_name_and_value(0, "lower", d.value.left).unwrap();
        sexp.set_name_and_value(1, "upper", d.value.right).unwrap();

        sexp.into()
    }
}

// Export as clock_naive_time
impl From<TimePoint> for Sexp {
    fn from(tp: TimePoint) -> Self {
        let mut sexp = OwnedListSexp::new(2, true).unwrap();
        let _ = sexp.set_class([
            "clock_naive_time",
            "clock_time_point",
            "clock_rcrd",
            "vctrs_rcrd",
            "vctrs_vctr",
        ]);
        let _ = sexp.set_attrib(
            "clock",
            <OwnedIntegerSexp>::try_from_scalar(1i32).unwrap().into(),
        );
        let _ = sexp.set_attrib(
            "precision",
            <OwnedIntegerSexp>::try_from_scalar(tp.precision)
                .unwrap()
                .into(),
        );
        sexp.set_name_and_value(0, "lower", tp.value.left).unwrap();
        sexp.set_name_and_value(1, "upper", tp.value.right).unwrap();

        sexp.into()
    }
}

impl From<ZonedTime> for Sexp {
    fn from(zt: ZonedTime) -> Self {
        let mut sexp = OwnedListSexp::new(2, true).unwrap();
        let _ = sexp.set_class(["clock_zoned_time", "clock_rcrd", "vctrs_rcrd", "vctrs_vctr"]);
        let _ = sexp.set_attrib(
            "precision",
            <OwnedIntegerSexp>::try_from_scalar(zt.time_point.precision)
                .unwrap()
                .into(),
        );
        let _ = sexp.set_attrib("zone", <OwnedStringSexp>::try_from(zt.zone).unwrap().into());
        sexp.set_name_and_value(0, "lower", zt.time_point.value.left)
            .unwrap();
        sexp.set_name_and_value(1, "upper", zt.time_point.value.right)
            .unwrap();

        sexp.into()
    }
}
