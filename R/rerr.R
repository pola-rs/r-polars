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
as.character.Rerr = function(x) x$info()

#' @export
#' @noRd
print.Rerr = function(x) writeLines(x$info())
