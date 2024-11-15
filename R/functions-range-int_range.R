#' Generate a range of integers
#'
#' @inheritParams rlang::args_dots_empty
#' @param start Start of the range (inclusive). Defaults to 0.
#' @param end End of the range (exclusive). If `NULL` (default), the value
#' of `start` is used and `start` is set to 0.
#' @param step Step size of the range.
#' @param dtype Data type of the range.
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$select(int = pl$int_range(0, 3))
#'
#' # end can be omitted for a shorter syntax.
#' pl$select(int = pl$int_range(3))
#'
#' # Generate an index column by using int_range in conjunction with len().
#' df <- pl$DataFrame(a = c(1, 3, 5), b = c(2, 4, 6))
#' df$select(
#'   index = pl$int_range(pl$len(), dtype = pl$UInt32),
#'   pl$all()
#' )
pl__int_range <- function(
    start = 0,
    end = NULL,
    step = 1,
    ...,
    dtype = pl$Int64) {
  wrap({
    check_dots_empty0(...)
    check_polars_dtype(dtype)
    if (is.null(end)) {
      end <- start
      start <- 0
    }
    int_range(
      as_polars_expr(start)$`_rexpr`,
      as_polars_expr(end)$`_rexpr`,
      step,
      dtype$`_dt`
    )
  })
}

#' Generate a range of integers for each row of the input columns
#'
#' @inheritParams pl__int_range
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(start = c(1, -1), end = c(3, 2))
#' df$with_columns(int_range = pl$int_ranges("start", "end"))
#'
#' # end can be omitted for a shorter syntax$
#' df$select("end", int_range = pl$int_ranges("end"))
pl__int_ranges <- function(
    start = 0,
    end = NULL,
    step = 1,
    ...,
    dtype = pl$Int64) {
  wrap({
    check_dots_empty0(...)
    check_polars_dtype(dtype)
    if (is.null(end)) {
      end <- start
      start <- 0
    }
    int_ranges(
      as_polars_expr(start)$`_rexpr`,
      as_polars_expr(end)$`_rexpr`,
      as_polars_expr(step)$`_rexpr`,
      dtype$`_dt`
    )
  })
}
