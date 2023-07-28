#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x RPolarsErr
#' @param pattern code-stump as string to auto-complete
#' @return char vec
#' @export
#' @inherit .DollarNames.DataFrame return
#' @keywords internal
.DollarNames.RPolarsErr = function(x, pattern = "") {
  get_method_usages(RPolarsErr, pattern = pattern)
}

#' @export
#' @noRd
as.character.RPolarsErr = function(x, ...) x$pretty_msg()


#' @export
#' @noRd
print.RPolarsErr = function(x, ...) cat(x$pretty_msg())


## RPolarsErr IPLEMENTS IPLEMENTS R-POLARS error_trait.R
when_calling.RPolarsErr = function(err, call) {
  err$rcall(call_to_string(call))
}
where_in.RPolarsErr = function(err, context) {
  err$rinfo(context)
}
to_condition.RPolarsErr = function(err) {
  errorCondition(
    err$pretty_msg(),
    class = c("RPolarsErr_error"),
    value = err,
    call = NULL
  )
}
plain.RPolarsErr = function(err, msg) {
  err$plain(msg)
}

upgrade_err.RPolarsErr = function(err) { # already RPolarsErr pass through
  err
}




#### ---- rpolarserr utils

# short hand  for starting new error with a bad robj input
bad_robj = function(r) {
  .pr$RPolarsErr$new()$bad_robj(r)
}
