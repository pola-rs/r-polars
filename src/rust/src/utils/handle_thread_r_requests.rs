pub fn handle_thread_r_requests(
    self_df: DataFrame,
    exprs: Vec<pl::Expr>,
) -> std::result::Result<DataFrame, Box<dyn std::error::Error>> {
    let res_res_df = concurrent_handler(
        //call this polars code
        move |tc| {
            //use polars and R functions concurrently
            let retval = self_df.0.lazy().select(exprs).collect();

            //drop global ThreadCom clone
            ThreadCom::kill_global(&CONFIG);

            //local threadcom will also be dropped (likely the last tc, unless some polars thread crashed)
            drop(tc);

            //no more tc's, main thread should wake up now by recieving a Disconnect error signal

            //tada return value
            retval
        },
        //out of hot loop call this R code, just retrieve high-level function wrapper from package
        || extendr_api::eval_string("minipolars:::Series_udf_handler").unwrap(),
        //pass any concurrent 'lambda' call from polars to R via main thread
        |(probj, s): (ParRObj, pl::Series), robj: Robj| -> Result<pl::Series, extendr_api::Error> {
            let opt_f = probj.0.as_function().ok_or_else(|| {
                extendr_api::error::Error::Other(format!("this is not a function: {:?}", probj.0))
            }); //user defined function

            let f = opt_f?;

            let series_udf_handler = robj.as_function().ok_or_else(|| {
                extendr_api::error::Error::Other("this is not a function".to_string())
            })?;

            let rseries_ptr = series_udf_handler.call(pairlist!(f = f, rs = Series(s)))?;

            let rseries_ptr_str = rseries_ptr.as_str().ok_or_else(|| {
                extendr_api::error::Error::Other(format!(
                    "failed to run user function because: {:?}",
                    rseries_ptr
                ))
            })?;

            //safety relies on private minipolars:::series_udf_handler only passes Series pointers.
            let x = unsafe {
                let x: &mut Series = strpointer_to_(rseries_ptr_str)?;
                x
            };

            //try into cast robj into point to expected type

            //unwrap to series
            let s = x.clone().0;

            Ok(s)
        },
        &CONFIG,
    );

    let res_df = res_res_df?;

    let new_df = res_df.map_err(|err| err.to_string())?;
    Ok(DataFrame(new_df))
}
