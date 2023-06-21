#THIS FILE IMPLEMENTS ERROR CONVERSION, FOR R TO Result-list & FOR Result-list TO R

# TODO unwrap should be eventually renamed to unwrap_with_context (or similar)
# a simpler unwrap without where_in and when_calling should be defined in rust_result.R

#' rust-like unwrapping of result. Useful to keep error handling on the R side.
#'
#' @param result a list here either element ok or err is NULL, or both if ok is litteral NULL
#' @param call context of error or string
#' @param context a msg to prefix a raised error with
#'
#' @return the ok-element of list , or a error will be thrown
#' @keywords internal
#' @examples
#'
#' #get unwrap without using :::
#' unwrap = environment(polars::pl$all)$unwrap
#'
#' structure(list(ok = "foo", err = NULL), class = "extendr_result")
#'
#' tryCatch(
#'   unwrap(
#'     structure(
#'       list(ok = NULL, err = "something happen on the rust side"),
#'       class = "extendr_result"
#'     )
#'   ),
#'   error = function(err) as.character(err)
#' )
unwrap = function(result, context = NULL, call = sys.call(1L)) {
  if(is_ok(result)) {
    result$ok
  } else {
    result$err |>
      where_in(context) |>
      when_calling(call) |>
      to_condition() |>
      stop()
  }
}

#' rust-like unwrap_err, internal use only
#' @details
#' throwed error info is sparse because only for internal errors
#' @keywords internal
#' @param result a Result, see rust_result.R#'
#' @return some error type
unwrap_err = function(result) {
  if(is_ok(result)) {
    stop("internal error: Cannot unwrap_err an Ok-value")
  } else {
    result$err
  }
}


#' Capture any R error and return a rust-like Result
#' @param expr code to capture any error from and wrap as Result
#' @param msg handy way to add a context msg
#' @keywords internal
#' @return Result
#' @examples
#'
#'  #user internal functions without using :::
#'  result = environment(polars::pl$all)$result
#'  unwrap_err = environment(polars::pl$all)$unwrap_err
#'  unwrap = environment(polars::pl$all)$unwrap
#'  Err = environment(polars::pl$all)$Err
#'
#'  #capture regular R errors or RPolarsErr
#'  throw_simpleError  = \() stop("Imma simple error")
#'  result(throw_simpleError())
#'
#'  throw_RPolarsErr = \() unwrap(
#'   Err(.pr$RPolarsErr$new()$bad_robj(42)$mistyped("String")$when("doing something"))
#'  )
#'  res_RPolarsErr = result(throw_RPolarsErr())
#'  str(res_RPolarsErr)
#'  RPolarsErr = unwrap_err(res_RPolarsErr)
#'  RPolarsErr$contexts()
result = function(expr, msg = NULL) {
  tryCatch(
    Ok(expr),
    error = \(cond) cond$value %||% cond$message |> plain(msg) |> Err()
  )
}
