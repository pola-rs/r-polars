# The env for storing lazygroupby methods
polars_lazygroupby__methods <- new.env(parent = emptyenv())

#' @export
wrap.PlRLazyGroupBy <- function(x, ...) {
  self <- new.env(parent = emptyenv())
  self$lgb <- x

  class(self) <- c("polars_lazy_group_by", "polars_object")
  self
}

lazygroupby__agg <- function(...) {
  exprs <- parse_into_list_of_expressions(...)
  self$lgb$agg(exprs) |>
    wrap()
}

lazygroupby__head <- function(n = 5) {
  self$lgb$head(n) |>
    wrap()
}

lazygroupby__tail <- function(n = 5) {
  self$lgb$tail(n) |>
    wrap()
}
