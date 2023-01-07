//use crate::rdataframe::rseries::ptr_str_to_rseries;
use crate::rdataframe::DataFrame;
use crate::utils::extendr_concurrent::ParRObj;
use crate::utils::extendr_concurrent::{concurrent_handler, ThreadCom};
use crate::CONFIG;
use polars::prelude as pl;

use crate::rdataframe::Series;
use extendr_api::prelude::*;
use extendr_api::Conversions;
use std::result::Result;

// This functions allows to call .collect() on polars lazy frame. A lazy frame may contain user defined functions
// which could call R from any spawned thread by polars. This function is a bridge between multithraedded polars
// and mostly single threaded only R

//handle_thread_r_request() is a special case of the concurrent_handler()
//handle_thread_r_request passes 3 closures to concurrent_handler() + 1 closure to lazyframe
//1: What to run (polars collect), 2: what wrapper function to use, 3: what handler to execute code
//4: Expr.map or such, passes an R user defined function in a closure to the lazyframe. This closure describes
//how to request R functions run on the mainthread with a ThreadCom object.

pub fn handle_thread_r_requests(lazy_df: pl::LazyFrame) -> pl::PolarsResult<DataFrame> {
    //Closure 1: start concurrent handler and get final result
    let res_res_df = concurrent_handler(
        //give a closure doing what want if we could ... to run LazyFrame.collect() safely
        move |tc| {
            //start collect
            let retval = lazy_df.collect();
            //collect done, we're all done know

            //drop local and global ThreadCom clone, signals to R serving thread to shut down.
            ThreadCom::kill_global(&CONFIG);
            drop(tc);

            //taadaaa return value
            retval
        },
        //closure 2:
        //out of hot loop call this R code, just retrieve high-level function wrapper from package
        //This wrapper Series_udf_handler only sends a valid series pointer

        //closure 3
        //how should the R serving mainthread handle a user function requst?
        //spoiler alert:: run the function, return the answer.
        |(probj, s): (ParRObj, pl::Series)| -> Result<pl::Series, Box<dyn std::error::Error>> {
            //
            //get user defined function
            let f = probj.0.as_function().ok_or_else(|| {
                extendr_api::error::Error::Other(format!(
                    "provided input is not an R function but a: {:?}",
                    probj.0
                ))
            })?;

            //run call udf with Series as input, return Robj (likeliy as Series)
            let rseries_robj = f.call(pairlist!(Series(s)))?;

            //return may not
            let s = Series::any_robj_to_pl_series_result(&rseries_robj);
            Ok(s?)
        },
        &CONFIG,
    );

    //bubble on concurrent errors
    let res_df = res_res_df.map_err(|err| {
        pl::PolarsError::ComputeError(polars::error::ErrString::Owned(format!(
            "error via rpolars concurrent handler {:?}",
            err
        )))
    })?;

    //bubble polars errors
    let new_df = res_df?;

    //wrap ok
    Ok(DataFrame(new_df))
}
