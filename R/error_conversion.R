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


#'  catches any R error and return a rust-Result
#' @param expr code to capture any error from and wrap as Result
#' @param msg easy way to add a context msg
#' @keywords internal
#' @return Result
result = function(expr, msg = NULL) {
  tryCatch(
    Ok(expr),
    error = function(cond) {
      cond$value %||%
        cond$message |>
        plain(msg) |>
        Err()
    }
  )
}
