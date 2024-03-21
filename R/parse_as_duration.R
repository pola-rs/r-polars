#' Parse an object as the Polars duration string language
#'
#' A generic function for parsing an object as a string representation of a duration.
#' See the `Polars duration string language` section for details.
#' @param x An object to parse as a duration.
#' It's length should be `1` and it should not be `NA`.
#' @param ... Additional arguments passed to methods.
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
#' @export
#' @examples
#' # A single character is passed as is
#' parse_as_polars_duration_string("1d")
#'
#' # A single difftime is converted to a duration string
#' parse_as_polars_duration_string(as.difftime(1, units = "days"))
parse_as_polars_duration_string = function(x, ...) {
  UseMethod("parse_as_polars_duration_string")
}


#' @rdname parse_as_polars_duration_string
#' @export
parse_as_polars_duration_string.character = function(x, ...) {
  if (length(x) != 1L || is.na(x)) {
    Err_plain("`x` should be a single non-NA character.") |>
      unwrap("in `parse_as_polars_duration_string(<character>)`")
  }

  x
}


#' @rdname parse_as_polars_duration_string
#' @export
parse_as_polars_duration_string.difftime = function(x, ...) {
  if (length(x) != 1L || is.na(x)) {
    Err_plain("`x` should be a single non-NA difftime.") |>
      unwrap("in `parse_as_polars_duration_string(<difftime>)`")
  }

  difftime_to_duration_string(x)
}


# Internal function for parsing difftime to Polars interval language
difftime_to_duration_string = function(dft) {
  value = as.numeric(dft)
  u = attr(dft, "units")
  unit = pcase(
    !is_string(u), Err(sprintf("difftime units should be a character, not a %s", class(u))),
    u == "secs", "s",
    u == "mins", "m",
    u == "hours", "h",
    u == "days", "d",
    u == "weeks", "w",
    u == "years", "y",
    or_else = Err(sprintf("unknown difftime units: %s", u))
  )
  paste0(value, unit)
}
