# The env for storing rolling_group_by methods
polars_rolling_groupby__methods <- new.env(parent = emptyenv())

wrap_to_rolling_group_by <- function(x, index_column, period, offset, closed, group_by) {
  self <- new.env(parent = emptyenv())
  self$df <- x
  self$index_column <- index_column
  self$period <- period
  self$offset <- offset
  self$closed <- closed
  self$group_by <- group_by

  class(self) <- c("polars_rolling_group_by", "polars_object")
  self
}

rolling_groupby__agg <- function(...) {
  self$df$lazy()$rolling(
    index_column = self$index_column,
    period = self$period,
    offset = self$offset,
    closed = self$closed,
    group_by = self$group_by
  )$agg(...)$collect(no_optimization = TRUE) |>
    wrap()
}
