

#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x Rerr
#' @param pattern code-stump as string to auto-complete
#' @export
#' @keywords internal
.DollarNames.Rerr = function(x, pattern = "") {
  get_method_usages(Rerr, pattern = pattern)
}

#' @export
#' @noRd
as.character.Rerr = function(x, ...) x$info()


#' @export
#' @noRd
print.Rerr = function(x, ...) writeLines(x$info())


## Rerr IPLEMENTS IPLEMENTS R-POLARS error_trait.R
when_calling.Rerr = function(err, call) {
  err$when_last(paste("calling:", call_to_string(call)))
}
where_in.Rerr = function(err, context) {
  err$wherein(context)
}
to_condition.Rerr = function(err) {
  errorCondition(
    err$info(),
    class = c("Rerr_error"),
    value = err,
    call = NULL
  )
}
plain.Rerr = function(err, msg) {
  err$value$plain(msg)
}
