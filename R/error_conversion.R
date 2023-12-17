# THIS FILE IMPLEMENTS ERROR CONVERSION, FOR R TO Result-list & FOR Result-list TO R


#' unwrap
#' @description rust-like unwrapping of result. Useful to keep error handling on the R side.
#' @noRd
#' @param result a list here either element ok or err is NULL, or both if ok is litteral NULL
#' @param call context of error or string
#' @param context a msg to prefix a raised error with
#'
#' @details
#' unwraps any ok value and raises any err values
#' when raising error value, the error will be called with methods where_in() a simple lexical
#' context and when_calling() to add the call context and finally to_condition() to convert any
#' error into an R error condition. These s3 methods can be implemented for any future error type.
#'
#' @return the ok-element of list , or a error will be thrown
#' @noRd
#' @examples
#'
#' # fetch internal unwrap-function
#' unwrap = .pr$env$unwrap
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
  if (is_ok(result)) {
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
#' @noRd
#' @details
#' throwed error info is sparse because only for internal errors
#' @noRd
#' @param result a Result, see rust_result.R#'
#' @return some error type
unwrap_err = function(result) {
  if (is_ok(result)) {
    stop("internal error: Cannot unwrap_err an Ok-value")
  } else {
    result$err
  }
}


#' Capture any R error and return a rust-like Result
#' @noRd
#' @param expr code to capture any error from and wrap as Result
#' @param msg handy way to add a context msg
#' @noRd
#' @return Result
#' @examples
#'
#' # get user internal functions
#' result = .pr$env$result
#' unwrap_err = .pr$env$unwrap_err
#' unwrap = .pr$env$unwrap
#' Err = .pr$env$Err
#'
#' # capture regular R errors or RPolarsErr
#' throw_simpleError = \() stop("Imma simple error")
#' result(throw_simpleError())
#'
#' throw_RPolarsErr = \() unwrap(
#'   Err(.pr$Err$new()$bad_robj(42)$mistyped("String")$when("doing something"))
#' )
#' res_RPolarsErr = result(throw_RPolarsErr())
#' str(res_RPolarsErr)
#' RPolarsErr = unwrap_err(res_RPolarsErr)
#' RPolarsErr$contexts()
result = function(expr, msg = NULL) {
  tryCatch(
    Ok(expr),
    error = \(cond) {
      cond$value %||% cond$message |>
        upgrade_err() |>
        plain(msg) |>
        Err()
    }
  )
}


#' Capture any R error and return a rust-like Result (Minimal)
#' @description use sparingly internally for speed optimization where the error is not important.
#' @noRd
#' @param expr code to capture any error from and wrap as Result
#' @noRd
#' @return Result
#' @examples
#' # get user internal functions
#' result = .pr$env$result
#' unwrap_err = .pr$env$unwrap_err
#' unwrap = .pr$env$unwrap
#' Err = .pr$env$Err
#'
#' # capture regular R errors or RPolarsErr
#' throw_simpleError = \() stop("Imma simple error")
#' result_minimal(throw_simpleError())
result_minimal = function(expr) {
  tryCatch(
    Ok(expr),
    error = \(cond) Err(cond$value %||% cond$message)
  )
}


raw_result = function(expr) {
  tryCatch(
    Ok(expr),
    error = \(cond) {
      cond$value %||% cond$message |>
        Err()
    }
  )
}
