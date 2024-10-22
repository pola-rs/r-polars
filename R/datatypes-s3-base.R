#' @export
print.polars_dtype <- function(x, ...) {
  x$`_dt`$print()
  invisible(x)
}
