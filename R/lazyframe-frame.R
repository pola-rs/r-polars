# The env for storing lazyrame methods
polars_lazyframe__methods <- new.env(parent = emptyenv())

#' @export
wrap.PlRLazyFrame <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_ldf` <- x

  lapply(names(polars_lazyframe__methods), function(name) {
    fn <- polars_lazyframe__methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- "polars_lazy_frame"
  self
}

lazyframe__select <- function(...) {
  exprs <- list2(...) |>
    lapply(\(x) as_polars_expr(x)$`_rexpr`)
  self$`_ldf`$select(exprs) |>
    wrap()
}

lazyframe__group_by <- function(..., maintain_order = FALSE) {
  exprs <- list2(...) |>
    lapply(\(x) as_polars_expr(x)$`_rexpr`)
  self$`_ldf`$group_by(exprs, maintain_order) |>
    wrap()
}

lazyframe__collect <- function() {
  self$`_ldf`$collect() |>
    wrap()
}
