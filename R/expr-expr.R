# The env storing expr namespaces
polars_namespaces_expr <- new.env(parent = emptyenv())

# The env storing expr methods
polars_expr__methods <- new.env(parent = emptyenv())

#' @export
is_polars_expr <- function(x, ...) {
  inherits(x, "polars_expr")
}

#' @export
wrap.PlRExpr <- function(x, ...) {
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

pl__deserialize_expr <- function(data, ..., format = "binary") {
  wrap({
    check_dots_empty0(...)
    check_string(format)

    if (format == "binary") {
      PlRExpr$deserialize_binary(data)
    } else if (format == "json") {
      PlRExpr$deserialize_json(data)
    } else {
      abort(
        sprintf("`format` must be one of ('binary', 'json'), got '%s'", format)
      )
    }
  })
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

# Beacuse the $not method and the $invert method are distinguished in the selector,
# this is only necessary to map the $invert method to the `!` operator.
expr__invert <- expr__not

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

expr__min <- function() {
  self$`_rexpr`$min() |>
    wrap()
}

expr__max <- function() {
  self$`_rexpr`$max() |>
    wrap()
}

expr__nan_max <- function() {
  self$`_rexpr`$nan_max() |>
    wrap()
}

expr__nan_min <- function() {
  self$`_rexpr`$nan_min() |>
    wrap()
}

expr__mean <- function() {
  self$`_rexpr`$mean() |>
    wrap()
}

expr__median <- function() {
  self$`_rexpr`$median() |>
    wrap()
}

expr__sum <- function() {
  self$`_rexpr`$sum() |>
    wrap()
}

expr__cast <- function(dtype, ..., strict = TRUE) {
  wrap({
    check_dots_empty0(...)

    dtype <- as_polars_dtype(dtype)
    self$`_rexpr`$cast(dtype$`_dt`, strict)
  })
}

expr__sort_by <- function(
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

    self$`_rexpr`$sort_by(by, descending, nulls_last, multithreaded, maintain_order)
  })
}

expr__reverse <- function() {
  self$`_rexpr`$reverse() |>
    wrap()
}

expr__first <- function() {
  self$`_rexpr`$first() |>
    wrap()
}

expr__last <- function() {
  self$`_rexpr`$last() |>
    wrap()
}

expr__over <- function(
    ...,
    order_by = NULL,
    mapping_strategy = "group_to_rows") {
  wrap({
    check_dots_unnamed()

    partition_by <- parse_into_list_of_expressions(...)
    if (!is.null(order_by)) {
      order_by <- parse_into_list_of_expressions(!!!order_by)
    }

    self$`_rexpr`$over(
      partition_by,
      order_by = order_by,
      order_by_descending = FALSE, # does not work yet
      order_by_nulls_last = FALSE, # does not work yet
      mapping_strategy = mapping_strategy
    )
  })
}

expr__filter <- function(...) {
  parse_predicates_constraints_into_expression(...) |>
    self$`_rexpr`$filter() |>
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

expr__any <- function(..., ignore_nulls = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$any(ignore_nulls)
  })
}

expr__all <- function(..., ignore_nulls = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$all(ignore_nulls)
  })
}
