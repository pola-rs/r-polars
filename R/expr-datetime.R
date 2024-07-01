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

  class(self) <- c(
    "polars_namespace_expr", "polars_dt_namespace", "polars_object"
  )
  self
}

expr_dt_convert_time_zone <- function(time_zone) {
  self$`_rexpr`$dt_convert_time_zone(time_zone) |>
    wrap()
}

expr_dt_replace_time_zone <- function(time_zone, ..., ambiguous = "raise", non_existent = "raise") {
  check_dots_empty0(...)

  ambiguous <- as_polars_expr(ambiguous, str_as_lit = TRUE)$`_rexpr`
  self$`_rexpr`$dt_replace_time_zone(time_zone, ambiguous = ambiguous, non_existent = non_existent) |>
    wrap()
}