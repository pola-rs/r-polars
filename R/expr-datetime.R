# The env for storing all expr dt methods
polars_expr_dt_methods <- new.env(parent = emptyenv())

namespace_expr_dt <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x$`_rexpr`

  lapply(names(polars_expr_dt_methods), function(name) {
    fn <- polars_expr_dt_methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- c("polars_namespace_expr", "polars_object")
  self
}

expr_dt_convert_time_zone <- function(time_zone) {
  self$`_rexpr`$dt_convert_time_zone(time_zone) |>
    wrap()
}

# TODO: link to `convert_time_zone`
# TODO: return, examples
#' Replace time zone for an expression of type Datetime
#'
#' Different from `convert_time_zone`, this will also modify the underlying timestamp
#' and will ignore the original time zone.
#'
#' @inheritParams rlang::args_dots_empty
#' @param time_zone `NULL` or a character time zone from [base::OlsonNames()].
#' Pass `NULL` to unset time zone.
#' @param ambiguous Determine how to deal with ambiguous datetimes.
#' Character vector or [expression] containing the followings:
#' - `"raise"` (default): Throw an error
#' - `"earliest"`: Use the earliest datetime
#' - `"latest"`: Use the latest datetime
#' - `"null"`: Return a null value
#' @param non_existent Determine how to deal with non-existent datetimes.
#' One of the followings:
#' - `"raise"` (default): Throw an error
#' - `"null"`: Return a null value
expr_dt_replace_time_zone <- function(time_zone, ..., ambiguous = "raise", non_existent = "raise") {
  wrap({
    check_dots_empty0(...)

    ambiguous <- as_polars_expr(ambiguous, as_lit = TRUE)$`_rexpr`
    self$`_rexpr`$dt_replace_time_zone(
      time_zone,
      ambiguous = ambiguous,
      non_existent = non_existent
    )
  })
}
