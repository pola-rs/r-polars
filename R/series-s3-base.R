#' @export
print.polars_series <- function(x, ...) {
  x$`_s`$print()
  invisible(x)
}

#' @export
as.vector.polars_series <- function(x, ...) {
  x$to_r_vector()
}
