#' check if z is a result
#' @param x R object which could be a rust-like result of a list with two elements, ok and err
#' @details both ok and err being NULL encodes ok-value NULL. No way to encode an err-value NULL
#' If both ok and err has value then this is an invalid result
#' @keywords internal
#' @return bool if is a result object
is_result = function(x) {
  identical(class(x), "extendr_result")
  # is.list(x) && identical(names(x), c("ok","err")) && (is.null(x[[1L]]) || is.null(x[[2L]]))
}

guard_result = function(x, msg = "") {
  if (!is_result(x)) stop("internal error: expected a Result-type %s", msg)
  invisible(x)
}

#' check if x ss a result and an err
#' @param x R object which could be a rust-like result of a list with two elements, ok and err
#' @return bool if is a result object which is an err
#' @keywords internal
is_err = function(x) {
  guard_result(x)
  !is.null(x$err)
}

#' check if x ss a result and an ok
#' @param x R object which could be a rust-like result of a list with two elements, ok and err
#' @return bool if is a result object which is an ok
#' @keywords internal
is_ok = function(x) {
  guard_result(x)
  is.null(x$err)
}

#' Wrap in Ok
#' @param x any R object
#' @return same R object wrapped in a Ok-result
#' @keywords internal
Ok = function(x) {
  structure(list(ok = x, err = NULL), class = "extendr_result")
}

#' Wrap in Err
#' @param x any R object
#' @keywords internal
#' @return same R object wrapped in a Err-result
Err = function(x) {
  if (is.null(x)) stop("internal error in Err(x): x cannot be a NULL, not allowed")
  structure(list(ok = NULL, err = x), class = "extendr_result")
}


#' map an Err part of Result
#' @keywords internal
#' @param x any R object
#' @param f a closure that takes the err part as input
#' @return same R object wrapped in a Err-result
map_err = function(x, f) {
  if (is_err(x)) x$err <- f(x$err)
  x
}

#' map an Err part of Result
#' @param x any R object
#' @param f a closure that takes the ok part as input
#' @return same R object wrapped in a Err-result
#' @noRd
map = function(x, f) {
  if (is_ok(x)) x$ok <- f(x$ok)
  x
}

#' map an ok-value or pass on an err-value
#' @param x any R object
#' @param f a closure that takes the ok part as input
#' @return same R object wrapped in a Err-result
#' @keywords internal
and_then = function(x, f) {
  if (is_err(x)) {
    return(x)
  }
  guard_result(f(x$ok), msg = "in and_then(x, f): f must return a result")
}

#' map an Err part of Result
#' @param x any R object
#' @keywords internal
#' @param f a closure that takes the ok part as input, must return a result itself
#' @return same R object wrapped in a Err-result
or_else = function(x, f) {
  guard_result(x)
  if (is_ok(x)) {
    return(x)
  }
  guard_result(f(x$err), msg = "in or_else(x, f): f must return a result")
}


#' unwrap return or if err
#' @param x any R object
#' @keywords internal
#' @param or any R value
#' @return pl
unwrap_or = function(x, or) {
  guard_result(x)
  if (is_ok(x)) {
    x$ok
  } else {
    or
  }
}


#' pstop
#' @noRd
#' @description DEPRECATED USE stopf instead
#' @param err error msg string
#' @param call calling context
#' @keywords internal
#'
#' @return throws an error
#'
#' @examples
#' f = function() .pr$env$pstop("this aint right!!")
#' tryCatch(f(), error = \(e) as.character(e))
pstop = function(err, call = sys.call(1L)) {
  unwrap(list(ok = NULL, err = err), call = call)
}
