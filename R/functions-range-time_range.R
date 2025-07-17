#' Generate a time range
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams pl__datetime_range
#' @param start Lower bound of the time range. If omitted, defaults to
#' `00:00:00.000`.
#' @param end Upper bound of the time range. If omitted, defaults to
#' `23:59:59.999`
#' @param interval Interval of the range periods, specified as a [difftime]
#' or using the Polars duration string language (see details).
#'
#' @inheritSection polars-duration-string Polars duration string language
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
  closed = c("both", "left", "none", "right")
) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "none", "right"))
    interval <- parse_as_duration_string(interval)
    check_time_units(interval)

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
#' @inheritParams rlang::args_dots_empty
#' @inheritParams pl__time_range
#'
#' @inheritSection polars-duration-string Polars duration string language
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
  closed = c("both", "left", "none", "right")
) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "none", "right"))
    interval <- parse_as_duration_string(interval)
    check_time_units(interval)

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

check_time_units <- function(interval) {
  for (unit in c("y", "mo", "w", "d")) {
    if (grepl(unit, interval)) {
      abort(
        c(
          sprintf("Invalid unit in `interval`, found '%s'", unit),
          i = 'Units "y", "mo", "w", and "d" are not supported.'
        ),
        call = caller_env()
      )
    }
  }
}
