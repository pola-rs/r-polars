//use crate::rdataframe::rseries::ptr_str_to_rseries;
use crate::rdataframe::RPolarsDataFrame;
use crate::utils::extendr_concurrent::ParRObj;
use crate::utils::extendr_concurrent::{concurrent_handler, ThreadCom};
use crate::CONFIG;
use polars::prelude as pl;

use crate::rdataframe::RPolarsSeries;
use crate::rpolarserr::*;
use extendr_api::prelude::*;
use std::result::Result;

// define any possible signature of R lambdas
#[derive(Debug)]
pub enum RFnSignature {
    //... read as function with input 1 Series mapped to output 1 Series
    FnSeriesToSeries(ParRObj, pl::Series),
    FnTwoSeriesToSeries(ParRObj, pl::Series, pl::Series),
    FnF64ToString(ParRObj, f64),
}

//any possible output from an R lambda
#[derive(Debug)]
pub enum RFnOutput {
    Series(pl::Series),
    String(String),
}

impl RFnSignature {
    // main thread serving R call should just eval any variant of RFnSignature
    pub fn eval(self) -> Result<RFnOutput, Box<dyn std::error::Error>> {
        let unpack_rfn = |f: ParRObj| -> extendr_api::Result<extendr_api::Function> {
            f.0.as_function().ok_or_else(|| {
                extendr_api::error::Error::Other(format!(
                    "provided input is not an R function but a: {:?}",
                    f.0
                ))
            })
        };

        match self {
            RFnSignature::FnSeriesToSeries(f, s) => {
                let s = unpack_rfn(f)?
                    .call(pairlist!(RPolarsSeries(s)))
                    .map(RPolarsSeries::any_robj_to_pl_series_result)??;
                Ok(RFnOutput::Series(s))
            }
            RFnSignature::FnTwoSeriesToSeries(f, s1, s2) => {
                let s = unpack_rfn(f)?
                    .call(pairlist!(RPolarsSeries(s1), RPolarsSeries(s2)))
                    .map(RPolarsSeries::any_robj_to_pl_series_result)??;
                Ok(RFnOutput::Series(s))
            }
            RFnSignature::FnF64ToString(f, f64_val) => {
                let s = unpack_rfn(f)?
                    .call(pairlist!(f64_val))?
                    .as_str()
                    .ok_or("wrong return value, expected a string")?;
                Ok(RFnOutput::String(s.to_string()))
            }
        }
    }
}

impl RFnOutput {
    // main thread serving R call should just eval any variant of RFnSignature
    pub fn unwrap_series(self) -> pl::Series {
        match self {
            RFnOutput::Series(out) => out,
            _ => panic!("internal error unexpected type of returned answer"),
        }
    }

    pub fn unwrap_string(self) -> String {
        match self {
            RFnOutput::String(out) => out,
            _ => panic!("internal error unexpected type of returned answer"),
        }
    }
}

// This is the standard way the main thread which can call the R session,
// should process a request from a polars thread worker to run an R function
fn serve_r(rfsig: RFnSignature) -> Result<RFnOutput, Box<dyn std::error::Error>> {
    rfsig.eval()
}

// This functions allows to call .collect() on polars lazy frame. A lazy frame may contain user defined functions
// which could call R from any spawned thread by polars. This function is a bridge between multithraedded polars
// and mostly single threaded only R
pub fn collect_with_r_func_support(lazy_df: pl::LazyFrame) -> RResult<RPolarsDataFrame> {
    let new_df = if ThreadCom::try_from_global(&CONFIG).is_ok() {
        #[cfg(feature = "rpolars_debug_print")]
        println!("in collect:  concurrent handler already started");
        lazy_df.collect().map_err(polars_to_rpolars_err)
    } else {
        #[cfg(feature = "rpolars_debug_print")]
        println!("in collect: starting a concurrent handler");

        #[cfg(feature = "rpolars_debug_print")]
        println!("in collect: concurrent handler done");
        concurrent_handler(
            // closure 1: spawned by main thread
            // tc is a ThreadCom which any child thread can use to submit R jobs to main thread
            move |tc| {
                // get return value
                let retval = lazy_df.collect();

                // drop the last two ThreadCom clones, signals to main/R-serving thread to shut down.
                ThreadCom::kill_global(&CONFIG);
                drop(tc);

                retval
            },
            // closure 2: how to serve polars worker R job request in main thread
            serve_r,
            //CONFIG is "global variable" where any new thread can request a clone of ThreadCom to establish contact with main thread
            &CONFIG,
        )
        .map_err(|err| RPolarsErr::new().plain(err.to_string()))?
        .map_err(polars_to_rpolars_err)
    };

    //wrap ok
    Ok(RPolarsDataFrame(new_df?))
}

pub fn profile_with_r_func_support(
    lazy_df: pl::LazyFrame,
) -> RResult<(RPolarsDataFrame, RPolarsDataFrame)> {
    if ThreadCom::try_from_global(&CONFIG).is_ok() {
        lazy_df.profile()
    } else {
        concurrent_handler(
            move |tc| {
                let retval = lazy_df.profile();
                ThreadCom::kill_global(&CONFIG);
                drop(tc);
                retval
            },
            serve_r,
            &CONFIG,
        )
        .map_err(|err| RPolarsErr::new().plain(err.to_string()))?
    }
    .map_err(polars_to_rpolars_err)
    .map(|(result_df, profile_df)| (RPolarsDataFrame(result_df), RPolarsDataFrame(profile_df)))
}

pub fn fetch_with_r_func_support(
    lazy_df: pl::LazyFrame,
    n_rows: usize,
) -> RResult<RPolarsDataFrame> {
    if ThreadCom::try_from_global(&CONFIG).is_ok() {
        lazy_df.fetch(n_rows)
    } else {
        concurrent_handler(
            move |tc| {
                let retval = lazy_df.fetch(n_rows);
                ThreadCom::kill_global(&CONFIG);
                drop(tc);
                retval
            },
            serve_r,
            &CONFIG,
        )
        .map_err(|err| RPolarsErr::new().plain(err.to_string()))?
    }
    .map_err(polars_to_rpolars_err)
    .map(RPolarsDataFrame)
}
