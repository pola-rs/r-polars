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
  # TODO: replace to rlang::list2
  exprs <- list(...) |>
    lapply(\(x) as_polars_expr(x)$`_rexpr`)
  self$`_ldf`$select(exprs) |>
    wrap()
}

lazyframe__collect <- function() {
  self$`_ldf`$collect() |>
    wrap()
}
