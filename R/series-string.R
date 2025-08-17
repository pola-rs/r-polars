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

#' Convert a String Series into a Decimal Series
#'
#' `r lifecycle::badge("experimental")`
#'
#' @inherit as_polars_series return
#' @inheritParams rlang::args_dots_empty
#' @param scale Number of digits after the comma to use for the decimals, or `NULL` (default).
#'   If `NULL`, the method will infer the scale from the data.
#' @param inference_length Number of elements to parse to determine the
#'   `precision` and `scale` of the [decimal data type][pl__Decimal].
#' @examples
#' s <- as_polars_series(c(
#'   "40.12",
#'   "3420.13",
#'   "120134.19",
#'   "3212.98",
#'   "12.90",
#'   "143.09",
#'   "143.9"
#' ))
#'
#' s$str$to_decimal()
#' s$str$to_decimal(scale = 4)
series_str_to_decimal <- function(..., scale = NULL, inference_length = 100L) {
  wrap({
    check_dots_empty0(...)

    if (is.null(scale)) {
      self$`_s`$str_to_decimal_infer(inference_length)
    } else {
      s <- wrap(self$`_s`)
      s$to_frame()$select_seq(
        pl__col(s$name)$str$to_decimal(
          scale = scale
        )
      )$to_series()
    }
  })
}

#' Parse string values as JSON
#'
#' Throws an error if invalid JSON strings are encountered.
#' @inherit as_polars_series return
#' @inheritParams rlang::args_dots_empty
#' @param dtype The [dtype][DataType] to cast the extracted value to, or `NULL` (default).
#'   If `NULL`, the dtype will be inferred from the JSON value.
#' @param infer_schema_length The maximum number of rows to scan for schema inference.
#'   If set to `NULL`, the full data may be scanned *(this is slow)*.
#'   Only used if the `dtype` argument is `NULL`.
#' @examples
#' s1 <- as_polars_series(c('{"a":1, "b": true}', NA, '{"a":2, "b": false}'))
#'
#' s2 <- s1$str$json_decode()
#' s2
#' s2$dtype
#'
#' s3 <- s1$str$json_decode(pl$Struct(a = pl$UInt8, b = pl$Boolean))
#' s3
#' s3$dtype
series_str_json_decode <- function(dtype = NULL, ..., infer_schema_length = 100L) {
  wrap({
    check_dots_empty0(...)

    if (is.null(dtype)) {
      self$`_s`$str_json_decode(infer_schema_length)
    } else {
      s <- wrap(self$`_s`)
      s$to_frame()$select_seq(
        pl__col(s$name)$str$json_decode(dtype = dtype)
      )$to_series()
    }
  })
}
