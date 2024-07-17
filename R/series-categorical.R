# The env for storing all series cat methods
polars_series_cat_methods <- new.env(parent = emptyenv())

namespace_series_cat <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x$`_s`

  lapply(names(polars_series_cat_methods), function(name) {
    fn <- polars_series_cat_methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  # Dispatch expr cat methods
  lapply(setdiff(names(polars_expr_cat_methods), names(self)), function(name) {
    fn <- polars_expr_cat_methods[[name]]
    wraped_fn <- expr_wrap_function_factory(fn, self)
    assign(name, wraped_fn, envir = self)
  })

  class(self) <- c("polars_namespace_series", "polars_object")
  self
}

series_cat_is_local <- function() {
  self$`_s`$cat_is_local() |>
    wrap()
}

series_cat_to_local <- function() {
  self$`_s`$cat_to_local() |>
    wrap()
}

series_cat_uses_lexical_ordering <- function() {
  self$`_s`$cat_uses_lexical_ordering() |>
    wrap()
}
