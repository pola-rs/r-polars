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

  class(self) <- c("polars_lazy_frame", "polars_object")
  self
}

lazyframe__select <- function(...) {
  exprs <- parse_into_list_of_expressions(...)
  self$`_ldf`$select(exprs) |>
    wrap()
}

lazyframe__group_by <- function(..., maintain_order = FALSE) {
  exprs <- parse_into_list_of_expressions(...)
  self$`_ldf`$group_by(exprs, maintain_order) |>
    wrap()
}

lazyframe__collect <- function() {
  self$`_ldf`$collect() |>
    wrap()
}
