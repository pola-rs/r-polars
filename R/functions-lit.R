# TODO: inherit params from cast
# TODO: link to data type page
#' Return an expression representing a literal value
#'
#' This function is a shorthand for [`as_polars_expr(x, as_lit = TRUE)`][as_polars_expr] and
#' in most cases, the actual conversion is done by [as_polars_series()].
#' @inherit as_polars_expr return
#' @param value An R object. Passed as the `x` param of [as_polars_expr()].
#' @param dtype A polars data type or `NULL` (default).
#' If not `NULL`, casted to the specified data type.
#' @seealso
#' - [as_polars_series()]: R -> Polars type mapping is mostly defined by this function.
#' - [as_polars_expr()]: Internal implementation of `pl$lit()`.
#' @examples
#' # Literal scalar values
#' pl$lit(1L)
#' pl$lit(5.5)
#' pl$lit(NULL)
#' pl$lit("foo_bar")
#'
#' ## Generally, for a vector (an R object) becomes a Series with length 1,
#' ## it is converted to a Series and then get the first value to become a scalar literal.
#' pl$lit(as.Date("2021-01-20"))
#' pl$lit(as.POSIXct("2023-03-31 10:30:45"))
#' pl$lit(data.frame(a = 1, b = "foo"))
#'
#' # Literal Series data
#' pl$lit(1:3)
#' pl$lit(pl$Series("x", 1:3))
pl__lit <- function(value, dtype = NULL) {
  if (is.null(dtype)) {
    as_polars_expr(value, as_lit = TRUE)
  } else {
    as_polars_expr(value, as_lit = TRUE)$cast(dtype)
  }
}
