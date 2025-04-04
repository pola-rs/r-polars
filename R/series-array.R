# The env for storing all series arr methods
polars_series_arr_methods <- new.env(parent = emptyenv())

namespace_series_arr <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x$`_s`

  class(self) <- c(
    "polars_namespace_series_arr",
    "polars_namespace_series",
    "polars_object"
  )
  self
}
