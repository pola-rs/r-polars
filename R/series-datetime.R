# The env for storing all series dt methods
polars_series_dt_methods <- new.env(parent = emptyenv())

namespace_series_dt <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_s` <- x$`_s`

  class(self) <- c(
    "polars_namespace_series_dt",
    "polars_namespace_series",
    "polars_object"
  )
  self
}
