# TODO: link to data type docs
# TODO: section for name spaces
# source: https://docs.pola.rs/user-guide/concepts/expressions/
#' Polars expression class (`polars_expr`)
#'
#' An expression is a tree of operations that describe how to construct one or more [Series].
#' As the outputs are [Series], it is straightforward to apply a sequence of expressions each of
#' which transforms the output from the previous step.
#' See examples for details.
#' @name polars_expr
#' @aliases Expr expression
#' @seealso
#' - [`pl$lit()`][pl__lit]: Create a literal expression.
#' - [`pl$col()`][pl__col]: Create an expression representing column(s) in a [DataFrame].
#' @examples
#' # An expression:
#' # 1. Select column `foo`,
#' # 2. Then sort the column (not in reversed order)
#' # 3. Then take the first two values of the sorted output
#' pl$col("foo")$sort()$head(2)
#'
#' # Expressions will be evaluated inside a context, such as `<DataFrame>$select()`
#' df <- pl$DataFrame(
#'   foo = c(1, 2, 1, 2, 3),
#'   bar = c(5, 4, 3, 2, 1),
#' )
#'
#' df$select(
#'   pl$col("foo")$sort()$head(3), # Return 3 values
#'   pl$col("bar")$filter(pl$col("foo") == 1)$sum(), # Return a single value
#' )
NULL

# The env storing expr namespaces
polars_namespaces_expr <- new.env(parent = emptyenv())

# The env storing expr methods
polars_expr__methods <- new.env(parent = emptyenv())

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

pl__deserialize_expr <- function(data, ..., format = c("binary", "json")) {
  wrap({
    check_dots_empty0(...)

    format <- arg_match0(format, c("binary", "json"))

    switch(format,
      binary = PlRExpr$deserialize_binary(data),
      json = PlRExpr$deserialize_json(data),
      abort("Unreachable")
    )
  })
}

expr__add <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$add(other$`_rexpr`)
  })
}

expr__sub <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$sub(other$`_rexpr`)
  })
}

expr__mul <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$mul(other$`_rexpr`)
  })
}

expr__true_div <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$div(other$`_rexpr`)
  })
}

expr__pow <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$pow(other$`_rexpr`)
  })
}

expr__mod <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$rem(other$`_rexpr`)
  })
}

expr__floor_div <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$floor_div(other$`_rexpr`)
  })
}

expr__neg <- function() {
  self$`_rexpr`$neg() |>
    wrap()
}

expr__eq <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$eq(other$`_rexpr`)
  })
}

expr__eq_missing <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$eq_missing(other$`_rexpr`)
  })
}

expr__neq <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$neq(other$`_rexpr`)
  })
}

expr__neq_missing <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$neq_missing(other$`_rexpr`)
  })
}

expr__gt <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$gt(other$`_rexpr`)
  })
}

expr__gt_eq <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$gt_eq(other$`_rexpr`)
  })
}

expr__lt_eq <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$lt_eq(other$`_rexpr`)
  })
}

expr__lt <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$lt(other$`_rexpr`)
  })
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

expr__cast <- function(dtype, ..., strict = TRUE, wrap_numerical = FALSE) {
  wrap({
    check_dots_empty0(...)
    check_polars_dtype(dtype)

    self$`_rexpr`$cast(dtype$`_dt`, strict, wrap_numerical)
  })
}

expr__sort <- function(..., descending = FALSE, nulls_last = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$sort_with(descending, nulls_last)
  })
}

expr__arg_sort <- function(..., descending = FALSE, nulls_last = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$arg_sort(descending, nulls_last)
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

expr__slice <- function(offset, length = NULL) {
  self$`_rexpr`$slice(
    as_polars_expr(
      offset,
      as_lit = TRUE
    )$`_rexpr`$cast(pl$Int64$`_dt`, strict = FALSE, wrap_numerical = TRUE),
    as_polars_expr(
      length,
      as_lit = TRUE
    )$`_rexpr`$cast(pl$Int64$`_dt`, strict = FALSE, wrap_numerical = TRUE)
  ) |>
    wrap()
}

expr__head <- function(n = 10) {
  self$slice(0, n) |>
    wrap()
}

expr__tail <- function(n = 10) {
  wrap({
    # Supports unsigned integers
    offset <- -as_polars_expr(n, as_lit = TRUE)$cast(pl$Int64, strict = FALSE, wrap_numerical = TRUE)
    self$slice(offset, n)
  })
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
    mapping_strategy = c("group_to_rows", "join", "explode")) {
  wrap({
    check_dots_unnamed()

    partition_by <- parse_into_list_of_expressions(...)
    if (!is.null(order_by)) {
      order_by <- parse_into_list_of_expressions(!!!order_by)
    }
    mapping_strategy <- arg_match0(mapping_strategy, c("group_to_rows", "join", "explode"))

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

expr__map_batches <- function(
    lambda,
    return_dtype = NULL,
    ...,
    agg_list = FALSE) {
  wrap({
    check_dots_empty0(...)
    check_function(lambda)
    check_polars_dtype(return_dtype, allow_null = TRUE)

    self$`_rexpr`$map_batches(
      lambda = function(series) {
        as_polars_series(lambda(wrap(.savvy_wrap_PlRSeries(series))))$`_s`
      },
      output_type = return_dtype$`_dt`,
      agg_list = agg_list
    )
  })
}

expr__and <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$and(other$`_rexpr`)
  })
}

expr__or <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$or(other$`_rexpr`)
  })
}

expr__xor <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$xor(other$`_rexpr`)
  })
}

expr__diff <- function(n = 1, null_behavior = c("ignore", "drop")) {
  wrap({
    null_behavior <- arg_match0(null_behavior, c("ignore", "drop"))
    self$`_rexpr`$diff(n, null_behavior)
  })
}

expr__reshape <- function(dimensions) {
  wrap({
    if (is.numeric(dimensions) && anyNA(dimensions)) {
      abort("`dimensions` must not contain any NA values.")
    }
    self$`_rexpr`$reshape(dimensions)
  })
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
