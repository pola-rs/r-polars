# The env storing expr namespaces
polars_namespaces_expr <- new.env(parent = emptyenv())

# The env storing expr methods
polars_expr__methods <- new.env(parent = emptyenv())

#' @export
wrap.PlRExpr <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x

  lapply(names(polars_expr__methods), function(name) {
    fn <- polars_expr__methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  lapply(names(polars_namespaces_expr), function(namespace) {
    makeActiveBinding(namespace, function() polars_namespaces_expr[[namespace]](self), self)
  })

  class(self) <- "polars_expr"
  self
}

expr__add <- function(other) {
  other <- as_polars_expr(other, str_as_lit = TRUE)
  self$`_rexpr`$add(other$`_rexpr`) |>
    wrap()
}

expr__sub <- function(other) {
  other <- as_polars_expr(other, str_as_lit = TRUE)
  self$`_rexpr`$sub(other$`_rexpr`) |>
    wrap()
}

expr__mul <- function(other) {
  other <- as_polars_expr(other, str_as_lit = TRUE)
  self$`_rexpr`$mul(other$`_rexpr`) |>
    wrap()
}

expr__true_div <- function(other) {
  other <- as_polars_expr(other, str_as_lit = TRUE)
  self$`_rexpr`$div(other$`_rexpr`) |>
    wrap()
}

expr__mod <- function(other) {
  other <- as_polars_expr(other, str_as_lit = TRUE)
  self$`_rexpr`$rem(other$`_rexpr`) |>
    wrap()
}

expr__floor_div <- function(other) {
  other <- as_polars_expr(other, str_as_lit = TRUE)
  self$`_rexpr`$floor_div(other$`_rexpr`) |>
    wrap()
}

expr__neg <- function() {
  self$`_rexpr`$neg() |>
    wrap()
}

expr__cast <- function(dtype, ..., strict = TRUE) {
  dtype <- as_polars_dtype(dtype)
  self$`_rexpr`$cast(dtype$`_dt`, strict) |>
    wrap()
}
