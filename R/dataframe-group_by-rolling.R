# The env for storing rolling_group_by methods
polars_rolling_groupby__methods <- new.env(parent = emptyenv()) # nolint: object_length_linter

wrap_to_rolling_group_by <- function(
  x,
  index_column,
  period,
  offset,
  closed,
  group_by,
  predicates
) {
  self <- new.env(parent = emptyenv())
  self$df <- x
  self$index_column <- index_column
  self$period <- period
  self$offset <- offset
  self$closed <- closed
  self$group_by <- group_by
  self$predicates <- predicates

  class(self) <- c("polars_rolling_group_by", "polars_object")
  self
}

rolling_groupby__agg <- function(...) {
  wrap({
    out <- self$df$lazy()$rolling(
      index_column = self$index_column,
      period = self$period,
      offset = self$offset,
      closed = self$closed,
      group_by = self$group_by
    )
    if (!is.null(self$predicates)) {
      out <- out$having(!!!self$predicates)
    }
    out$agg(...)$collect(optimizations = QueryOptFlags()$no_optimizations())
  })
}

rolling_groupby__having <- function(...) {
  wrap_to_rolling_group_by(
    x = self$df,
    index_column = self$index_column,
    period = self$period,
    offset = self$offset,
    closed = self$closed,
    group_by = self$group_by,
    predicates = c(self$predicates, list2(...))
  )
}
