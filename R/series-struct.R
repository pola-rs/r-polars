series_namespace_struct <- function(x) {
  .self <- new.env(parent = emptyenv())
  .self$`_s` <- x$`_s`

  .self$unnest <- function() series_struct_unnest(.self)

  class(.self) <- "polars_namespace_series"
  .self
}

series_struct_unnest <- function(self) {
  self$`_s`$struct_unnest() |>
    wrap()
}
