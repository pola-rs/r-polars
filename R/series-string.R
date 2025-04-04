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
