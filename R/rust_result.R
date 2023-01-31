
#' check if z is a result
#' @param x R object which could be a rust-like result of a list with two elements, ok and err
#' @return bool if is a result object
is_result = function(x) {
  is.list(x) && identical(names(x), c("ok","err"))
}

guard_result = function(x) {
  if(!is_result(x)) stopf("internal error: cannot map_err a non result")
}

#' check if x ss a result and an err
#' @param x R object which could be a rust-like result of a list with two elements, ok and err
#' @return bool if is a result object which is an err
is_err = function(x) {
  guard_result(x)
  !is.null(x$err)
}

#' check if x ss a result and an ok
#' @param x R object which could be a rust-like result of a list with two elements, ok and err
#' @return bool if is a result object which is an ok
is_ok = function(x) {
  guard_result(x)
  is_result(x)  && is.null(x$err)
}

#' Wrap in Ok
#' @param x any R object
#' @return same R object wrapped in a Ok-result
Ok = function(x) {
  list(ok = x, err = NULL)
}

#' Wrap in Err
#' @param x any R object
#' @return same R object wrapped in a Err-result
Err = function(x) {
  list(ok = NULL, err = x)
}


#' map an Err part of Result
#' @param x any R object
#' @param f a closure that takes the err part as input
#' @return same R object wrapped in a Err-result
map_err = function(x, f) {
  guard_result(x)
  if(is_err(x)) x$err = f(x$err)
  x
}

#' map an Err part of Result
#' @param x any R object
#' @param f a closure that takes the ok part as input
#' @return same R object wrapped in a Err-result
map = function(x, f) {
  guard_result(x)
  if(is_ok(x)) x$ok = f(x$ok)
  x
}

#' rust-like unwrapping of result. Useful to keep error handling on the R side.
#'
#' @param result a list here either element ok or err is NULL, or both if ok is litteral NULL
#' @param call context of error or string
#'
#' @return the ok-element of list , or a error will be thrown
#' @export
#'
#' @examples
#'
#' unwrap(list(ok="foo",err=NULL))
#'
#' tryCatch(
#'   unwrap(ok=NULL, err = "something happen on the rust side"),
#'   error = function(e) as.character(e)
#' )
unwrap = function(result, call=sys.call(1L)) {

  #if not a result
  if(!is_result(result)) {
    stopf("Internal error: cannot unwrap non result")
  }

  #if result is ok (ok can be be valid null, hence OK if both ok and err is null)
  if(is.null(result$err)) {
    return(result$ok)
  }

  #if result is error, make a pretty with context
  #TODO err messages cannot contain %, they should be able to that
  # replace stopf here without dropping context err messages
  if(is.null(result$ok) && !is.null(result$err)) {
    stopf(
      paste(
        result$err,
        paste(
          "\nwhen calling:\n",
          paste(
            capture.output(print(call)),collapse="\n")
        )
    ))
  }

  #if not ok XOR error, then roll over
  stopf("Internal error: result object corrupted")
}


#' Internal preferred function to throw errors
#' @description DEPRECATED USE stopf instead
#' @param err error msg string
#' @param call calling context
#' @keywords internals
#'
#' @return throws an error
#'
#' @examples
#' f = function() rpolars:::pstop("this aint right!!")
#' tryCatch(f(), error = \(e) as.character(e))
pstop = function(err, call=sys.call(1L)) {
  unwrap(list(ok=NULL,err=err),call=call)
}
