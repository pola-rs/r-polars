# The env for storing lazyrame methods
polars_lazyframe__methods <- new.env(parent = emptyenv())

#' @export
is_polars_lf <- function(x) {
  inherits(x, "polars_lazy_frame")
}

#' @export
wrap.PlRLazyFrame <- function(x, ...) {
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
  wrap({
    exprs <- parse_into_list_of_expressions(...)
    self$`_ldf`$select(exprs)
  })
}

lazyframe__group_by <- function(..., maintain_order = FALSE) {
  wrap({
    exprs <- parse_into_list_of_expressions(...)
    self$`_ldf`$group_by(exprs, maintain_order)
  })
}

lazyframe__collect <- function() {
  self$`_ldf`$collect() |>
    wrap()
}

lazyframe__cast <- function(..., strict = TRUE) {
  parse_into_list_of_datatypes(...) |>
    self$`_ldf`$cast(strict) |>
    wrap()
}

lazyframe__sort <- function(
    ...,
    descending = FALSE,
    nulls_last = FALSE,
    multithreaded = TRUE,
    maintain_order = FALSE) {
  wrap({
    check_dots_unnamed()

    by <- parse_into_list_of_expressions(...)
    descending <- extend_bool(descending, length(by), "descending", "...")
    nulls_last <- extend_bool(nulls_last, length(by), "nulls_last", "...")

    self$`_ldf`$sort_by_exprs(
      by,
      descending = descending,
      nulls_last = nulls_last,
      multithreaded = multithreaded,
      maintain_order = maintain_order
    )
  })
}

lazyframe__with_columns <- function(...) {
  parse_into_list_of_expressions(...) |>
    self$`_ldf`$with_columns() |>
    wrap()
}
