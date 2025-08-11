#' Create sequence of evenly-spaced points
#'
#' `r lifecycle::badge("experimental")`
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams pl__date_range
#' @param start Lower bound of the range.
#' @param end Upper bound of the range.
#' @param num_samples Number of samples in the output sequence.
#'
#' @details
#' `linear_space` works with numeric and temporal dtypes. When the `start` and
#' `end` parameters are `Date` dtypes, the output sequence consists of
#' equally-spaced `Datetime` elements with millisecond precision.
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$select(
#'   pl$linear_space(start = 0, end = 1, num_samples = 3)
#' )
#' pl$select(
#'   pl$linear_space(start = 0, end = 1, num_samples = 3, closed = "left")
#' )
#' pl$select(
#'   pl$linear_space(start = 0, end = 1, num_samples = 3, closed = "right")
#' )
#' pl$select(
#'   pl$linear_space(start = 0, end = 1, num_samples = 3, closed = "none")
#' )
#'
#' # Date endpoints generate a sequence of Datetime values:
#' pl$select(
#'   pl$linear_space(
#'     start = as.Date("2025-01-01"),
#'     end = as.Date("2025-02-01"),
#'     num_samples = 3,
#'     closed = "right"
#'   )
#' )
#'
#' # You can generate a sequence using the length of the dataframe:
#' df <- pl$DataFrame(a = c(1, 2, 3, 4, 5))
#' df$with_columns(ls = pl$linear_space(0, 1, pl$len()))
pl__linear_space <- function(
  start,
  end,
  num_samples,
  ...,
  closed = c("both", "left", "none", "right")
) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "none", "right"))
    start <- as_polars_expr(start)$`_rexpr`
    end <- as_polars_expr(end)$`_rexpr`
    num_samples <- as_polars_expr(num_samples)$`_rexpr`
    linear_space(start, end, num_samples, closed)
  })
}

#' Create sequence of evenly-spaced points for each row between `start` and
#' `end`
#'
#' `r lifecycle::badge("experimental")`
#' The number of values in each sequence is determined by `num_samples`.
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams pl__linear_space
#' @param as_array Return result as a fixed-length `Array`. `num_samples` must
#' be a constant.
#'
#' @details
#' `linear_space` works with numeric and temporal dtypes. When the `start` and
#' `end` parameters are `Date` dtypes, the output sequence consists of
#' equally-spaced `Datetime` elements with millisecond precision.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(start = c(1, -1), end = c(3, 2), num_samples = c(4, 5))
#' df$with_columns(ls = pl$linear_spaces("start", "end", "num_samples"))
#'
#' df$with_columns(ls = pl$linear_spaces("start", "end", 3, as_array = TRUE))
pl__linear_spaces <- function(
  start,
  end,
  num_samples,
  ...,
  closed = c("both", "left", "none", "right"),
  as_array = FALSE
) {
  wrap({
    check_dots_empty0(...)
    # Non-integer values are rejected in the Rust function but we want to allow
    # num_samples = 3 for instance (for a better user experience).
    if (is_bare_double(num_samples) && is_integerish(num_samples)) {
      num_samples <- as.integer(num_samples)
    }
    closed <- arg_match0(closed, values = c("both", "left", "none", "right"))
    start <- as_polars_expr(start)$`_rexpr`
    end <- as_polars_expr(end)$`_rexpr`
    num_samples <- as_polars_expr(num_samples)$`_rexpr`
    linear_spaces(start, end, num_samples, closed, as_array)
  })
}
