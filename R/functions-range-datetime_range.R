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
