# The env for storing all series str methods
polars_series_str_methods <- new.env(parent = emptyenv())

namespace_series_str <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x$`_s`

  lapply(names(polars_series_str_methods), function(name) {
    fn <- polars_series_str_methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  # Dispatch expr str methods
  lapply(setdiff(names(polars_expr_str_methods), names(self)), function(name) {
    fn <- polars_expr_str_methods[[name]]
    wraped_fn <- expr_wrap_function_factory(fn, self)
    assign(name, wraped_fn, envir = self)
  })

  class(self) <- c("polars_namespace_series", "polars_object")
  self
}
