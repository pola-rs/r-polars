# The env for storing all series bin methods
polars_series_bin_methods <- new.env(parent = emptyenv())

namespace_series_bin <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x$`_s`

  lapply(names(polars_series_bin_methods), function(name) {
    fn <- polars_series_bin_methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  # Dispatch expr bin methods
  lapply(setdiff(names(polars_expr_bin_methods), names(self)), function(name) {
    fn <- polars_expr_bin_methods[[name]]
    wraped_fn <- expr_wrap_function_factory(fn, self)
    assign(name, wraped_fn, envir = self)
  })

  class(self) <- c("polars_namespace_series", "polars_object")
  self
}
