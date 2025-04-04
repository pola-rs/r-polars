# The env for storing all series list methods
polars_series_list_methods <- new.env(parent = emptyenv())

namespace_series_list <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x$`_s`

  class(self) <- c(
    "polars_namespace_series_list",
    "polars_namespace_series",
    "polars_object"
  )
  self
}
