# The env for storing all series dt methods
polars_series_dt_methods <- new.env(parent = emptyenv())

namespace_series_dt <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x$`_s`

  lapply(names(polars_series_dt_methods), function(name) {
    fn <- polars_series_dt_methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  # Dispatch expr dt methods
  lapply(setdiff(names(polars_expr_dt_methods), names(self)), function(name) {
    fn <- polars_expr_dt_methods[[name]]
    wraped_fn <- expr_wrap_function_factory(fn, self, "dt")
    assign(name, wraped_fn, envir = self)
  })

  class(self) <- c("polars_namespace_series", "polars_object")
  self
}
