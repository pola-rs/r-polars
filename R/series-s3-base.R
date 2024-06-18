#' @export
print.polars_series <- function(x, ...) {
  x$`_s`$print()
  invisible(x)
}
