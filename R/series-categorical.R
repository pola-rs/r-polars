# The env for storing all series cat methods
polars_series_cat_methods <- new.env(parent = emptyenv())

namespace_series_cat <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x$`_s`

  class(self) <- c(
    "polars_namespace_series_cat",
    "polars_namespace_series",
    "polars_object"
  )
  self
}
