# The env for storing all series str methods
polars_series_str_methods <- new.env(parent = emptyenv())

namespace_series_str <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x$`_s`

  class(self) <- c(
    "polars_namespace_series_str",
    "polars_namespace_series",
    "polars_object"
  )
  self
}

#' Convert a String Series into a Datetime Series
#' @inherit as_polars_series return
#' @inheritParams expr_str_to_datetime
#' @param ambiguous Determine how to deal with ambiguous datetimes.
#' Character vector or [Series] containing the followings:
#' - `"raise"` (default): Throw an error
#' - `"earliest"`: Use the earliest datetime
#' - `"latest"`: Use the latest datetime
#' - `"null"`: Return a null value
#' @examples
#' s <- as_polars_series(c("2020-01-01 01:00Z", "2020-01-01 02:00Z"))
#' s$str$to_datetime("%Y-%m-%d %H:%M%#z")
#' s$str$to_datetime(time_unit = "ms")
series_str_to_datetime <- function(
  format = NULL,
  ...,
  time_unit = NULL,
  time_zone = NULL,
  strict = TRUE,
  exact = TRUE,
  cache = TRUE,
  ambiguous = c("raise", "earliest", "latest", "null")
) {
  wrap({
    check_dots_empty0(...)

    ambiguous <- if (!is_polars_series(ambiguous)) {
      arg_match0(ambiguous, c("raise", "earliest", "latest", "null")) |>
        as_polars_series()
    } else {
      ambiguous
    }

    if (is.null(format) && is.null(time_zone)) {
      self$`_s`$str_to_datetime_infer(
        time_unit = time_unit,
        strict = strict,
        exact = exact,
        ambiguous = ambiguous$`_s`
      )
    } else {
      ambiguous_expr <- as_polars_expr(ambiguous)
      s <- wrap(s$`_s`)

      s$to_frame()$select_seq(
        pl__col(s$name)$str$to_datetime(
          format,
          time_unit = time_unit,
          time_zone = time_zone,
          strict = strict,
          exact = exact,
          cache = cache,
          ambiguous = ambiguous_expr
        )
      )$to_series()
    }
  })
}

#' Convert a String Series into a Date/Datetime/Time Series
#'
# The order of roxygen tags is important to inherit params from series_str_to_datetime
#' @inherit as_polars_series return
#' @inheritParams series_str_to_datetime
#' @inherit expr_str_strptime description details
#' @inheritParams expr_str_strptime
#' @examples
#' s1 <- as_polars_series(c("2020-01-01 01:00Z", "2020-01-01 02:00Z"))
#'
#' s1$str$strptime(pl$Datetime(), "%Y-%m-%d %H:%M%#z")
#'
#' # Auto infer format
#' s1$str$strptime(pl$Datetime())
#'
#' # Datetime with timezone is interpreted as UTC timezone
#' s2 <- as_polars_series(c("2020-01-01T01:00:00+09:00"))
#' s2$str$strptime(pl$Datetime())
#'
#' # Dealing with different formats.
#' s3 <- as_polars_series(
#'   c(
#'     "2021-04-22",
#'     "2022-01-04 00:00:00",
#'     "01/31/22",
#'     "Sun Jul  8 00:34:60 2001"
#'   )
#' )
#'
#' pl$select(pl$coalesce(
#'   s3$str$strptime(pl$Date, "%F", strict = FALSE),
#'   s3$str$strptime(pl$Date, "%F %T", strict = FALSE),
#'   s3$str$strptime(pl$Date, "%D", strict = FALSE),
#'   s3$str$strptime(pl$Date, "%c", strict = FALSE),
#' ))$to_series()
series_str_strptime <- function(
  dtype,
  format = NULL,
  ...,
  strict = TRUE,
  exact = TRUE,
  cache = TRUE,
  ambiguous = c("raise", "earliest", "latest", "null")
) {
  wrap({
    check_dots_empty0(...)
    check_polars_dtype(dtype)

    if (is.null(format) && inherits(dtype, "polars_dtype_datetime") && is.null(dtype$time_zone)) {
      self$to_datetime(
        time_unit = NULL,
        strict = strict,
        exact = exact,
        cache = cache,
        ambiguous = ambiguous
      )
    } else {
      ambiguous <- if (!is_polars_series(ambiguous)) {
        arg_match0(ambiguous, c("raise", "earliest", "latest", "null")) |>
          as_polars_series()
      } else {
        ambiguous
      }
      ambiguous_expr <- as_polars_expr(ambiguous)
      s <- wrap(self$`_s`)

      s$to_frame()$select_seq(
        pl__col(s$name)$str$strptime(
          dtype = dtype,
          format = format,
          strict = strict,
          exact = exact,
          cache = cache,
          ambiguous = ambiguous_expr
        )
      )$to_series()
    }
  })
}
