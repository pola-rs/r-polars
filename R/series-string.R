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
      ambiguous <- as_polars_expr(ambiguous)
      s <- wrap(s$`_s`)

      s$to_frame()$select_seq(
        pl__col(s$name)$str$to_datetime(
          format,
          time_unit = time_unit,
          time_zone = time_zone,
          strict = strict,
          exact = exact,
          cache = cache,
          ambiguous = ambiguous
        )
      )$to_series()
    }
  })
}
