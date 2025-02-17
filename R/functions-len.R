#' Return the number of rows in the context$
#'
#' This is similar to `COUNT(*)` in SQL.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 2, NA),
#'   b = c(3, NA, NA),
#'   c = c("foo", "bar", "foo"),
#' )
#' df$select(pl$len())
#'
#' # Generate an index column by using len in conjunction with $int_range()
#' df$with_columns(
#'   pl$int_range(pl$len(), dtype = pl$UInt32)$alias("index")
#' )
pl__len <- function() {
  len() |>
    wrap()
}
