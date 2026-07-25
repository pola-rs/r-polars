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

# Deprecated as of polars 1.14.0; Categoricals no longer have a local scope.
series_cat_to_local <- function() {
  deprecate_warn(
    c(
      `!` = sprintf(
        "%s is deprecated as of %s 1.14.0.",
        format_fn("cat$to_local"),
        format_pkg("polars")
      ),
      i = "Categoricals no longer have a local scope."
    )
  )
  self$`_s`$cat_to_local() |>
    wrap()
}

# nolint start: object_length_linter
series_cat_uses_lexical_ordering <- function() {
  self$`_s`$cat_uses_lexical_ordering() |>
    wrap()
}
# nolint end
