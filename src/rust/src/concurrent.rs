//use crate::rdataframe::rseries::ptr_str_to_rseries;
use crate::lazy::dataframe::LazyFrame;
use crate::rdataframe::DataFrame;
use crate::utils::extendr_concurrent::ParRObj;
use crate::utils::extendr_concurrent::{
    concurrent_handler, join_background_handler, start_background_handler, ThreadCom,
};
use crate::CONFIG;
use polars::prelude as pl;

use crate::rdataframe::Series;
use crate::rpolarserr::*;
use extendr_api::prelude::*;
use extendr_api::Conversions;
use std::result::Result;
use std::thread::JoinHandle;

// create the standard closure to serve R maps. This is how main thread which can do
// R calls should process a request from a polars thread worker to run an R function
fn make_closure_serve_r() -> impl Fn(
    (ParRObj, polars::prelude::Series),
) -> Result<polars::prelude::Series, Box<dyn std::error::Error>> {
    |(probj, s): (ParRObj, pl::Series)| -> Result<pl::Series, Box<dyn std::error::Error>> {
        //unpack user-R-function
        let f = probj.0.as_function().ok_or_else(|| {
            extendr_api::error::Error::Other(format!(
                "provided input is not an R function but a: {:?}",
                probj.0
            ))
        })?;

        // call user-R-function with Series as input, return Robj (likeliy as Series)
        let rseries_robj = f.call(pairlist!(Series(s)))?;

        // return of user-R-function may not be Series, return Err if so
        let s = Series::any_robj_to_pl_series_result(rseries_robj)?;

        Ok(s)
    }
}

// This functions allows to call .collect() on polars lazy frame. A lazy frame may contain user defined functions
// which could call R from any spawned thread by polars. This function is a bridge between multithraedded polars
// and mostly single threaded only R

//handle_thread_r_request() is a special case of the concurrent_handler()
//handle_thread_r_request passes 2 closures to concurrent_handler() + 1 closure to lazyframe
//1: What to run (polars collect), 2: what handler to execute code
//3: Expr.map or such, passes an R user defined function in a closure to the lazyframe. This closure describes
//how to request R functions run on the mainthread with a ThreadCom object.
pub fn collect_with_r_func_support(lazy_df: pl::LazyFrame) -> pl::PolarsResult<DataFrame> {
    let res_res_df = concurrent_handler(
        // Closure 1: start concurrent handler and get final result
        // This what we want to do in the first place ... to run LazyFrame.collect() thread-safe
        //this closure gets spawned in a child of main thred, tc is a ThreadCom struct
        move |tc| {
            //start polars .collect, which it self can spawn many new threads
            let retval = lazy_df.collect();
            //collect done, we're all done know

            //drop local and global ThreadCom clone, signals to main/R-serving thread to shut down.
            ThreadCom::kill_global(&CONFIG);
            drop(tc);

            //taadaaa return value
            retval
        },
        //closure 2
        //how should the R-serving mainthread handle a user function requst?
        //synopsis: run the user-R-function, input/ouput is a Series
        make_closure_serve_r(),
        //CONFIG is "global variable" where threads can request a new ThreadCom
        &CONFIG,
    );
    //concurrent handling complete

    //bubble on concurrent errors
    let res_df = res_res_df.map_err(|err| {
        pl::polars_err!(
            ComputeError: "error via polars concurrent R handler {:?}", err,
        )
    })?;

    //bubble polars errors
    let new_df = res_df?;

    //wrap ok
    Ok(DataFrame(new_df))
}

pub fn profile_with_r_func_support(
    lazy_df: pl::LazyFrame,
) -> RResult<(pl::DataFrame, pl::DataFrame)> {
    let res_res_df: Result<
        Result<(pl::DataFrame, pl::DataFrame), pl::PolarsError>,
        Box<dyn std::error::Error>,
    > = concurrent_handler(
        move |tc| {
            let retval = lazy_df.profile();
            ThreadCom::kill_global(&CONFIG);
            drop(tc);
            retval
        },
        make_closure_serve_r(),
        &CONFIG,
    );

    res_res_df
        .map_err(|err| RPolarsErr::new().plain(err.to_string()))?
        .map_err(polars_to_rpolars_err)
}

#[derive(Debug, Default)]
pub struct PolarsBackgroundHandle(Option<JoinHandle<pl::PolarsResult<pl::DataFrame>>>);

#[extendr]
impl PolarsBackgroundHandle {
    pub fn new(lazy_df: &LazyFrame) -> Self {
        let lazy_df = lazy_df.0.clone();
        let join_handle = start_background_handler(move || lazy_df.collect());
        PolarsBackgroundHandle(Some(join_handle))
        //concurrent handling complete
    }

    pub fn join(&mut self) -> Result<DataFrame, String> {
        //take handle from Robj, replace with default None
        let handle = std::mem::take(self)
            .0
            .ok_or("join error: Handle was already exhausted")?;

        let x = join_background_handler(handle);
        x.map_err(|err| {
            format!(
                "thread error when joining polars background process: {}",
                err
            )
        })?
        .map(DataFrame)
        .map_err(|err| format!("polars query error : {}", err))
    }

    pub fn is_exhausted(&self) -> bool {
        self.0.is_none()
    }
}

extendr_module! {
    mod concurrent;
    impl PolarsBackgroundHandle;
}
