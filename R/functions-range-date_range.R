# TODO: link to the Date type docs
#' Generate a date range
#'
#' If both `start` and `end` are passed as the Date types (not Datetime), and
#' the `interval` granularity is no finer than `"1d"`, the returned range is
#' also of type Date. All other permutations return a Datetime.
#'
#' @inheritParams rlang::args_dots_empty
#' @param start Lower bound of the date range. Something that can be coerced to
#' a Date or a [Datetime][DataType_Datetime] expression. See examples for details.
#' @param end Upper bound of the date range. Something that can be coerced to a
#' Date or a [Datetime][DataType_Datetime] expression. See examples for details.
#' @param interval Interval of the range periods, specified as a [difftime]
#' object or using the Polars duration string language. See the `Polars
#' duration string language` section for details. Must consist of full days.
#' @param closed Define which sides of the range are closed (inclusive).
#' One of the following: `"both"` (default), `"left"`, `"right"`, `"none"`.
#'
#' @inherit as_polars_expr return
#'
#' @inheritSection polars_duration_string Polars duration string language
#'
#' @seealso [`pl$date_ranges()`][pl__date_ranges] to create a simple Series of
#' data type list(Date) based on column values.
#'
#' @examples
#' # Using Polars duration string to specify the interval:
#' pl$select(
#'   date = pl$date_range(as.Date("2022-01-01"), as.Date("2022-03-01"), "1mo")
#' )
#'
#' # Using `difftime` object to specify the interval:
#' pl$select(
#'   date = pl$date_range(
#'     as.Date("1985-01-01"),
#'     as.Date("1985-01-10"),
#'     as.difftime(2, units = "days")
#'   )
#' )
pl__date_range <- function(
    start,
    end,
    interval = "1d",
    ...,
    closed = c("both", "left", "none", "right")) {
  wrap({
    check_dots_empty0(...)
    check_date_or_datetime(start)
    check_date_or_datetime(end)
    closed <- arg_match0(closed, values = c("both", "left", "none", "right"))
    interval <- parse_as_duration_string(interval)
    date_range(
      as_polars_expr(start)$`_rexpr`,
      as_polars_expr(end)$`_rexpr`,
      interval,
      closed
    )
  })
}

# TODO: link to the Date type docs
#' Create a column of date ranges
#'
#' If both `start` and `end` are passed as Date types (not Datetime), and
#' the `interval` granularity is no finer than `"1d"`, the returned range is
#' also of type Date. All other permutations return a Datetime.
#'
#' @inheritParams pl__date_range
#' @inheritSection polars_duration_string  Polars duration string language
#'
#' @inherit as_polars_expr return
#'
#' @seealso [`pl$date_range()`][pl__date_range] to create a simple Series of
#' data type Date.
#'
#' @examples
#' df <- pl$DataFrame(
#'   start = as.Date(c("2022-01-01", "2022-01-02", NA)),
#'   end = rep(as.Date("2022-01-03"), 3)
#' )
#'
#' df$with_columns(
#'   date_range = pl$date_ranges("start", "end"),
#'   date_range_cr = pl$date_ranges("start", "end", closed = "right")
#' )
#'
#' # provide a custom "end" value
#' df$with_columns(
#'   date_range_lit = pl$date_ranges("start", pl$lit(as.Date("2022-01-02")))
#' )
pl__date_ranges <- function(
    start,
    end,
    interval = "1d",
    ...,
    closed = c("both", "left", "none", "right")) {
  wrap({
    check_dots_empty0(...)
    check_date_or_datetime(start)
    check_date_or_datetime(end)
    closed <- arg_match0(closed, values = c("both", "left", "none", "right"))
    interval <- parse_as_duration_string(interval)
    date_ranges(
      as_polars_expr(start)$`_rexpr`,
      as_polars_expr(end)$`_rexpr`,
      interval,
      closed
    )
  })
}
