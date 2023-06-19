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
  if (!is_result(x)) stopf("internal error: expected a Result-type %s", msg)
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
  if (is.null(x)) stopf("internal error in Err(x): x cannot be a NULL, not allowed")
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


#' rust-like unwrapping of result. Useful to keep error handling on the R side.
#'
#' @param result a list here either element ok or err is NULL, or both if ok is litteral NULL
#' @param call context of error or string
#' @param context a msg to prefix a raised error with
#'
#' @return the ok-element of list , or a error will be thrown
#' @keywords internal
#' @export
#'
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
  # if not a result
  if (!is_result(result)) {
    stopf("Internal error: cannot unwrap non result")
  }

  # if result is ok (ok can be be valid null, hence OK if both ok and err is null)
  if (is.null(result$err)) {
    return(result$ok)
  }

  # if result is error, make a pretty with context
  if (is.null(result$ok) && !is.null(result$err)) {
    if (!is.null(context)) {
      result$err = paste(context, result$err)
    }

    stop(
      paste(
        result$err,
        if (!polars_optenv$do_not_repeat_call) {
          paste(
            "\n when calling :\n",
            paste(capture.output(print(call)), collapse = "\n")
          )
        }
      ),
      domain = NA,
      call. = FALSE
    )
  }

  # if not ok XOR error, then roll over
  stopf("Internal error: result object corrupted")
}


#' Internal preferred function to throw errors
#' @description DEPRECATED USE stopf instead
#' @param err error msg string
#' @param call calling context
#' @keywords internal
#'
#' @return throws an error
#'
#' @examples
#' f = function() polars:::pstop("this aint right!!")
#' tryCatch(f(), error = \(e) as.character(e))
pstop = function(err, call = sys.call(1L)) {
  unwrap(list(ok = NULL, err = err), call = call)
}

# capture error in any R side arguments, and pass to rust side to preserve context and write
# really sweet error messages
result = function(x, msg = "an error because:\n") {
  tryCatch(
    Ok(x),
    error = function(err) {
      Err(paste0(msg, err$message))
    }
  )
}

# Alternative unwrap that keeps the Rerr
unwrap_rerr = function(result) {
  if (!is_result(result)) {
    stopf("Internal error: cannot unwrap non result")
  }
  if (polars:::is_ok(result)) return(result$ok)
  err = result$err
  cond = errorCondition(
    capture.output(print(err))
  )
  if(inherits(err, "Rerr")) {
    cond$Rerr = err
    class(cond) = c("Rerr_error", "error", "condition")
  }
  
  stop(cond)
}

# Alternative result that captures the Rerr from the alternative unwrap
result_rerr = function(expr) {
  tryCatch(
    polars:::Ok(expr),
    Rerr_error = function(err) {
      polars:::Err(err$Rerr)
    },
    error = function(err) {
      polars:::Err(err)
    }
  )
}