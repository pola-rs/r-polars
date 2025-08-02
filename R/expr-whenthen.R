#' @export
wrap.PlRWhen <- function(x, ...) {
  self <- new.env(parent = emptyenv())
  self$`_when` <- x

  fn <- when__then
  environment(fn) <- environment()
  self$then <- fn

  class(self) <- c("polars_when", "polars_object")
  self
}

when__then <- function(statement) {
  as_polars_expr(statement)$`_rexpr` |>
    self$`_when`$then() |>
    wrap()
}

# The env storing then methods
polars_then__methods <- new.env(parent = emptyenv())

#' @export
wrap.PlRThen <- function(x, ...) {
  self <- new.env(parent = emptyenv())
  self$`_then` <- x
  makeActiveBinding("_rexpr", function() self$`_then`$otherwise(lit_null()), self)

  lapply(names(polars_namespaces_expr), function(namespace) {
    makeActiveBinding(namespace, function() polars_namespaces_expr[[namespace]](self), self)
  })

  class(self) <- c("polars_then", "polars_expr", "polars_object")
  self
}

then__when <- function(...) {
  parse_predicates_constraints_into_expression(...) |>
    self$`_then`$when() |>
    wrap()
}

then__otherwise <- function(otherwise) {
  as_polars_expr(otherwise)$`_rexpr` |>
    self$`_then`$otherwise() |>
    wrap()
}

#' @export
wrap.PlRChainedWhen <- function(x, ...) {
  self <- new.env(parent = emptyenv())
  self$`_chained_when` <- x

  fn <- chainedwhen__then
  environment(fn) <- environment()
  self$then <- fn

  class(self) <- c("polars_chained_when", "polars_object")
  self
}

chainedwhen__then <- function(statement) {
  as_polars_expr(statement)$`_rexpr` |>
    self$`_chained_when`$then() |>
    wrap()
}

# The env storing then methods
polars_chainedthen__methods <- new.env(parent = emptyenv())

#' @export
wrap.PlRChainedThen <- function(x, ...) {
  self <- new.env(parent = emptyenv())
  self$`_chained_then` <- x
  makeActiveBinding("_rexpr", function() self$`_chained_then`$otherwise(lit_null()), self)

  lapply(names(polars_namespaces_expr), function(namespace) {
    makeActiveBinding(namespace, function() polars_namespaces_expr[[namespace]](self), self)
  })

  class(self) <- c("polars_chained_then", "polars_expr", "polars_object")
  self
}

chainedthen__when <- function(...) {
  parse_predicates_constraints_into_expression(...) |>
    self$`_chained_then`$when() |>
    wrap()
}

chainedthen__otherwise <- function(otherwise) {
  as_polars_expr(otherwise)$`_rexpr` |>
    self$`_chained_then`$otherwise() |>
    wrap()
}
