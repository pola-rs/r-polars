#' @export
print.polars_dtype <- function(x, ...) {
  format(x, abbreviated = FALSE) |>
    writeLines()
  invisible(x)
}

#' Format a data type
#'
#' @param x A [polars_dtype] object.
#' @param ... Ignored.
#' @param abbreviated `r lifecycle::badge("experimental")`
#'   A boolean. If `TRUE`, use the abbreviated form of the dtype name,
#'   e.g. "i64" instead of "Int64".
#' @examples
#' format(pl$Int64)
#' format(pl$Float64, abbreviated = TRUE)
#' @export
#' @keywords internal
format.polars_dtype <- function(x, ..., abbreviated = FALSE) {
  x$`_dt`$as_str(abbreviated = abbreviated)
}
