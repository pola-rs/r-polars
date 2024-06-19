#' @export
print.polars_expr <- function(x, ...) {
  x$`_rexpr`$print()
  invisible(x)
}
