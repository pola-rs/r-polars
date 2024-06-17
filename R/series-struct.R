# The env for storing all series struct methods
polars_series_struct_methods <- new.env(parent = emptyenv())

namespace_series_struct <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x$`_s`

  lapply(names(polars_series_struct_methods), function(name) {
    fn <- polars_series_struct_methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- "polars_namespace_series"
  self
}

series_struct_unnest <- function() {
  self$`_s`$struct_unnest() |>
    wrap()
}
