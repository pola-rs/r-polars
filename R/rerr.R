

#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x RPolarsErr
#' @param pattern code-stump as string to auto-complete
#' @export
#' @keywords internal
.DollarNames.RPolarsErr = function(x, pattern = "") {
  get_method_usages(RPolarsErr, pattern = pattern)
}

#' @export
#' @noRd
as.character.RPolarsErr = function(x, ...) x$info()


#' @export
#' @noRd
print.RPolarsErr = function(x, ...) cat(x$info())


## RPolarsErr IPLEMENTS IPLEMENTS R-POLARS error_trait.R
when_calling.RPolarsErr = function(err, call) {
  err$when_last(paste("calling:", call_to_string(call)))
}
where_in.RPolarsErr = function(err, context) {
  err$wherein(context)
}
to_condition.RPolarsErr = function(err) {
  errorCondition(
    err$info(),
    class = c("Rerr_error"),
    value = err,
    call = NULL
  )
}
plain.RPolarsErr = function(err, msg) {
  err$value$plain(msg)
}
