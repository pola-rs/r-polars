# TODO: link to the Date type docs
#' Generate a date range
#'
#' If both `start` and `end` are passed as the Date types (not Datetime), and
#' the `interval` granularity is no finer than `"1d"`, the returned range is
#' also of type Date. All other permutations return a Datetime.
#'
#' @inheritParams rlang::check_dots_empty0
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

# TODO: add link to Datatype
#' Generate a datetime range
#'
#' @inheritParams pl__date_range
#' @inheritSection polars_duration_string  Polars duration string language
#'
#' @param time_unit Time unit of the resulting the [Datetime][DataType_Datetime]
#' data type. One of `"ns"`, `"us"`, `"ms"` or `NULL`
#' @param time_zone Time zone of the resulting [Datetime][DataType_Datetime]
#' data type.
#'
#' @inherit as_polars_expr return
#'
#' @seealso [`pl$datetime_ranges()`][pl__datetime_ranges] to create a simple
#' Series of data type list(Datetime) based on column values.
#'
#' @examples
#' # Using Polars duration string to specify the interval:
#' pl$select(
#'   datetime = pl$datetime_range(as.Date("2022-01-01"), as.Date("2022-03-01"), "1mo")
#' )
#'
#' # Using `difftime` object to specify the interval:
#' pl$select(
#'   datetime = pl$datetime_range(
#'     as.Date("1985-01-01"),
#'     as.Date("1985-01-10"),
#'     as.difftime(1, units = "days") + as.difftime(12, units = "hours")
#'   )
#' )
#'
#' # Specifying a time zone:
#' pl$select(
#'   datetime = pl$datetime_range(
#'     as.Date("2022-01-01"),
#'     as.Date("2022-03-01"),
#'     "1mo",
#'     time_zone = "America/New_York"
#'   )
#' )
pl__datetime_range <- function(
    start,
    end,
    interval = "1d",
    ...,
    closed = c("both", "left", "none", "right"),
    time_unit = NULL,
    time_zone = NULL) {
  wrap({
    check_dots_empty0(...)
    check_date_or_datetime(start)
    check_date_or_datetime(end)
    closed <- arg_match0(closed, values = c("both", "left", "none", "right"))
    interval <- parse_as_duration_string(interval)
    datetime_range(
      as_polars_expr(start)$`_rexpr`,
      as_polars_expr(end)$`_rexpr`,
      interval, closed, time_unit, time_zone
    )
  })
}

#' Generate a list containing a datetime range
#'
#' @inheritParams pl__datetime_range
#' @inheritSection polars_duration_string  Polars duration string language
#'
#' @inherit as_polars_expr return
#'
#' @seealso [`pl$datetime_range()`][pl__datetime_range] to create a simple Series
#' of data type Datetime.
#'
#' @examples
#' df <- pl$DataFrame(
#'   start = as.POSIXct(c("2022-01-01 10:00", "2022-01-01 11:00", NA)),
#'   end = rep(as.POSIXct("2022-01-01 12:00"), 3)
#' )
#'
#' df$with_columns(
#'   dt_range = pl$datetime_ranges("start", "end", interval = "1h"),
#'   dt_range_cr = pl$datetime_ranges("start", "end", closed = "right", interval = "1h")
#' )
#'
#' # provide a custom "end" value
#' df$with_columns(
#'   dt_range_lit = pl$datetime_ranges(
#'     "start", pl$lit(as.POSIXct("2022-01-01 11:00")),
#'     interval = "1h"
#'   )
#' )
pl__datetime_ranges <- function(
    start,
    end,
    interval = "1d",
    ...,
    closed = c("both", "left", "none", "right"),
    time_unit = NULL,
    time_zone = NULL) {
  wrap({
    check_dots_empty0(...)
    check_date_or_datetime(start)
    check_date_or_datetime(end)
    closed <- arg_match0(closed, values = c("both", "left", "none", "right"))
    interval <- parse_as_duration_string(interval)
    datetime_ranges(
      as_polars_expr(start)$`_rexpr`,
      as_polars_expr(end)$`_rexpr`,
      interval, closed, time_unit, time_zone
    )
  })
}

#' Generate a range of integers
#'
#' @inheritParams rlang::check_dots_empty0
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

#' Generate a time range
#'
#' @inheritParams rlang::check_dots_empty0
#' @inheritParams pl__datetime_range
#' @param start Lower bound of the time range. If omitted, defaults to
#' `00:00:00.000`.
#' @param end Upper bound of the time range. If omitted, defaults to
#' `23:59:59.999`
#' @param interval Interval of the range periods, specified as a [difftime]
#' or using the Polars duration string language (see details).
#'
#' @inheritSection polars_duration_string Polars duration string language
#' @inherit as_polars_expr return
#' @examplesIf requireNamespace("hms", quietly = TRUE)
#' pl$select(
#'   time = pl$time_range(
#'     start = hms::parse_hms("14:00:00"),
#'     interval = as.difftime("3:15:00")
#'   )
#' )
pl__time_range <- function(
    start = NULL,
    end = NULL,
    interval = "1h",
    ...,
    closed = c("both", "left", "none", "right")) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "none", "right"))
    interval <- parse_as_duration_string(interval)
    for (unit in c("y", "mo", "w", "d")) {
      if (grepl(unit, interval)) {
        abort(sprintf("invalid unit in `interval`: found '%s'", unit))
      }
    }
    start <- start %||% pl$lit(0)$cast(pl$Time)
    end <- end %||% pl$lit(86399999999999)$cast(pl$Time)

    time_range(
      as_polars_expr(start)$`_rexpr`,
      as_polars_expr(end)$`_rexpr`,
      interval,
      closed
    )
  })
}

#' Create a column of time ranges
#'
#' @inheritParams rlang::check_dots_empty0
#' @inheritParams pl__time_range
#'
#' @inheritSection polars_duration_string Polars duration string language
#' @inherit as_polars_expr return
#' @examplesIf requireNamespace("hms", quietly = TRUE)
#' df <- pl$DataFrame(
#'   start = hms::parse_hms(c("09:00:00", "10:00:00")),
#'   end = hms::parse_hms(c("11:00:00", "11:00:00"))
#' )
#' df$with_columns(time_range = pl$time_ranges("start", "end"))
pl__time_ranges <- function(
    start = NULL,
    end = NULL,
    interval = "1h",
    ...,
    closed = c("both", "left", "none", "right")) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "none", "right"))
    interval <- parse_as_duration_string(interval)
    for (unit in c("y", "mo", "w", "d")) {
      if (grepl(unit, interval)) {
        abort(sprintf("invalid unit in `interval`: found '%s'", unit))
      }
    }
    start <- start %||% pl$lit(0)$cast(pl$Time)
    end <- end %||% pl$lit(86399999999999)$cast(pl$Time)

    time_ranges(
      as_polars_expr(start)$`_rexpr`,
      as_polars_expr(end)$`_rexpr`,
      interval,
      closed
    )
  })
}
