#' @export
print.polars_data_type <- function(x, ...) {
  x$`_dt`$print()
  invisible(x)
}
