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

  class(self) <- c("polars_expr", "polars_object")
  self
}

expr__add <- function(other) {
  other <- as_polars_expr(other)
  self$`_rexpr`$add(other$`_rexpr`) |>
    wrap()
}

expr__sub <- function(other) {
  other <- as_polars_expr(other)
  self$`_rexpr`$sub(other$`_rexpr`) |>
    wrap()
}

expr__mul <- function(other) {
  other <- as_polars_expr(other)
  self$`_rexpr`$mul(other$`_rexpr`) |>
    wrap()
}

expr__true_div <- function(other) {
  other <- as_polars_expr(other)
  self$`_rexpr`$div(other$`_rexpr`) |>
    wrap()
}

expr__mod <- function(other) {
  other <- as_polars_expr(other)
  self$`_rexpr`$rem(other$`_rexpr`) |>
    wrap()
}

expr__floor_div <- function(other) {
  other <- as_polars_expr(other)
  self$`_rexpr`$floor_div(other$`_rexpr`) |>
    wrap()
}

expr__neg <- function() {
  self$`_rexpr`$neg() |>
    wrap()
}

expr__eq <- function(other) {
  other <- as_polars_expr(other, str_as_lit = TRUE)
  self$`_rexpr`$eq(other$`_rexpr`) |>
    wrap()
}

expr__eq_missing <- function(other) {
  other <- as_polars_expr(other, str_as_lit = TRUE)
  self$`_rexpr`$eq_missing(other$`_rexpr`) |>
    wrap()
}

expr__neq <- function(other) {
  other <- as_polars_expr(other, str_as_lit = TRUE)
  self$`_rexpr`$neq(other$`_rexpr`) |>
    wrap()
}

expr__neq_missing <- function(other) {
  other <- as_polars_expr(other, str_as_lit = TRUE)
  self$`_rexpr`$neq_missing(other$`_rexpr`) |>
    wrap()
}

expr__gt <- function(other) {
  other <- as_polars_expr(other, str_as_lit = TRUE)
  self$`_rexpr`$gt(other$`_rexpr`) |>
    wrap()
}

expr__gt_eq <- function(other) {
  other <- as_polars_expr(other, str_as_lit = TRUE)
  self$`_rexpr`$gt_eq(other$`_rexpr`) |>
    wrap()
}

expr__lt_eq <- function(other) {
  other <- as_polars_expr(other, str_as_lit = TRUE)
  self$`_rexpr`$lt_eq(other$`_rexpr`) |>
    wrap()
}

expr__lt <- function(other) {
  other <- as_polars_expr(other, str_as_lit = TRUE)
  self$`_rexpr`$lt(other$`_rexpr`) |>
    wrap()
}

expr__alias <- function(name) {
  self$`_rexpr`$alias(name) |>
    wrap()
}

expr__not <- function() {
  self$`_rexpr`$not() |>
    wrap()
}

expr__is_null <- function() {
  self$`_rexpr`$is_null() |>
    wrap()
}

expr__is_not_null <- function() {
  self$`_rexpr`$is_not_null() |>
    wrap()
}

expr__is_infinite <- function() {
  self$`_rexpr`$is_infinite() |>
    wrap()
}

expr__is_finite <- function() {
  self$`_rexpr`$is_finite() |>
    wrap()
}

expr__is_nan <- function() {
  self$`_rexpr`$is_nan() |>
    wrap()
}

expr__is_not_nan <- function() {
  self$`_rexpr`$is_not_nan() |>
    wrap()
}

expr__cast <- function(dtype, ..., strict = TRUE) {
  dtype <- as_polars_dtype(dtype)
  self$`_rexpr`$cast(dtype$`_dt`, strict) |>
    wrap()
}

expr__and <- function(other) {
  other <- as_polars_expr(other)
  self$`_rexpr`$and(other$`_rexpr`) |>
    wrap()
}

expr__or <- function(other) {
  other <- as_polars_expr(other)
  self$`_rexpr`$or(other$`_rexpr`) |>
    wrap()
}

expr__xor <- function(other) {
  other <- as_polars_expr(other)
  self$`_rexpr`$xor(other$`_rexpr`) |>
    wrap()
}

expr__reshape <- function(dimensions) {
  self$`_rexpr`$reshape(dimensions) |>
    wrap()
}
