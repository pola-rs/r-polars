# The env for storing all series bin methods
polars_series_bin_methods <- new.env(parent = emptyenv())

namespace_series_bin <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x$`_s`

  class(self) <- c(
    "polars_namespace_series_bin",
    "polars_namespace_series",
    "polars_object"
  )
  self
}
