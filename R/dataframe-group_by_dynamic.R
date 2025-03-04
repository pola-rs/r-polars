# The env for storing rolling_group_by methods
polars_group_by_dynamic__methods <- new.env(parent = emptyenv())

wrap_to_group_by_dynamic <- function(
  x,
  index_column,
  every,
  period,
  offset,
  include_boundaries,
  closed,
  label,
  group_by,
  start_by
) {
  self <- new.env(parent = emptyenv())
  self$df <- x
  self$index_column <- index_column
  self$every <- every
  self$period <- period
  self$offset <- offset
  self$include_boundaries <- include_boundaries
  self$closed <- closed
  self$label <- label
  self$group_by <- group_by
  self$start_by <- start_by

  class(self) <- c("polars_group_by_dynamic", "polars_object")
  self
}

group_by_dynamic__agg <- function(...) {
  self$df$lazy()$group_by_dynamic(
    index_column = self$index_column,
    every = self$every,
    period = self$period,
    offset = self$offset,
    include_boundaries = self$include_boundaries,
    closed = self$closed,
    label = self$label,
    group_by = self$group_by,
    start_by = self$start_by
  )$agg(...)$collect(no_optimization = TRUE) |>
    wrap()
}
