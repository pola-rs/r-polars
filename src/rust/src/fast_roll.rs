use crate::robj_to;
use crate::rpolarserr::{polars_to_rpolars_err, RResult};
use crate::series::Series;
use extendr_api::prelude::*;
use pl::IntoSeries;
use polars::prelude as pl;
use polars::prelude::ChunkedCollectInferIterExt;
use polars_core::utils::CustomIterTools;

// functions to aggregate over windows
#[inline(always)]
fn window_agg_mean<T>(rsum: T, width_t: T) -> T
where
    T: std::ops::Div<Output = T>,
{
    rsum / width_t
}

#[inline(always)]
fn window_agg_sum<T>(rsum: T, _: T) -> T
where
    T: std::ops::Div<Output = T>,
{
    rsum
}

// macro to roll any type and agg_funciton
#[macro_export]
macro_rules! fastroll {
    ($agg_fun:expr, $type:ty, $chunked_f:ident, $chunked_type:ident, $s_in:expr, $width:expr) => {
        (|| -> RResult<Series> {
            let s = $s_in;
            let s = robj_to!(Series, s)?;
            let width = $width;
            let width = robj_to!(usize, width)?;
            let width_t = width as $type;

            let ca = s.0.$chunked_f().map_err(polars_to_rpolars_err)?;
            let ca_cloned = ca.clone();
            let mut ca_iter_front = ca.into_iter();
            let mut ca_iter_back = ca_cloned.into_iter();
            let mut rsum = <$type>::default(); // the window sum
            let mut ncount: u64 = 0; // the window null count
            let burn_in = width - 1; // remaining values to fill up window first time

            // fill up window first
            for _i in 0..burn_in {
                match ca_iter_front.next() {
                    None => (),
                    Some(None) => ncount += 1,
                    Some(Some(value)) => rsum += value,
                };
            }

            let window_value_iter = ca_iter_front.map(|front_value| {
                // 1 add front value into window
                match front_value {
                    None => ncount += 1,
                    Some(value) => rsum += value,
                };

                // 2 compute window value
                let window_value = match ncount {
                    0 => Some($agg_fun(rsum, width_t)),
                    _ => None, // window contains one or more Nulls
                };

                // 3 drop back value from window
                match ca_iter_back
                    .next()
                    .expect("iter_back cannot be depleted before front")
                {
                    None => ncount -= 1,
                    Some(value) => rsum -= value,
                };

                window_value
            });

            // SAFETY: new trusted length is always correct.
            let window_value_iter =
                unsafe { window_value_iter.trust_my_length(s.len() as usize - burn_in as usize) };

            // pad first burn_in elements as missing
            let padded_window_value_iter = std::iter::repeat(None)
                .take(burn_in)
                .chain(window_value_iter);

            let ca_out: pl::ChunkedArray<pl::$chunked_type> =
                padded_window_value_iter.collect_ca_trusted("roll!");

            Ok(Series(ca_out.into_series()))
        })()
    };
}

#[extendr]
fn fast_roll_sum_f64(s: Robj, width: Robj) -> RResult<Series> {
    fastroll!(window_agg_sum, f64, f64, Float64Type, s, width)
}
#[extendr]
fn fast_roll_mean_f64(s: Robj, width: Robj) -> RResult<Series> {
    fastroll!(window_agg_mean, f64, f64, Float64Type, s, width)
}

#[extendr]
fn fast_roll_mean_f32(s: Robj, width: Robj) -> RResult<Series> {
    fastroll!(window_agg_mean, f64, f64, Float64Type, s, width)
}

#[extendr]
fn fast_roll_sum_i64(s: Robj, width: Robj) -> RResult<Series> {
    fastroll!(window_agg_sum, i64, i64, Int64Type, s, width)
}

#[extendr]
fn fast_roll_mean_i64(s: Robj, width: Robj) -> RResult<Series> {
    fastroll!(window_agg_mean, i64, i64, Int64Type, s, width)
}

#[extendr]
fn fast_roll_mean_i32(s: Robj, width: Robj) -> RResult<Series> {
    fastroll!(window_agg_mean, i32, i32, Int32Type, s, width)
}

#[extendr]
fn fast_roll_mean_f64_non_macro(s: Robj, width: Robj) -> RResult<Series> {
    let s = robj_to!(Series, s)?;
    let width = robj_to!(usize, width)?;
    let width_t = width as f64;

    let ca = s.0.f64().map_err(polars_to_rpolars_err)?;
    let ca_cloned = ca.clone();

    let mut ca_iter_front = ca.into_iter();
    let mut ca_iter_back = ca_cloned.into_iter();
    let mut rsum: f64 = 0.0; // the window sum
    let mut ncount: u64 = 0; // the window null count
    let burn_in = width - 1; // remaining values to fill up window first time

    //rprintln!("\n size hint iterator {:?}", ca_iter_front.size_hint());

    for _i in 0..burn_in {
        //rprintln!("\n burn-in {}", _i);
        match ca_iter_front.next() {
            None => (),
            Some(None) => ncount += 1,
            Some(Some(value)) => rsum += value,
        };
    }

    //rprintln!("\n size hint iterator {:?}", ca_iter_front.size_hint());

    use polars::prelude::ChunkedCollectInferIterExt;
    let window_value_iter = ca_iter_front.map(|front_value| {
        //rprintln!("\n front-value {:?}", front_value);
        // 1 add front value into window
        match front_value {
            None => ncount += 1,
            Some(value) => rsum += value,
        };

        // 2 compute window value
        let window_value = match ncount {
            0 => Some(rsum / width_t),
            _ => None, // window contains one or more Nulls
        };
        //rprintln!("window-value {:?}", window_value);

        // 3 drop back value from window

        //rprintln!("back-value {:?}", back_value);
        match ca_iter_back
            .next()
            // well maybe if width =1 ,check for that
            .expect("iter_back cannot be depleted before front ")
        {
            None => ncount -= 1,
            Some(value) => rsum -= value,
        };

        window_value
    });
    use polars_core::utils::CustomIterTools;
    let window_value_iter =
        unsafe { window_value_iter.trust_my_length(s.len() as usize - burn_in as usize) };

    //rprintln!("\n size hint iterator {:?}", window_value_iter.size_hint());

    let padded_window_value_iter = std::iter::repeat(None)
        .take(burn_in)
        .chain(window_value_iter);

    let ca_out: pl::ChunkedArray<pl::Float64Type> =
        padded_window_value_iter.collect_ca_trusted("roll!");

    Ok(Series(ca_out.into_series()))
}

extendr_module! {
    mod fast_roll;

    fn fast_roll_sum_f64;
    fn fast_roll_mean_f64;
    fn fast_roll_mean_f32;
    fn fast_roll_sum_i64;
    fn fast_roll_mean_i64;
    fn fast_roll_mean_i32;
    fn fast_roll_mean_f64_non_macro;
}
