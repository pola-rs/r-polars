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

series_cat_is_local <- function() {
  self$`_s`$cat_is_local() |>
    wrap()
}

series_cat_to_local <- function() {
  self$`_s`$cat_to_local() |>
    wrap()
}

# nolint start: object_length_linter
series_cat_uses_lexical_ordering <- function() {
  self$`_s`$cat_uses_lexical_ordering() |>
    wrap()
}
# nolint end
