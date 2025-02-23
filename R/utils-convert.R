#' The Polars duration string language
#'
#' @name polars_duration_string
#' @section Polars duration string language:
#' Polars duration string language is a simple representation of
#' durations. It is used in many Polars functions that accept durations.
#'
#' It has the following format:
#'
#' - 1ns (1 nanosecond)
#' - 1us (1 microsecond)
#' - 1ms (1 millisecond)
#' - 1s (1 second)
#' - 1m (1 minute)
#' - 1h (1 hour)
#' - 1d (1 calendar day)
#' - 1w (1 calendar week)
#' - 1mo (1 calendar month)
#' - 1q (1 calendar quarter)
#' - 1y (1 calendar year)
#'
#' Or combine them: `"3d12h4m25s"` # 3 days, 12 hours, 4 minutes, and 25 seconds
#'
#' By "calendar day", we mean the corresponding time on the next day
#' (which may not be 24 hours, due to daylight savings).
#' Similarly for "calendar week", "calendar month", "calendar quarter", and "calendar year".
NULL

# TODO: Test this function with expr_dt_to_string(format = "polars")
#' Parse an object as the Polars duration string language
#'
#' A generic function for parsing an object as a string representation of a duration.
#' See the `Polars duration string language` section for details.
#' @param x An object to parse as a duration.
#' It's length should be `1` and it should not be `NA`.
#' @param ... Additional arguments passed to methods.
#' @noRd
#' @examples
#' # A single character is passed as is
#' parse_as_duration_string("1d")
#'
#' # A single difftime is converted to a duration string
#' parse_as_duration_string(as.difftime(1, units = "days"))
parse_as_duration_string <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }
  UseMethod("parse_as_duration_string")
}

# TODO: error message improvement
#' @export
parse_as_duration_string.default <- function(x) {
  abort(
    paste0("`", deparse(substitute(x)), "` must be a single non-NA character or difftime."),
    call = caller_env()
  )
}

#' @export
parse_as_duration_string.character <- function(x) {
  if (length(x) != 1L || anyNA(x)) {
    abort(
      paste0("`", deparse(substitute(x)), "` must be a single non-NA character or difftime."),
      call = caller_env()
    )
  }
  x
}

#' @export
parse_as_duration_string.difftime <- function(x) {
  if (length(x) != 1L || anyNA(x)) {
    abort(
      paste0("`", deparse(substitute(x)), "` must be a single non-NA character or difftime."),
      call = caller_env()
    )
  }

  # fmt: skip
  unit <- switch(attr(x, "units"),
    weeks = "w",
    days = "d",
    hours = "h",
    mins = "m",
    secs = "s",
    abort("Unsupported `units` attribute of the difftime object.")
  )

  rest_value <- as.numeric(x)
  out <- ""

  if (rest_value < 0) {
    out <- "-"
    rest_value <- abs(rest_value)
  }

  if (unit == "w") {
    weeks <- trunc(rest_value)
    out <- sprintf("%s%dw", out, weeks)
    rest_value <- (rest_value - weeks) * 7
    unit <- "d"
  }

  if (unit == "d") {
    days <- trunc(rest_value)
    out <- sprintf("%s%dd", out, days)
    rest_value <- (rest_value - days) * 24
    unit <- "h"
  }

  if (unit == "h") {
    hours <- trunc(rest_value)
    out <- sprintf("%s%dh", out, hours)
    rest_value <- (rest_value - hours) * 60
    unit <- "m"
  }

  if (unit == "m") {
    minutes <- trunc(rest_value)
    out <- sprintf("%s%dm", out, minutes)
    rest_value <- (rest_value - minutes) * 60
  }

  seconds <- trunc(rest_value)
  milliseconds <- (rest_value - seconds) * 1e3

  sprintf("%s%ds%.0fms", out, seconds, milliseconds)
}

#' @export
parse_as_duration_string.clock_duration <- function(x) {
  if (length(x) != 1L || anyNA(x)) {
    abort(
      paste0("`", deparse(substitute(x)), "` must be a single non-NA character or difftime."),
      call = caller_env()
    )
  }

  precision <- clock::duration_precision(x)

  # fmt: skip
  unit <- switch(precision,
    nanosecond = "ns",
    microsecond = "us",
    millisecond = "ms",
    second = "s",
    minute = "m",
    hour = "h",
    day = "d",
    week = "w",
    month = "mo",
    quarter = "q",
    year = "y",
    abort(
      sprintf("Unsupported precision `%s` of the clock duration object.", precision)
    )
  )

  sprintf("%s%s", x, unit)
}

negate_duration_string <- function(x) {
  if (startsWith(x, "-")) {
    gsub("^-", "", x)
  } else {
    paste0("-", x)
  }
}
