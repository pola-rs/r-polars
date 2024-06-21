# The env for storing lazygroupby methods
polars_lazygroupby__methods <- new.env(parent = emptyenv())

#' @export
wrap.PlRLazyGroupBy <- function(x) {
  self <- new.env(parent = emptyenv())
  self$lgb <- x

  lapply(names(polars_lazygroupby__methods), function(name) {
    fn <- polars_lazygroupby__methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- "polars_lazy_group_by"
  self
}

lazygroupby__agg <- function(...) {
  exprs <- list2(...) |>
    lapply(\(x) as_polars_expr(x)$`_rexpr`)
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
