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

    # fmt: skip
    switch(format,
      binary = PlRExpr$deserialize_binary(data),
      json = PlRExpr$deserialize_json(data),
      abort("Unreachable")
    )
  })
}

#' Add two expressions
#'
#' Method equivalent of addition operator `expr + other`.
#' @param other Element to add. Can be a string (only if `expr` is a string), a
#' numeric value or an other expression.
#' @inherit as_polars_expr return
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' @examples
#' df <- pl$DataFrame(x = 1:5)
#'
#' df$with_columns(
#'   `x+int` = pl$col("x")$add(2L),
#'   `x+expr` = pl$col("x")$add(pl$col("x")$cum_prod())
#' )
#'
#' df <- pl$DataFrame(
#'   x = c("a", "d", "g"),
#'   y = c("b", "e", "h"),
#'   z = c("c", "f", "i")
#' )
#'
#' df$with_columns(
#'   pl$col("x")$add(pl$col("y"))$add(pl$col("z"))$alias("xyz")
#' )
expr__add <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$add(other$`_rexpr`)
  })
}

#' Substract two expressions
#'
#' Method equivalent of subtraction operator `expr - other`.
#' @inheritParams expr__true_div
#' @inherit as_polars_expr return
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' @examples
#' df <- pl$DataFrame(x = 0:4)
#'
#' df$with_columns(
#'   `x-2` = pl$col("x")$sub(2),
#'   `x-expr` = pl$col("x")$sub(pl$col("x")$cum_sum())
#' )
expr__sub <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$sub(other$`_rexpr`)
  })
}

#' Multiply two expressions
#'
#' Method equivalent of multiplication operator `expr * other`.
#' @inheritParams expr__true_div
#' @inherit as_polars_expr return
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' @examples
#' df <- pl$DataFrame(x = c(1, 2, 4, 8, 16))
#'
#' df$with_columns(
#'   `x*2` = pl$col("x")$mul(2),
#'   `x * xlog2` = pl$col("x")$mul(pl$col("x")$log(2))
#' )
expr__mul <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$mul(other$`_rexpr`)
  })
}

#' Divide two expressions
#'
#' Method equivalent of float division operator `expr / other`.
#' `$truediv()` is an alias for `$true_div()`, which exists for compatibility
#' with Python Polars.
#'
#' Zero-division behaviour follows IEEE-754:
#' - `0/0`: Invalid operation - mathematically undefined, returns `NaN`.
#' - `n/0`: On finite operands gives an exact infinite result, e.g.: ±infinity.
#' @inherit as_polars_expr return
#' @param other Numeric literal or expression value.
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' - [`<Expr>$floor_div()`][Expr_floor_div]
#' @examples
#' df <- pl$DataFrame(
#'   x = -2:2,
#'   y = c(0.5, 0, 0, -4, -0.5)
#' )
#'
#' df$with_columns(
#'   `x/2` = pl$col("x")$true_div(2),
#'   `x/y` = pl$col("x")$true_div(pl$col("y"))
#' )
expr__true_div <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$div(other$`_rexpr`)
  })
}

#' @rdname expr__true_div
expr__truediv <- expr__true_div

#' Exponentiation using two expressions
#'
#' Method equivalent of exponentiation operator `expr ^ exponent`.
#'
#' @param exponent Numeric literal or expression value.
#' @inherit as_polars_expr return
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' @examples
#' df <- pl$DataFrame(x = c(1, 2, 4, 8))
#'
#' df$with_columns(
#'   cube = pl$col("x")$pow(3),
#'   `x^xlog2` = pl$col("x")$pow(pl$col("x")$log(2))
#' )
expr__pow <- function(exponent) {
  wrap({
    exponent <- as_polars_expr(exponent, as_lit = TRUE)
    self$`_rexpr`$pow(exponent$`_rexpr`)
  })
}

#' Modulo using two expressions
#'
#' Method equivalent of modulus operator `expr %% other`.
#' @inheritParams expr__true_div
#' @inherit as_polars_expr return
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' - [`<Expr>$floor_div()`][expr__floor_div]
#' @examples
#' df <- pl$DataFrame(x = -5L:5L)
#'
#' df$with_columns(
#'   `x%%2` = pl$col("x")$mod(2)
#' )
expr__mod <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$rem(other$`_rexpr`)
  })
}

#' Floor divide using two expressions
#'
#' Method equivalent of floor division operator `expr %/% other`.
#' `$floordiv()` is an alias for `$floor_div()`, which exists for compatibility
#' with Python Polars.
#' @inheritParams expr__true_div
#' @inherit as_polars_expr return
#' @seealso
#' - [Arithmetic operators][S3_arithmetic]
#' - [`<Expr>$true_div()`][expr__true_div]
#' - [`<Expr>$mod()`][expr__mod]
#' @examples
#' df <- pl$DataFrame(x = 1:5)
#'
#' df$with_columns(
#'   `x/2` = pl$col("x")$true_div(2),
#'   `x%/%2` = pl$col("x")$floor_div(2)
#' )
expr__floor_div <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$floor_div(other$`_rexpr`)
  })
}

#' @rdname expr__floor_div
expr__floordiv <- expr__floor_div

expr__neg <- function() {
  self$`_rexpr`$neg() |>
    wrap()
}

#' Check equality
#'
#' This propagates null values, i.e. any comparison involving `null` will
#' return `null`. Use [`$eq_missing()`][expr__eq_missing] to consider null
#' values as equal.
#'
#' @param other A literal or expression value to compare with.
#' @inherit as_polars_expr return
#'
#' @seealso [expr__eq_missing]
#' @examples
#' df <- pl$DataFrame(x = c(NA, FALSE, TRUE), y = c(TRUE, TRUE, TRUE))
#' df$with_columns(
#'   eq = pl$col("x")$eq(pl$col("y")),
#'   eq_missing = pl$col("x")$eq_missing(pl$col("y"))
#' )
expr__eq <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$eq(other$`_rexpr`)
  })
}

#' Check equality without `null` propagation
#'
#' This considers that null values are equal. It differs from
#' [`$eq()`][expr__eq] where null values are propagated.
#'
#' @inheritParams expr__eq
#' @inherit as_polars_expr return
#'
#' @seealso [expr__eq]
#' @examples
#' df <- pl$DataFrame(x = c(NA, FALSE, TRUE), y = c(TRUE, TRUE, TRUE))
#' df$with_columns(
#'   eq = pl$col("x")$eq("y"),
#'   eq_missing = pl$col("x")$eq_missing("y")
#' )
expr__eq_missing <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$eq_missing(other$`_rexpr`)
  })
}

#' Check inequality
#'
#' This propagates null values, i.e. any comparison involving `null` will
#' return `null`. Use [`$ne_missing()`][expr__ne_missing] to consider null
#' values as equal.
#'
#' @inheritParams expr__eq
#' @inherit as_polars_expr return
#'
#' @seealso [expr__ne_missing]
#' @examples
#' df <- pl$DataFrame(x = c(NA, FALSE, TRUE), y = c(TRUE, TRUE, TRUE))
#' df$with_columns(
#'   ne = pl$col("x")$ne(pl$col("y")),
#'   ne_missing = pl$col("x")$ne_missing(pl$col("y"))
#' )
expr__ne <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$neq(other$`_rexpr`)
  })
}

#' Check inequality without `null` propagation
#'
#' @inherit expr__add description params
#' @inherit as_polars_expr return
#'
#' @seealso [expr__ne]
#' @examples
#' df <- pl$DataFrame(x = c(NA, FALSE, TRUE), y = c(TRUE, TRUE, TRUE))
#' df$with_columns(
#'   ne = pl$col("x")$ne("y"),
#'   ne_missing = pl$col("x")$ne_missing("y")
#' )
expr__ne_missing <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$neq_missing(other$`_rexpr`)
  })
}

#' Check greater or equal inequality
#'
#' @inheritParams expr__eq
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(x = 1:3)
#' df$with_columns(
#'   with_gt = pl$col("x")$gt(pl$lit(2)),
#'   with_symbol = pl$col("x") > pl$lit(2)
#' )
expr__gt <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$gt(other$`_rexpr`)
  })
}

#' Check greater or equal inequality
#'
#' @inheritParams expr__eq
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(x = 1:3)
#' df$with_columns(
#'   with_ge = pl$col("x")$ge(pl$lit(2)),
#'   with_symbol = pl$col("x") >= pl$lit(2)
#' )
expr__ge <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$gt_eq(other$`_rexpr`)
  })
}

#' Check lower or equal inequality
#'
#' @inheritParams expr__eq
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(x = 1:3)
#' df$with_columns(
#'   with_le = pl$col("x")$le(pl$lit(2)),
#'   with_symbol = pl$col("x") <= pl$lit(2)
#' )
expr__le <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$lt_eq(other$`_rexpr`)
  })
}

#' Check strictly lower inequality
#'
#' @inheritParams expr__eq
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(x = 1:3)
#' df$with_columns(
#'   with_lt = pl$col("x")$lt(pl$lit(2)),
#'   with_symbol = pl$col("x") < pl$lit(2)
#' )
expr__lt <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$lt(other$`_rexpr`)
  })
}

#' Rename the expression
#'
#' @param name The new name.
#'
#' @inherit as_polars_expr return
#' @examples
#' # Rename an expression to avoid overwriting an existing column
#' df <- pl$DataFrame(a = 1:3, b = c("x", "y", "z"))
#' df$with_columns(
#'   pl$col("a") + 10,
#'   pl$col("b")$str$to_uppercase()$alias("c")
#' )
#'
#' # Overwrite the default name of literal columns to prevent errors due to
#' # duplicate column names.
#' df$with_columns(
#'   pl$lit(TRUE)$alias("c"),
#'   pl$lit(4)$alias("d")
#' )
expr__alias <- function(name) {
  self$`_rexpr`$alias(name) |>
    wrap()
}


#' Exclude columns from a multi-column expression.
#'
#' @param ... The name or datatype of the column(s) to exclude. Accepts regular
#' expression input. Regular expressions should start with `^` and end with `$`.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(aa = 1:2, ba = c("a", NA), cc = c(NA, 2.5))
#' df
#'
#' # Exclude by column name(s):
#' df$select(pl$all()$exclude("ba"))
#'
#' # Exclude by regex, e.g. removing all columns whose names end with the
#' # letter "a":
#' df$select(pl$all()$exclude("^.*a$"))
#'
#' # Exclude by dtype(s), e.g. removing all columns of type Int64 or Float64:
#' df$select(pl$all()$exclude(pl$Int64, pl$Float64))
expr__exclude <- function(...) {
  wrap({
    check_dots_unnamed()
    by <- list2(...)
    exclude_cols <- Filter(is_string, by)
    exclude_dtypes <- Filter(is_polars_dtype, by)

    unknown <- Filter(
      \(x) !is_string(x) && !is_polars_dtype(x),
      by
    )

    if (length(unknown) > 0 || length(exclude_cols) > 0 && length(exclude_dtypes) > 0) {
      abort(
        c(
          "Invalid `...` elements.",
          `*` = "All elements in `...` must be either single strings or Polars data types.",
          i = "`cs$exclude()` accepts mixing column names and Polars data types."
        )
      )
    } else if (length(exclude_cols) > 0) {
      self$`_rexpr`$exclude(unlist(exclude_cols))
    } else if (length(exclude_dtypes) > 0) {
      exclude_dtypes <- lapply(exclude_dtypes, \(x) x$`_dt`)
      self$`_rexpr`$exclude_dtype(exclude_dtypes)
    }
  })
}


#' Negate a boolean expression
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(TRUE, FALSE, FALSE, NA))
#'
#' df$with_columns(a_not = pl$col("a")$not())
#'
#' # Same result with "!"
#' df$with_columns(a_not = !pl$col("a"))
expr__not <- function() {
  self$`_rexpr`$not() |>
    wrap()
}

# Beacuse the $not method and the $invert method are distinguished in the selector,
# this is only necessary to map the $invert method to the `!` operator.

expr__invert <- expr__not

#' Check if elements are NULL
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 2, NA, 1, 5),
#'   b = c(1, 2, NaN, 1, 5)
#' )
#' df$with_columns(
#'   a_null = pl$col("a")$is_null(),
#'   b_null = pl$col("b")$is_null()
#' )
expr__is_null <- function() {
  self$`_rexpr`$is_null() |>
    wrap()
}

#' Check if elements are not NULL
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 2, NA, 1, 5),
#'   b = c(1, 2, NaN, 1, 5)
#' )
#' df$with_columns(
#'   a_not_null = pl$col("a")$is_not_null(),
#'   b_not_null = pl$col("b")$is_not_null()
#' )
expr__is_not_null <- function() {
  self$`_rexpr`$is_not_null() |>
    wrap()
}

#' Check if elements are infinite
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 2), b = c(3, Inf))
#' df$with_columns(
#'   a_infinite = pl$col("a")$is_infinite(),
#'   b_infinite = pl$col("b")$is_infinite()
#' )
expr__is_infinite <- function() {
  self$`_rexpr`$is_infinite() |>
    wrap()
}

#' Check if elements are finite
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 2), b = c(3, Inf))
#' df$with_columns(
#'   a_finite = pl$col("a")$is_finite(),
#'   b_finite = pl$col("b")$is_finite()
#' )
expr__is_finite <- function() {
  self$`_rexpr`$is_finite() |>
    wrap()
}

#' Check if elements are NaN
#'
#' Floating point `NaN` (Not A Number) should not be confused with missing data
#' represented as `NA` (in R) or `null` (in Polars).
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 2, NA, 1, 5),
#'   b = c(1, 2, NaN, 1, 5)
#' )
#' df$with_columns(
#'   a_nan = pl$col("a")$is_nan(),
#'   b_nan = pl$col("b")$is_nan()
#' )
expr__is_nan <- function() {
  self$`_rexpr`$is_nan() |>
    wrap()
}

#' Check if elements are not NaN
#'
#' @inherit expr__is_nan description
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 2, NA, 1, 5),
#'   b = c(1, 2, NaN, 1, 5)
#' )
#' df$with_columns(
#'   a_not_nan = pl$col("a")$is_not_nan(),
#'   b_not_nan = pl$col("b")$is_not_nan()
#' )
expr__is_not_nan <- function() {
  self$`_rexpr`$is_not_nan() |>
    wrap()
}

#' Get the minimum value
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(x = c(1, NaN, 3))$
#'   with_columns(min = pl$col("x")$min())
expr__min <- function() {
  self$`_rexpr`$min() |>
    wrap()
}

#' Get the maximum value
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(x = c(1, NaN, 3))$
#'   with_columns(max = pl$col("x")$max())
expr__max <- function() {
  self$`_rexpr`$max() |>
    wrap()
}

#' Get the maximum value with NaN
#'
#' This returns `NaN` if there are any.
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(x = c(1, NA, 3, NaN, Inf))$
#'   with_columns(nan_max = pl$col("x")$nan_max())
expr__nan_max <- function() {
  self$`_rexpr`$nan_max() |>
    wrap()
}

#' Get the minimum value with NaN
#'
#' This returns `NaN` if there are any.
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(x = c(1, NA, 3, NaN, Inf))$
#'   with_columns(nan_min = pl$col("x")$nan_min())
expr__nan_min <- function() {
  self$`_rexpr`$nan_min() |>
    wrap()
}

#' Get mean value
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(x = c(1, 3, 4, NA))$
#'   with_columns(mean = pl$col("x")$mean())
expr__mean <- function() {
  self$`_rexpr`$mean() |>
    wrap()
}

#' Get median value
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(x = c(1, 3, 4, NA))$
#'   with_columns(median = pl$col("x")$median())
expr__median <- function() {
  self$`_rexpr`$median() |>
    wrap()
}

#' Get sum value
#'
#' @details
#' The dtypes Int8, UInt8, Int16 and UInt16 are cast to Int64 before summing to
#' prevent overflow issues.
#'
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(x = c(1L, NA, 2L))$
#'   with_columns(sum = pl$col("x")$sum())
expr__sum <- function() {
  self$`_rexpr`$sum() |>
    wrap()
}

#' Cast between DataType
#'
#' @inheritParams rlang::args_dots_empty
#' @param dtype DataType to cast to.
#' @param strict If `TRUE` (default), an error will be thrown if cast failed at
#' resolve time.
#' @param wrap_numerical If `TRUE`, numeric casts wrap overflowing values
#' instead of marking the cast as invalid.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:3, b = c(1, 2, 3))
#' df$with_columns(
#'   pl$col("a")$cast(pl$Float64),
#'   pl$col("b")$cast(pl$Int32)
#' )
#'
#' # strict FALSE, inserts null for any cast failure
#' pl$select(
#'   pl$lit(c(100, 200, 300))$cast(pl$UInt8, strict = FALSE)
#' )$to_series()
#'
#' # strict TRUE, raise any failure as an error when query is executed.
#' tryCatch(
#'   {
#'     pl$select(
#'       pl$lit("a")$cast(pl$Float64, strict = TRUE)
#'     )$to_series()
#'   },
#'   error = function(e) e
#' )
expr__cast <- function(dtype, ..., strict = TRUE, wrap_numerical = FALSE) {
  wrap({
    check_dots_empty0(...)
    check_polars_dtype(dtype)

    self$`_rexpr`$cast(dtype$`_dt`, strict, wrap_numerical)
  })
}

#' Sort this expression
#'
#' If used in a groupby context, values within each group are sorted.
#'
#' @inheritParams rlang::args_dots_empty
#' @param descending Sort in descending order.
#' @param nulls_last Place null values last.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(6, 1, 0, NA, Inf, NaN))
#'
#' df$with_columns(
#'   sorted = pl$col("a")$sort(),
#'   sorted_desc = pl$col("a")$sort(descending = TRUE),
#'   sorted_nulls_last = pl$col("a")$sort(nulls_last = TRUE)
#' )
#'
#' # When sorting in a group by context, values in each group are sorted.
#' df <- pl$DataFrame(
#'   group = c("one", "one", "one", "two", "two", "two"),
#'   value = c(1, 98, 2, 3, 99, 4)
#' )
#'
#' df$group_by("group")$agg(pl$col("value")$sort())
expr__sort <- function(..., descending = FALSE, nulls_last = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$sort_with(descending, nulls_last)
  })
}

#' Index of a sort
#'
#' Get the index values that would sort this column.
#'
#' @inheritParams expr__sort
#' @inherit as_polars_expr return
#' @seealso [pl$arg_sort_by()][pl_arg_sort_by()] to find the row indices that would
#' sort multiple columns.
#' @examples
#' pl$DataFrame(
#'   a = c(6, 1, 0, NA, Inf, NaN)
#' )$with_columns(arg_sorted = pl$col("a")$arg_sort())
expr__arg_sort <- function(..., descending = FALSE, nulls_last = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$arg_sort(descending, nulls_last)
  })
}

#' Sort this column by the ordering of another column, or multiple other
#' columns.
#'
#' @inherit expr__sort description
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Column(s) to sort by. Accepts
#' expression input. Strings are parsed as column names.
#' @param descending Sort in descending order. When sorting by multiple
#' columns, can be specified per column by passing a sequence of booleans.
#' @param nulls_last Place null values last; can specify a single boolean
#' applying to all columns or a sequence of booleans for per-column control.
#' @param multithreaded Sort using multiple threads.
#' @param maintain_order Whether the order should be maintained if elements are
#' equal.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   group = c("a", "a", "b", "b"),
#'   value1 = c(1, 3, 4, 2),
#'   value2 = c(8, 7, 6, 5)
#' )
#'
#' # by one column/expression
#' df$with_columns(
#'   sorted = pl$col("group")$sort_by("value1")
#' )
#'
#' # by two columns/expressions
#' df$with_columns(
#'   sorted = pl$col("group")$sort_by(
#'     "value2", pl$col("value1"),
#'     descending = c(TRUE, FALSE)
#'   )
#' )
#'
#' # by some expression
#' df$with_columns(
#'   sorted = pl$col("group")$sort_by(pl$col("value1") + pl$col("value2"))
#' )
#'
#' # in an aggregation context, values are sorted within groups
#' df$group_by("group")$agg(
#'   pl$col("value1")$sort_by("value2")
#' )
expr__sort_by <- function(
  ...,
  descending = FALSE,
  nulls_last = FALSE,
  multithreaded = TRUE,
  maintain_order = FALSE
) {
  wrap({
    check_dots_unnamed()

    by <- parse_into_list_of_expressions(...)
    descending <- extend_bool(descending, length(by), "descending", "...")
    nulls_last <- extend_bool(nulls_last, length(by), "nulls_last", "...")

    self$`_rexpr`$sort_by(by, descending, nulls_last, multithreaded, maintain_order)
  })
}

#' Reverse an expression
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = 1:5,
#'   fruits = c("banana", "banana", "apple", "apple", "banana"),
#'   b = 5:1
#' )
#'
#' df$with_columns(
#'   pl$all()$reverse()$name$suffix("_reverse")
#' )
expr__reverse <- function() {
  self$`_rexpr`$reverse() |>
    wrap()
}


#' Get a slice of this expression
#'
#' @param offset Numeric or expression, zero-indexed. Indicates where to start
#' the slice. A negative value is one-indexed and starts from the end.
#' @param length Maximum number of elements contained in the slice. If `NULL`
#' (default), all rows starting at the offset will be selected.
#'
#' @inherit as_polars_expr return
#' @examples
#' # as head
#' pl$DataFrame(a = 0:100)$select(
#'   pl$all()$slice(0, 6)
#' )
#'
#' # as tail
#' pl$DataFrame(a = 0:100)$select(
#'   pl$all()$slice(-6, 6)
#' )
#'
#' pl$DataFrame(a = 0:100)$select(
#'   pl$all()$slice(80)
#' )
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

#' Get the first n elements
#'
#' @param n Number of elements to take.
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(x = 1:11)$select(pl$col("x")$head(3))
expr__head <- function(n = 10) {
  self$slice(0, n) |>
    wrap()
}

#' Get the last n elements
#'
#' @inheritParams expr__head
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' pl$DataFrame(x = 1:11)$select(pl$col("x")$tail(3))
expr__tail <- function(n = 10) {
  wrap({
    # Supports unsigned integers
    offset <- -as_polars_expr(n, as_lit = TRUE)$cast(
      pl$Int64,
      strict = FALSE,
      wrap_numerical = TRUE
    )
    self$slice(offset, n)
  })
}

#' Get the first value
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(x = 3:1)$with_columns(first = pl$col("x")$first())
expr__first <- function() {
  self$`_rexpr`$first() |>
    wrap()
}

#' Get the last value
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(x = 3:1)$with_columns(last = pl$col("x")$last())
expr__last <- function() {
  self$`_rexpr`$last() |>
    wrap()
}

#' Compute expressions over the given groups
#'
#' This expression is similar to performing a group by aggregation and
#' joining the result back into the original [DataFrame].
#' The outcome is similar to how window functions work in
#' [PostgreSQL](https://www.postgresql.org/docs/current/tutorial-window.html).
#'
#' @param ... [`dynamic-dots`][rlang::dyn-dots]> Column(s) to group by. Accepts
#' expression input. Characters are parsed as column names.
#' @param order_by Order the window functions/aggregations with the partitioned
#' groups by the result of the expression passed to `order_by`. Accepts
#' expression input. Strings are parsed as column names.
#' @param mapping_strategy One of the following:
#' * `"group_to_rows"` (default): if the aggregation results in multiple values,
#'   assign them back to their position in the DataFrame. This can only be done
#'   if the group yields the same elements before aggregation as after.
#' * `"join"`: join the groups as `List<group_dtype>` to the row positions. Note
#'   that this can be memory intensive.
#' * `"explode"`: don’t do any mapping, but simply flatten the group. This only
#'   makes sense if the input data is sorted.
#'
#' @inherit as_polars_expr return
#' @examples
#' # Pass the name of a column to compute the expression over that column.
#' df <- pl$DataFrame(
#'   a = c("a", "a", "b", "b", "b"),
#'   b = c(1, 2, 3, 5, 3),
#'   c = c(5, 4, 2, 1, 3)
#' )
#'
#' df$with_columns(
#'   pl$col("c")$max()$over("a")$name$suffix("_max")
#' )
#'
#' # Expression input is supported.
#' df$with_columns(
#'   pl$col("c")$max()$over(pl$col("b") %/% 2)$name$suffix("_max")
#' )
#'
#' # Group by multiple columns by passing several column names a or list of
#' # expressions.
#' df$with_columns(
#'   pl$col("c")$min()$over("a", "b")$name$suffix("_min")
#' )
#'
#' group_vars <- list(pl$col("a"), pl$col("b"))
#' df$with_columns(
#'   pl$col("c")$min()$over(!!!group_vars)$name$suffix("_min")
#' )
#'
#' # Or use positional arguments to group by multiple columns in the same way.
#' df$with_columns(
#'   pl$col("c")$min()$over("a", pl$col("b") %% 2)$name$suffix("_min")
#' )
#'
#' # Alternative mapping strategy: join values in a list output
#' df$with_columns(
#'   top_2 = pl$col("c")$top_k(2)$over("a", mapping_strategy = "join")
#' )
#'
#' # order_by specifies how values are sorted within a group, which is
#' # essential when the operation depends on the order of values
#' df <- pl$DataFrame(
#'   g = c(1, 1, 1, 1, 2, 2, 2, 2),
#'   t = c(1, 2, 3, 4, 4, 1, 2, 3),
#'   x = c(10, 20, 30, 40, 10, 20, 30, 40)
#' )
#'
#' # without order_by, the first and second values in the second group would
#' # be inverted, which would be wrong
#' df$with_columns(
#'   x_lag = pl$col("x")$shift(1)$over("g", order_by = "t")
#' )
expr__over <- function(
  ...,
  order_by = NULL,
  mapping_strategy = c("group_to_rows", "join", "explode")
) {
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

#' Filter the expression based on one or more predicate expressions
#'
#' Elements where the filter does not evaluate to `TRUE` are discarded,
#' including nulls. This is mostly useful in an aggregation context. If you
#' want to filter on a DataFrame level, use
#' [`DataFrame$filter()`][dataframe__filter] or
#' [`LazyFrame$filter()`][lazyframe__filter].
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Expression(s) that evaluate
#' to a boolean Series.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   group_col = c("g1", "g1", "g2"),
#'   b = c(1, 2, 3)
#' )
#' df
#'
#' df$group_by("group_col")$agg(
#'   lt = pl$col("b")$filter(pl$col("b") < 2),
#'   gte = pl$col("b")$filter(pl$col("b") >= 2)
#' )
expr__filter <- function(...) {
  parse_predicates_constraints_into_expression(...) |>
    self$`_rexpr`$filter() |>
    wrap()
}

#' Apply a custom R function to a whole Series or sequence of Series.
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' The output of this custom function is presumed to be either a Series, or a
#' scalar that will be converted into a Series. If the result is a scalar and
#' you want it to stay as a scalar, pass in `returns_scalar = TRUE`.
#'
#' If you want to apply a custom function elementwise over single values, see
#' [map_elements()][expr__map_elements]. A reasonable use case for map
#' functions is transforming the values represented by an expression using a
#' third-party package.
#'
#' @inheritParams rlang::args_dots_empty
#' @param lambda Function to apply.
#' @param return_dtype Dtype of the output Series. If `NULL` (default), the
#' dtype will be inferred based on the first non-null value that is returned by
#' the function. This can lead to unexpected results, so it is recommended to
#' provide the return dtype.
#' @param agg_list Aggregate the values of the expression into a list before
#' applying the function. This parameter only works in a group-by context. The
#' function will be invoked only once on a list of groups, rather than once per
#' group.
# TODO: uncomment when those arguments are supported
# @param is_elementwise If `TRUE`, this can run in the streaming engine, but
# may yield incorrect results in group-by. Ensure you know what you are doing!
# @param returns_scalar If the function returns a scalar, by default it will
# be wrapped in a list in the output, since the assumption is that the
# function always returns something Series-like. If you want to keep the
# result as a scalar, set this argument to `TRUE`.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   sine = c(0.0, 1.0, 0.0, -1.0),
#'   cosine = c(1.0, 0.0, -1.0, 0.0)
#' )
#' df$select(pl$all()$map_batches(\(x) {
#'   elems <- as.vector(x)
#'   which.max(elems)
#' }))
#'
#' # In a group-by context, the `agg_list` parameter can improve performance if
#' # used correctly. The following example has `agg_list = FALSE`, which causes
#' # the function to be applied once per group. The input of the function is a
#' # Series of type Int64. This is less efficient.
#' df <- pl$DataFrame(
#'   a = c(0, 1, 0, 1),
#'   b = c(1, 2, 3, 4)
#' )
#' system.time({
#'   print(
#'     df$group_by("a")$agg(
#'       pl$col("b")$map_batches(\(x) x + 2, agg_list = FALSE)
#'     )
#'   )
#' })
#'
#' # Using `agg_list = TRUE` would be more efficient. In this example, the input
#' # of the function is a Series of type List(Int64).
#' system.time({
#'   print(
#'     df$group_by("a")$agg(
#'       pl$col("b")$map_batches(
#'         \(x) x$list$eval(pl$element() + 2),
#'         agg_list = TRUE
#'       )
#'     )
#'   )
#' })
#'
# TODO: uncomment when returns_scalar is supported
# # Here’s an example of a function that returns a scalar, where we want it to
# # stay as a scalar:
# df <- pl$DataFrame(
#   a = c(0, 1, 0, 1),
#   b = c(1, 2, 3, 4),
# )
# df$group_by("a")$agg(
#   pl$col("b")$map_batches(\(x) x$max(), returns_scalar = TRUE)
# )
#'
#' # Call a function that takes multiple arguments by creating a struct and
#' # referencing its fields inside the function call.
#' df <- pl$DataFrame(
#'   a = c(5, 1, 0, 3),
#'   b = c(4, 2, 3, 4),
#' )
#' df$with_columns(
#'   a_times_b = pl$struct("a", "b")$map_batches(
#'     \(x) x$struct$field("a") * x$struct$field("b")
#'   )
#' )
expr__map_batches <- function(
  lambda,
  return_dtype = NULL,
  ...,
  agg_list = FALSE
) {
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

#' Apply logical AND on two expressions
#'
#' Combine two boolean expressions with AND.
#' @inheritParams expr__add
#' @inherit as_polars_expr return
#' @examples
#' pl$lit(TRUE) & TRUE
#' pl$lit(TRUE)$and(pl$lit(TRUE))
expr__and <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$and(other$`_rexpr`)
  })
}

#' Apply logical OR on two expressions
#'
#' Combine two boolean expressions with OR.
#'
#' @inheritParams expr__add
#' @inherit as_polars_expr return
#' @examples
#' pl$lit(TRUE) | FALSE
#' pl$lit(TRUE)$or(pl$lit(TRUE))
expr__or <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$or(other$`_rexpr`)
  })
}

#' Apply logical XOR on two expressions
#'
#' Combine two boolean expressions with XOR.
#' @inheritParams expr__add
#' @inherit as_polars_expr return
#' @examples
#' pl$lit(TRUE)$xor(pl$lit(FALSE))
expr__xor <- function(other) {
  wrap({
    other <- as_polars_expr(other, as_lit = TRUE)
    self$`_rexpr`$xor(other$`_rexpr`)
  })
}

#' Calculate the n-th discrete difference between elements
#'
#' @param n Integer indicating the number of slots to shift.
#' @param null_behavior How to handle null values. Must be `"ignore"` (default),
#' or `"drop"`.
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(20, 10, 30, 25, 35))$with_columns(
#'   diff_default = pl$col("a")$diff(),
#'   diff_2_ignore = pl$col("a")$diff(2, "ignore")
#' )
expr__diff <- function(n = 1, null_behavior = c("ignore", "drop")) {
  wrap({
    null_behavior <- arg_match0(null_behavior, c("ignore", "drop"))
    self$`_rexpr`$diff(as_polars_expr(n)$`_rexpr`, null_behavior)
  })
}

#' Compute the dot/inner product between two Expressions
#'
#' @param other Expression to compute dot product with.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 3, 5), b = c(2, 4, 6))
#' df$select(pl$col("a")$dot(pl$col("b")))
expr__dot <- function(other) {
  self$`_rexpr`$dot(as_polars_expr(other)$`_rexpr`) |>
    wrap()
}

#' Reshape this Expr to a flat Series or a Series of Lists
#'
#' @param dimensions A integer vector of length of the dimension size.
#' If `-1` is used in any of the dimensions, that dimension is inferred.
#' @inherit as_polars_expr return
#'
#' @details
#' If a single dimension is given, results in an expression of the original data
#' type. If a multiple dimensions are given, results in an expression of data
#' type List with shape equal to the dimensions.
#' @examples
#' df <- pl$DataFrame(foo = 1:9)
#'
#' df$select(pl$col("foo")$reshape(9))
#' df$select(pl$col("foo")$reshape(c(3, 3)))
#'
#' # Use `-1` to infer the other dimension
#' df$select(pl$col("foo")$reshape(c(-1, 3)))
#' df$select(pl$col("foo")$reshape(c(3, -1)))
#'
#' # We can have more than 2 dimensions
#' df <- pl$DataFrame(foo = 1:8)
#' df$select(pl$col("foo")$reshape(c(2, 2, 2)))
expr__reshape <- function(dimensions) {
  wrap({
    if (!is_integerish(dimensions)) {
      abort("`dimensions` only accepts integer-ish values.")
    }
    if (anyNA(dimensions)) {
      abort("`dimensions` must not contain any NA values.")
    }
    self$`_rexpr`$reshape(dimensions)
  })
}

#' Check if any boolean value in a column is true
#'
#' @inheritParams expr__all
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(TRUE, FALSE),
#'   b = c(FALSE, FALSE),
#'   c = c(NA, FALSE)
#' )
#'
#' df$select(pl$col("*")$any())
#'
#' # If we set ignore_nulls = FALSE, then we don't know if any values in column
#' # "c" is TRUE, so it returns null
#' df$select(pl$col("*")$any(ignore_nulls = FALSE))
expr__any <- function(..., ignore_nulls = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$any(ignore_nulls)
  })
}

#' Check if all boolean values in a column are true
#'
#' This method is an expression - not to be confused with [`pl$all()`][pl__all]
#' which is a function to select all columns.
#'
#' @inheritParams rlang::args_dots_empty
#' @param ignore_nulls If `TRUE` (default), ignore null values. If `FALSE`,
#' [Kleene logic](https://en.wikipedia.org/wiki/Three-valued_logic) is used to
#' deal with nulls: if the column contains any null values and no `TRUE` values,
#' the output is null.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(TRUE, TRUE),
#'   b = c(TRUE, FALSE),
#'   c = c(NA, TRUE),
#'   d = c(NA, NA)
#' )
#'
#' # By default, ignore null values. If there are only nulls, then all() returns
#' # TRUE.
#' df$select(pl$col("*")$all())
#'
#' # If we set ignore_nulls = FALSE, then we don't know if all values in column
#' # "c" are TRUE, so it returns null
#' df$select(pl$col("*")$all(ignore_nulls = FALSE))
expr__all <- function(..., ignore_nulls = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$all(ignore_nulls)
  })
}

#' Return the cumulative sum computed at every element.
#'
#' @inheritParams rlang::args_dots_empty
#' @param reverse If `TRUE`, start with the total sum of elements and substract
#' each row one by one.
#'
#' @inherit as_polars_expr return
#' @details
#' The Dtypes Int8, UInt8, Int16 and UInt16 are cast to Int64 before summing to
#' prevent overflow issues.
#' @examples
#' pl$DataFrame(a = 1:4)$with_columns(
#'   cum_sum = pl$col("a")$cum_sum(),
#'   cum_sum_reversed = pl$col("a")$cum_sum(reverse = TRUE)
#' )
expr__cum_sum <- function(..., reverse = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$cum_sum(reverse)
  })
}


#' Return the cumulative product computed at every element.
#'
#' @inheritParams rlang::args_dots_empty
#' @param reverse If `TRUE`, start with the total product of elements and divide
#' each row one by one.
#'
#' @inherit expr__cum_sum return details
#' @examples
#' pl$DataFrame(a = 1:4)$with_columns(
#'   cum_prod = pl$col("a")$cum_prod(),
#'   cum_prod_reversed = pl$col("a")$cum_prod(reverse = TRUE)
#' )
expr__cum_prod <- function(..., reverse = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$cum_prod(reverse)
  })
}

#' Return the cumulative min computed at every element.
#'
#' @inheritParams rlang::args_dots_empty
#' @param reverse If `TRUE`, start from the last value.
#'
#' @inherit expr__cum_sum return details
#' @examples
#' pl$DataFrame(a = c(1:4, 2L))$with_columns(
#'   cum_min = pl$col("a")$cum_min(),
#'   cum_min_reversed = pl$col("a")$cum_min(reverse = TRUE)
#' )
expr__cum_min <- function(..., reverse = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$cum_min(reverse)
  })
}

#' Return the cumulative max computed at every element.
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams expr__cum_min
#'
#' @inherit expr__cum_sum return details
#' @examples
#' pl$DataFrame(a = c(1:4, 2L))$with_columns(
#'   cum_max = pl$col("a")$cum_max(),
#'   cum_max_reversed = pl$col("a")$cum_max(reverse = TRUE)
#' )
expr__cum_max <- function(..., reverse = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$cum_max(reverse)
  })
}

#' Return the cumulative count of the non-null values in the column
#'
#' @inheritParams rlang::args_dots_empty
#' @param reverse If `TRUE`, reverse the count.
#' @inherit as_polars_expr return
#'
#' @examples
#' pl$DataFrame(a = 1:4)$with_columns(
#'   cum_count = pl$col("a")$cum_count(),
#'   cum_count_reversed = pl$col("a")$cum_count(reverse = TRUE)
#' )
expr__cum_count <- function(..., reverse = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$cum_count(reverse)
  })
}

#' Return the cumulative count of the non-null values in the column
#'
#' @param expr Expression to evaluate.
#' @inheritParams rlang::args_dots_empty
#' @param min_periods Number of valid values (i.e. `length - null_count`) there
#' should be in the window before the expression is evaluated.
#' @param parallel Run in parallel. Don’t do this in a group by or another
#' operation that already has much parallelization.
#'
#' @details
#' This can be really slow as it can have `O(n^2)` complexity. Don’t use this
#' for operations that visit all elements.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(values = 1:5)
#' df$with_columns(
#'   pl$col("values")$cumulative_eval(
#'     pl$element()$first() - pl$element()$last()**2
#'   )
#' )
expr__cumulative_eval <- function(expr, ..., min_periods = 1, parallel = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$cumulative_eval(
      as_polars_expr(expr)$`_rexpr`,
      min_periods,
      parallel
    )
  })
}

#' Get the group indexes of the group by operation
#'
#' Should be used in aggregation context only.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   group = rep(c("one", "two"), each = 3),
#'   value = c(94, 95, 96, 97, 97, 99)
#' )
#'
#' df$group_by("group", maintain_order = TRUE)$agg(pl$col("value")$agg_groups())
expr__agg_groups <- function() {
  self$`_rexpr`$agg_groups() |>
    wrap()
}

#' Get the index of the maximal value
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(20, 10, 30))
#' df$select(pl$col("a")$arg_max())
expr__arg_max <- function() {
  self$`_rexpr`$arg_max() |>
    wrap()
}

#' Get the index of the minimal value
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(20, 10, 30))
#' df$select(pl$col("a")$arg_min())
expr__arg_min <- function() {
  self$`_rexpr`$arg_min() |>
    wrap()
}

#' Get the index of the first unique value
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:3, b = c(NA, 4, 4))
#' df$select(pl$col("a")$arg_unique())
#' df$select(pl$col("b")$arg_unique())
expr__arg_unique <- function() {
  self$`_rexpr`$arg_unique() |>
    wrap()
}

#' Return indices where expression is true
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 1, 2, 1))
#' df$select((pl$col("a") == 1)$arg_true())
expr__arg_true <- function() {
  arg_where(self$`_rexpr`) |>
    wrap()
}

#' Get the number of non-null elements in the column
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:3, b = c(NA, 4, 4))
#' df$select(pl$all()$count())
expr__count <- function() {
  self$`_rexpr`$count() |>
    wrap()
}

#' Aggregate values into a list
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:3, b = 4:6)
#' df$with_columns(pl$col("a")$implode())
expr__implode <- function() {
  self$`_rexpr`$implode() |>
    wrap()
}

#' Return the number of elements in the column
#'
#' Null values are counted in the total.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:3, b = c(NA, 4, 4))
#' df$select(pl$all()$len())
expr__len <- function() {
  self$`_rexpr`$len() |>
    wrap()
}

#' Compute the product of an expression.
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = 1:3, b = c(NA, 4, 4))$
#'   select(pl$all()$product())
expr__product <- function() {
  self$`_rexpr`$product() |>
    wrap()
}

#' Get quantile value(s)
#'
#' @param quantile Quantile between 0.0 and 1.0.
#' @param interpolation Interpolation method. Must be one of `"nearest"`,
#' `"higher"`, `"lower"`, `"midpoint"`, `"linear"`.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 0:5)
#' df$select(pl$col("a")$quantile(0.3))
#' df$select(pl$col("a")$quantile(0.3, interpolation = "higher"))
#' df$select(pl$col("a")$quantile(0.3, interpolation = "lower"))
#' df$select(pl$col("a")$quantile(0.3, interpolation = "midpoint"))
#' df$select(pl$col("a")$quantile(0.3, interpolation = "linear"))
expr__quantile <- function(
  quantile,
  interpolation = c("nearest", "higher", "lower", "midpoint", "linear")
) {
  wrap({
    interpolation <- arg_match0(
      interpolation,
      values = c("nearest", "higher", "lower", "midpoint", "linear")
    )
    self$`_rexpr`$quantile(as_polars_expr(quantile, as_lit = TRUE)$`_rexpr`, interpolation)
  })
}

#' Compute the standard deviation
#'
#' @inheritParams dataframe__var
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(1, 3, 5, 6))$
#'   select(pl$all()$std())
expr__std <- function(ddof = 1) {
  self$`_rexpr`$std(ddof) |>
    wrap()
}

#' Compute the variance
#'
#' @inheritParams dataframe__var
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(1, 3, 5, 6))$
#'   select(pl$all()$var())
expr__var <- function(ddof = 1) {
  self$`_rexpr`$var(ddof) |>
    wrap()
}

#' Check whether the expression contains one or more null values
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(NA, 1, NA),
#'   b = c(10, NA, 300),
#'   c = c(350, 650, 850)
#' )
#' df$select(pl$all()$has_nulls())
expr__has_nulls <- function() {
  self$null_count() >
    0 |>
      wrap()
}

#' Check if an expression is between the given lower and upper bounds
#'
#' @param lower_bound Lower bound value. Accepts expression input. Strings are
#'  parsed as column names, other non-expression inputs are parsed as literals.
#' @param upper_bound Upper bound value. Accepts expression input. Strings are
#' parsed as column names, other non-expression inputs are parsed as literals.
#' @param closed Define which sides of the interval are closed (inclusive). Must
#' be one of `"left"`, `"right"`, `"both"` or `"none"`.
#'
#' @details
#' If the value of the `lower_bound` is greater than that of the `upper_bound`
#' then the result will be `FALSE`, as no value can satisfy the condition.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(num = 1:5)
#' df$with_columns(
#'   is_between = pl$col("num")$is_between(2, 4)
#' )
#'
#' # Use the closed argument to include or exclude the values at the bounds:
#' df$with_columns(
#'   is_between = pl$col("num")$is_between(2, 4, closed = "left")
#' )
#'
#' # You can also use strings as well as numeric/temporal values (note: ensure
#' # that string literals are wrapped with lit so as not to conflate them with
#' # column names):
#' df <- pl$DataFrame(a = letters[1:5])
#' df$with_columns(
#'   is_between = pl$col("a")$is_between(pl$lit("a"), pl$lit("c"))
#' )
#'
#' # Use column expressions as lower/upper bounds, comparing to a literal value:
#' df <- pl$DataFrame(a = 1:5, b = 5:1)
#' df$with_columns(
#'   between_ab = pl$lit(3)$is_between(pl$col("a"), pl$col("b"))
#' )
expr__is_between <- function(
  lower_bound,
  upper_bound,
  closed = c("both", "left", "right", "none")
) {
  wrap({
    closed <- arg_match0(closed, values = c("both", "left", "right", "none"))
    self$`_rexpr`$is_between(
      as_polars_expr(lower_bound)$`_rexpr`,
      as_polars_expr(upper_bound)$`_rexpr`,
      closed
    )
  })
}

#' Return a boolean mask indicating duplicated values
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 1, 2, 3, 2))
#' df$select(pl$col("a")$is_duplicated())
expr__is_duplicated <- function() {
  self$`_rexpr`$is_duplicated() |>
    wrap()
}

#' Return a boolean mask indicating the first occurrence of each distinct value
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 1, 2, 3, 2))
#' df$with_columns(
#'   is_first_distinct = pl$col("a")$is_first_distinct()
#' )
expr__is_first_distinct <- function() {
  self$`_rexpr`$is_first_distinct() |>
    wrap()
}

#' Return a boolean mask indicating the last occurrence of each distinct value
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 1, 2, 3, 2))
#' df$with_columns(
#'   is_last_distinct = pl$col("a")$is_last_distinct()
#' )
expr__is_last_distinct <- function() {
  self$`_rexpr`$is_last_distinct() |>
    wrap()
}

#' Check if elements of an expression are present in another expression
#'
#' @param other Accepts expression input. Strings are parsed as column names.
#' @param nulls_equal A bool to indicate treating null as a distinct value.
#' If `TRUE`, null values will not propagate.
#' @inherit as_polars_expr return
#' @inheritParams rlang::args_dots_empty
#' @examples
#' df <- pl$DataFrame(
#'   sets = list(1:3, 1:2, 9:10),
#'   optional_members = 1:3
#' )
#' df$with_columns(
#'   contains = pl$col("optional_members")$is_in("sets")
#' )
expr__is_in <- function(other, ..., nulls_equal = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$is_in(as_polars_expr(other)$`_rexpr`, nulls_equal = nulls_equal)
  })
}

#' Return a boolean mask indicating unique values
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 1, 2, 3, 2))
#' df$select(pl$col("a")$is_unique())
expr__is_unique <- function() {
  self$`_rexpr`$is_unique() |>
    wrap()
}

#' Compute absolute values
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = -1:2)
#' df$with_columns(abs = pl$col("a")$abs())
expr__abs <- function() {
  self$`_rexpr`$abs() |>
    wrap()
}

#' Approximate count of unique values
#'
#' This is done using the HyperLogLog++ algorithm for cardinality estimation.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(n = c(1, 1, 2))
#' df$select(pl$col("n")$approx_n_unique())
#'
#' df <- pl$DataFrame(n = 0:1000)
#' df$select(
#'   exact = pl$col("n")$n_unique(),
#'   approx = pl$col("n")$approx_n_unique()
#' )
expr__approx_n_unique <- function() {
  self$`_rexpr`$approx_n_unique() |>
    wrap()
}

#' Count unique values
#'
#' `null` is considered to be a unique value for the purposes of this operation.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   x = c(1, 1, 2, 2, 3),
#'   y = c(1, 1, 1, NA, NA)
#' )
#' df$select(
#'   x_unique = pl$col("x")$n_unique(),
#'   y_unique = pl$col("y")$n_unique()
#' )
expr__n_unique <- function() {
  self$`_rexpr`$n_unique() |>
    wrap()
}

#' Compute sine
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(0, pi / 2, pi, NA))$
#'   with_columns(sine = pl$col("a")$sin())
expr__sin <- function() {
  self$`_rexpr`$sin() |>
    wrap()
}

#' Compute cosine
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(0, pi / 2, pi, NA))$
#'   with_columns(cosine = pl$col("a")$cos())
expr__cos <- function() {
  self$`_rexpr`$cos() |>
    wrap()
}

#' Compute cotangent
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(0, pi / 2, -5, NA))$
#'   with_columns(cotangent = pl$col("a")$cot())
expr__cot <- function() {
  self$`_rexpr`$cot() |>
    wrap()
}

#' Compute tangent
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(0, pi / 2, pi, NA))$
#'   with_columns(tangent = pl$col("a")$tan())
expr__tan <- function() {
  self$`_rexpr`$tan() |>
    wrap()
}

#' Compute inverse sine
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(-1, sin(0.5), 0, 1, NA))$
#'   with_columns(arcsin = pl$col("a")$arcsin())
expr__arcsin <- function() {
  self$`_rexpr`$arcsin() |>
    wrap()
}

#' Compute inverse cosine
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(-1, cos(0.5), 0, 1, NA))$
#'   with_columns(arccos = pl$col("a")$arccos())
expr__arccos <- function() {
  self$`_rexpr`$arccos() |>
    wrap()
}

#' Compute inverse tangent
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(-1, tan(0.5), 0, 1, NA_real_))$
#'   with_columns(arctan = pl$col("a")$arctan())
expr__arctan <- function() {
  self$`_rexpr`$arctan() |>
    wrap()
}

#' Compute hyperbolic sine
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(-1, asinh(0.5), 0, 1, NA))$
#'   with_columns(sinh = pl$col("a")$sinh())
expr__sinh <- function() {
  self$`_rexpr`$sinh() |>
    wrap()
}

#' Compute hyperbolic cosine
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(-1, acosh(2), 0, 1, NA))$
#'   with_columns(cosh = pl$col("a")$cosh())
expr__cosh <- function() {
  self$`_rexpr`$cosh() |>
    wrap()
}

#' Compute hyperbolic tangent
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(-1, atanh(0.5), 0, 1, NA))$
#'   with_columns(tanh = pl$col("a")$tanh())
expr__tanh <- function() {
  self$`_rexpr`$tanh() |>
    wrap()
}

#' Compute inverse hyperbolic sine
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(-1, sinh(0.5), 0, 1, NA))$
#'   with_columns(arcsinh = pl$col("a")$arcsinh())
expr__arcsinh <- function() {
  self$`_rexpr`$arcsinh() |>
    wrap()
}

#' Compute inverse hyperbolic cosine
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(-1, cosh(0.5), 0, 1, NA))$
#'   with_columns(arccosh = pl$col("a")$arccosh())
expr__arccosh <- function() {
  self$`_rexpr`$arccosh() |>
    wrap()
}

#' Compute inverse hyperbolic tangent
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(-1, tanh(0.5), 0, 1, NA))$
#'   with_columns(arctanh = pl$col("a")$arctanh())
expr__arctanh <- function() {
  self$`_rexpr`$arctanh() |>
    wrap()
}

#' Compute square root
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(1, 2, 4))$
#'   with_columns(sqrt = pl$col("a")$sqrt())
expr__sqrt <- function() {
  self$`_rexpr`$sqrt() |>
    wrap()
}

#' Compute cube root
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(1, 2, 4))$
#'   with_columns(cbrt = pl$col("a")$cbrt())
expr__cbrt <- function() {
  self$`_rexpr`$cbrt() |>
    wrap()
}

#' Convert from radians to degrees
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(1, 2, 4) * pi)$
#'   with_columns(degrees = pl$col("a")$degrees())
expr__degrees <- function() {
  self$`_rexpr`$degrees() |>
    wrap()
}

#' Convert from degrees to radians
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(-720, -540, -360, -180, 0, 180, 360, 540, 720))$
#'   with_columns(radians = pl$col("a")$radians())
expr__radians <- function() {
  self$`_rexpr`$radians() |>
    wrap()
}

#' Compute entropy
#'
#' Uses the formula `-sum(pk * log(pk)` where `pk` are discrete probabilities.
#'
#' @param base Numeric value used as base, defaults to `exp(1)`.
#' @inheritParams rlang::args_dots_empty
#' @param normalize Normalize `pk` if it doesn’t sum to 1.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:3)
#' df$select(pl$col("a")$entropy(base = 2))
#' df$select(pl$col("a")$entropy(base = 2, normalize = FALSE))
expr__entropy <- function(base = exp(1), ..., normalize = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$entropy(base, normalize)
  })
}

#' Compute the exponential
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(1, 2, 4))$
#'   with_columns(exp = pl$col("a")$exp())
expr__exp <- function() {
  self$`_rexpr`$exp() |>
    wrap()
}

#' Compute the logarithm
#'
#' @inheritParams expr__entropy
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(1, 2, 4))$
#'   with_columns(
#'   log = pl$col("a")$log(),
#'   log_base_2 = pl$col("a")$log(base = 2)
#' )
expr__log <- function(base = exp(1)) {
  self$`_rexpr`$log(base) |>
    wrap()
}

#' Compute the base-10 logarithm
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(1, 2, 4))$
#'   with_columns(log10 = pl$col("a")$log10())
expr__log10 <- function() {
  self$log(10)
}

#' Compute the natural logarithm plus one
#'
#' This computes `log(1 + x)` but is more numerically stable for `x` close to
#' zero.
#'
#' @inherit as_polars_expr return
#' @examples
#' pl$DataFrame(a = c(1, 2, 4))$
#'   with_columns(log1p = pl$col("a")$log1p())
expr__log1p <- function() {
  self$`_rexpr`$log1p() |>
    wrap()
}

#' Hash elements
#'
#' @param seed Integer, random seed parameter. Defaults to 0.
#' @param seed_1,seed_2,seed_3 Integer, random seed parameters. Default to
#' `seed` if not set.
#' @inherit as_polars_expr return
#'
#' @details
#' This implementation of hash does not guarantee stable results across
#' different Polars versions. Its stability is only guaranteed within a single
#' version.
#'
#' @examples
#' df <- pl$DataFrame(a = c(1, 2, NA), b = c("x", NA, "z"))
#' df$with_columns(pl$all()$hash(10, 20, 30, 40))
expr__hash <- function(seed = 0, seed_1 = NULL, seed_2 = NULL, seed_3 = NULL) {
  wrap({
    seed_1 <- seed_1 %||% seed
    seed_2 <- seed_2 %||% seed
    seed_3 <- seed_3 %||% seed
    self$`_rexpr`$hash(seed, seed_1, seed_2, seed_3)
  })
}

#' Compute the most occurring value(s)
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 1, 2, 3), b = c(1, 1, 2, 2))
#' df$select(pl$col("a")$mode())
#' df$select(pl$col("b")$mode())
expr__mode <- function() {
  self$`_rexpr`$mode() |>
    wrap()
}

#' Count null values
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(NA, 1, NA),
#'   b = c(10, NA, 300),
#'   c = c(1, 2, 2)
#' )
#' df$select(pl$all()$null_count())
expr__null_count <- function() {
  self$`_rexpr`$null_count() |>
    wrap()
}

#' Computes percentage change between values
#'
#' Computes the percentage change (as fraction) between current element and
#' most-recent non-null element at least `n` period(s) before the current
#' element. By default it computes the change from the previous row.
#'
#' @param n Integer or Expr indicating the number of periods to shift for
#' forming percent change.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(10:12, NA, 12))
#' df$with_columns(
#'   pct_change = pl$col("a")$pct_change()
#' )
expr__pct_change <- function(n = 1) {
  self$`_rexpr`$pct_change(as_polars_expr(n)$`_rexpr`) |>
    wrap()
}

#' Get a boolean mask of the local maximum peaks
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(x = c(1, 2, 3, 2, 3, 4, 5, 2))
#' df$with_columns(peak_max = pl$col("x")$peak_max())
expr__peak_max <- function() {
  self$`_rexpr`$peak_max() |>
    wrap()
}

#' Get a boolean mask of the local minimum peaks
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(x = c(1, 2, 3, 2, 3, 4, 5, 2))
#' df$with_columns(peak_min = pl$col("x")$peak_min())
expr__peak_min <- function() {
  self$`_rexpr`$peak_min() |>
    wrap()
}

#' Assign ranks to data, dealing with ties appropriately
#'
#' @inheritParams rlang::args_dots_empty
#' @param method The method used to assign ranks to tied elements. Must be one
#' of the following:
#' - `"average"` (default): The average of the ranks that would have been
#'   assigned to all the tied values is assigned to each value.
#' - `"min"`: The minimum of the ranks that would have been assigned to all
#'   the tied values is assigned to each value. (This is also referred to
#'   as "competition" ranking.)
#' - `"max"` : The maximum of the ranks that would have been assigned to all
#'   the tied values is assigned to each value.
#' - `"dense"`: Like 'min', but the rank of the next highest element is assigned
#'   the rank immediately after those assigned to the tied elements.
#' - `"ordinal"` : All values are given a distinct rank, corresponding to the
#'   order that the values occur in the Series.
#' - `"random"` : Like 'ordinal', but the rank for ties is not dependent on the
#'   order that the values occur in the Series.
#' @param descending Rank in descending order.
#' @param seed Integer. Only used if `method = "random"`.
#'
#' @inherit as_polars_expr return
#' @examples
#' # Default is to use the "average" method to break ties
#' df <- pl$DataFrame(a = c(3, 6, 1, 1, 6))
#' df$with_columns(rank = pl$col("a")$rank())
#'
#' # Ordinal method
#' df$with_columns(rank = pl$col("a")$rank("ordinal"))
#'
#' # Use "rank" with "over" to rank within groups:
#' df <- pl$DataFrame(
#'   a = c(1, 1, 2, 2, 2),
#'   b = c(6, 7, 5, 14, 11)
#' )
#' df$with_columns(
#'   rank = pl$col("b")$rank()$over("a")
#' )
expr__rank <- function(
  method = c("average", "min", "max", "dense", "ordinal", "random"),
  ...,
  descending = FALSE,
  seed = NULL
) {
  wrap({
    check_dots_empty0(...)
    method <- arg_match0(
      method,
      values = c("average", "min", "max", "dense", "ordinal", "random")
    )
    self$`_rexpr`$rank(method, descending, seed)
  })
}

#' Compute the kurtosis (Fisher or Pearson)
#'
#' Kurtosis is the fourth central moment divided by the square of the variance.
#' If Fisher’s definition is used, then 3.0 is subtracted from the result to
#' give 0.0 for a normal distribution. If `bias` is `FALSE` then the kurtosis
#' is calculated using `k` statistics to eliminate bias coming from biased
#' moment estimators.
#'
#' @inheritParams rlang::args_dots_empty
#' @param fisher If `TRUE` (default), Fisher’s definition is used
#' (normal ==> 0.0). If `FALSE`, Pearson’s definition is used (normal ==> 3.0).
#' @param bias If `FALSE`, the calculations are corrected for statistical bias.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(x = c(1, 2, 3, 2, 1))
#' df$select(pl$col("x")$kurtosis())
expr__kurtosis <- function(..., fisher = TRUE, bias = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$kurtosis(fisher, bias)
  })
}

#' Compute the skewness
#'
#' For normally distributed data, the skewness should be about zero. For
#' unimodal continuous distributions, a skewness value greater than zero means
#' that there is more weight in the right tail of the distribution.
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams expr__kurtosis
#'
#' @details
#' The sample skewness is computed as the Fisher-Pearson coefficient of
#' skewness, i.e.
#' \deqn{g_1=\frac{m_3}{m_2^{3/2}}}
#' where
#' \deqn{m_i=\frac{1}{N}\sum_{n=1}^N(x[n]-\bar{x})^i}
#' is the biased sample \eqn{i\texttt{th}} central moment, and \eqn{\bar{x}}
#' is the sample mean. If `bias = FALSE`, the calculations are corrected for
#' bias and the value computed is the adjusted Fisher-Pearson standardized
#' moment coefficient, i.e.
#' \deqn{G_1 = \frac{k_3}{k_2^{3/2}} = \frac{\sqrt{N(N-1)}}{N-2}\frac{m_3}{m_2^{3/2}}}
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(x = c(1, 2, 3, 2, 1))
#' df$select(pl$col("x")$skew())
expr__skew <- function(..., bias = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$skew(bias)
  })
}

#' Bin values into buckets and count their occurrences
#'
#' `r lifecycle::badge("experimental")`
#'
#' @inheritParams rlang::args_dots_empty
#' @param bins Discretizations to make. If `NULL` (default), we determine the
#' boundaries based on the data.
#' @param bin_count If no bins provided, this will be used to determine the
#' distance of the bins.
#' @param include_breakpoint Include a column that indicates the upper
#' breakpoint.
#' @param include_category Include a column that shows the intervals as
#' categories.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 3, 8, 8, 2, 1, 3))
#' df$select(pl$col("a")$hist(bins = 1:3))
#' df$select(
#'   pl$col("a")$hist(
#'     bins = 1:3, include_category = TRUE, include_breakpoint = TRUE
#'   )
#' )
expr__hist <- function(
  bins = NULL,
  ...,
  bin_count = NULL,
  include_category = FALSE,
  include_breakpoint = FALSE
) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$hist(
      bins = as_polars_expr(bins)$`_rexpr`,
      bin_count = bin_count,
      include_category = include_category,
      include_breakpoint = include_breakpoint
    )
  })
}

#' Count the occurrences of unique values
#'
#' @inheritParams rlang::args_dots_empty
#' @param sort Sort the output by count in descending order. If `FALSE`
#' (default), the order of the output is random.
#' @param parallel Execute the computation in parallel. This option should
#' likely not be enabled in a group by context, as the computation is already
#' parallelized per group.
#' @param name Give the resulting count field a specific name. If `normalize`
#' is `TRUE` it defaults to `"proportion"`, otherwise it defaults to `"count"`.
#' @param normalize If `TRUE`, gives relative frequencies of the unique values.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(color = c("red", "blue", "red", "green", "blue", "blue"))
#' df$select(pl$col("color")$value_counts())
#'
#' # Sort the output by (descending) count and customize the count field name.
#' df <- df$select(pl$col("color")$value_counts(sort = TRUE, name = "n"))
#' df
#'
#' df$unnest("color")
expr__value_counts <- function(
  ...,
  sort = FALSE,
  parallel = FALSE,
  name = NULL,
  normalize = FALSE
) {
  wrap({
    check_dots_empty0(...)
    if (is.null(name)) {
      if (isTRUE(normalize)) {
        name <- "proportion"
      } else {
        name <- "count"
      }
    }
    self$`_rexpr`$value_counts(sort, parallel, name, normalize)
  })
}

#' Count unique values in the order of appearance
#'
#' This method differs from [`$value_counts()`][expr__value_counts] in that it
#' does not return the values, only the counts and might be faster.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(id = c("a", "b", "b", "c", "c", "c"))
#' df$select(pl$col("id")$unique_counts())
expr__unique_counts <- function() {
  wrap({
    self$`_rexpr`$unique_counts()
  })
}

#' Get unique values
#'
#' This method differs from [`$value_counts()`][expr__value_counts] in that it
#' does not return the values, only the counts and might be faster.
#'
#' @inheritParams rlang::args_dots_empty
#' @param maintain_order Maintain order of data. This requires more work.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 1, 2))
#' df$select(pl$col("a")$unique())
expr__unique <- function(..., maintain_order = FALSE) {
  wrap({
    check_dots_empty0(...)
    if (isTRUE(maintain_order)) {
      self$`_rexpr`$unique_stable()
    } else {
      self$`_rexpr`$unique()
    }
  })
}

#' Compute the sign
#'
#' This returns -1 if x is lower than 0, 0 if x == 0, and 1 if x is greater
#' than 0.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(-9, 0, 0, 4, NA))
#' df$with_columns(sign = pl$col("a")$sign())
expr__sign <- function() {
  wrap({
    self$`_rexpr`$sign()
  })
}

#' Find indices where elements should be inserted to maintain order
#'
#' This returns -1 if x is lower than 0, 0 if x == 0, and 1 if x is greater
#' than 0.
#'
#' @param element Expression or scalar value.
#' @param side Must be one of the following:
#' * `"any"`: the index of the first suitable location found is given;
#' * `"left"`: the index of the leftmost suitable location found is given;
#' * `"right"`: the index the rightmost suitable location found is given.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(values = c(1, 2, 3, 5))
#' df$select(
#'   zero = pl$col("values")$search_sorted(0),
#'   three = pl$col("values")$search_sorted(3),
#'   six = pl$col("values")$search_sorted(6),
#' )
expr__search_sorted <- function(element, side = c("any", "left", "right")) {
  wrap({
    side <- arg_match0(side, values = c("any", "left", "right"))
    self$`_rexpr`$search_sorted(as_polars_expr(element)$`_rexpr`, side)
  })
}

#' Apply a rolling max over values
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' A window of length `window_size` will traverse the array. The values that
#' fill this window will (optionally) be multiplied with the weights given by
#' the `weights` vector. The resulting values will be aggregated.
#'
#' The window at a given row will include the row itself, and the
#' `window_size - 1` elements before it.
#'
#' @inheritParams rlang::args_dots_empty
#' @param window_size The length of the window in number of elements.
#' @param weights An optional slice with the same length as the window that
#' will be multiplied elementwise with the values in the window.
#' @param min_periods The number of values in the window that should be
#' non-null before computing a result. If `NULL` (default), it will be set
#' equal to `window_size`.
#' @param center If `TRUE`, set the labels at the center of the window.
#'
#' @details
#' If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using [`$rolling()`][expr__rolling] - this method can cache
#' the window size computation.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:6)
#' df$with_columns(
#'   rolling_max = pl$col("a")$rolling_max(window_size = 2)
#' )
#'
#' # Specify weights to multiply the values in the window with:
#' df$with_columns(
#'   rolling_max = pl$col("a")$rolling_max(
#'     window_size = 2, weights = c(0.25, 0.75)
#'   )
#' )
#'
#' # Center the values in the window
#' df$with_columns(
#'   rolling_max = pl$col("a")$rolling_max(window_size = 3, center = TRUE)
#' )
expr__rolling_max <- function(
  window_size,
  weights = NULL,
  ...,
  min_periods = NULL,
  center = FALSE
) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$rolling_max(
      window_size = window_size,
      weights = weights,
      min_periods = min_periods,
      center = center
    )
  })
}

#' Apply a rolling min over values
#'
#' @inherit expr__rolling_max description params details
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:6)
#' df$with_columns(
#'   rolling_min = pl$col("a")$rolling_min(window_size = 2)
#' )
#'
#' # Specify weights to multiply the values in the window with:
#' df$with_columns(
#'   rolling_min = pl$col("a")$rolling_min(
#'     window_size = 2, weights = c(0.25, 0.75)
#'   )
#' )
#'
#' # Center the values in the window
#' df$with_columns(
#'   rolling_min = pl$col("a")$rolling_min(window_size = 3, center = TRUE)
#' )
expr__rolling_min <- function(
  window_size,
  weights = NULL,
  ...,
  min_periods = NULL,
  center = FALSE
) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$rolling_min(
      window_size = window_size,
      weights = weights,
      min_periods = min_periods,
      center = center
    )
  })
}

#' Apply a rolling mean over values
#'
#' @inherit expr__rolling_max description params details
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:6)
#' df$with_columns(
#'   rolling_mean = pl$col("a")$rolling_mean(window_size = 2)
#' )
#'
#' # Specify weights to multiply the values in the window with:
#' df$with_columns(
#'   rolling_mean = pl$col("a")$rolling_mean(
#'     window_size = 2, weights = c(0.25, 0.75)
#'   )
#' )
#'
#' # Center the values in the window
#' df$with_columns(
#'   rolling_mean = pl$col("a")$rolling_mean(window_size = 3, center = TRUE)
#' )
expr__rolling_mean <- function(
  window_size,
  weights = NULL,
  ...,
  min_periods = NULL,
  center = FALSE
) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$rolling_mean(
      window_size = window_size,
      weights = weights,
      min_periods = min_periods,
      center = center
    )
  })
}

#' Apply a rolling median over values
#'
#' @inherit expr__rolling_max description params details
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:6)
#' df$with_columns(
#'   rolling_median = pl$col("a")$rolling_median(window_size = 2)
#' )
#'
#' # Specify weights to multiply the values in the window with:
#' df$with_columns(
#'   rolling_median = pl$col("a")$rolling_median(
#'     window_size = 2, weights = c(0.25, 0.75)
#'   )
#' )
#'
#' # Center the values in the window
#' df$with_columns(
#'   rolling_median = pl$col("a")$rolling_median(window_size = 3, center = TRUE)
#' )
expr__rolling_median <- function(
  window_size,
  weights = NULL,
  ...,
  min_periods = NULL,
  center = FALSE
) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$rolling_median(
      window_size = window_size,
      weights = weights,
      min_periods = min_periods,
      center = center
    )
  })
}

#' Apply a rolling sum over values
#'
#' @inherit expr__rolling_max description params details
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:6)
#' df$with_columns(
#'   rolling_sum = pl$col("a")$rolling_sum(window_size = 2)
#' )
#'
#' # Specify weights to multiply the values in the window with:
#' df$with_columns(
#'   rolling_sum = pl$col("a")$rolling_sum(
#'     window_size = 2, weights = c(0.25, 0.75)
#'   )
#' )
#'
#' # Center the values in the window
#' df$with_columns(
#'   rolling_sum = pl$col("a")$rolling_sum(window_size = 3, center = TRUE)
#' )
expr__rolling_sum <- function(
  window_size,
  weights = NULL,
  ...,
  min_periods = NULL,
  center = FALSE
) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$rolling_sum(
      window_size = window_size,
      weights = weights,
      min_periods = min_periods,
      center = center
    )
  })
}

#' Apply a rolling quantile over values
#'
#' @inherit expr__rolling_max description params details
#' @inheritParams expr__quantile
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:6)
#' df$with_columns(
#'   rolling_quantile = pl$col("a")$rolling_quantile(
#'     quantile = 0.25, window_size = 4
#'   )
#' )
#'
#' # Specify weights to multiply the values in the window with:
#' df$with_columns(
#'   rolling_quantile = pl$col("a")$rolling_quantile(
#'     quantile = 0.25, window_size = 4, weights = c(0.2, 0.4, 0.4, 0.2)
#'   )
#' )
#'
#' # Specify weights and interpolation method:
#' df$with_columns(
#'   rolling_quantile = pl$col("a")$rolling_quantile(
#'     quantile = 0.25, window_size = 4, weights = c(0.2, 0.4, 0.4, 0.2),
#'     interpolation = "linear"
#'   )
#' )
#'
#' # Center the values in the window
#' df$with_columns(
#'   rolling_quantile = pl$col("a")$rolling_quantile(
#'     quantile = 0.25, window_size = 5, center = TRUE
#'   )
#' )
expr__rolling_quantile <- function(
  quantile,
  interpolation = c("nearest", "higher", "lower", "midpoint", "linear"),
  window_size,
  weights = NULL,
  ...,
  min_periods = NULL,
  center = FALSE
) {
  wrap({
    check_dots_empty0(...)
    interpolation <- arg_match0(
      interpolation,
      values = c("nearest", "higher", "lower", "midpoint", "linear")
    )
    self$`_rexpr`$rolling_quantile(
      quantile = quantile,
      interpolation = interpolation,
      window_size = window_size,
      weights = weights,
      min_periods = min_periods,
      center = center
    )
  })
}

#' Apply a rolling skew over values
#'
#' @inherit expr__rolling_max description params details
#' @inherit as_polars_expr return
#' @inheritParams expr__skew
#' @param min_samples The number of values in the window that should be non-null before computing
#' a result. If set to `NULL` (default), it will be set equal to `window_size`.
#' @param center Set the labels at the center of the window.
#' @examples
#' df <- pl$DataFrame(a = c(1, 4, 2, 9))
#' df$with_columns(
#'   rolling_skew = pl$col("a")$rolling_skew(3)
#' )
expr__rolling_skew <- function(
  window_size,
  ...,
  bias = TRUE,
  min_samples = NULL,
  center = FALSE
) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$rolling_skew(
      window_size = window_size,
      bias = bias,
      min_samples = min_samples,
      center = center
    )
  })
}

#' Apply a rolling standard deviation over values
#'
#' @inherit expr__rolling_max description params details
#' @inheritParams expr__std
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:6)
#' df$with_columns(
#'   rolling_std = pl$col("a")$rolling_std(window_size = 2)
#' )
#'
#' # Specify weights to multiply the values in the window with:
#' df$with_columns(
#'   rolling_std = pl$col("a")$rolling_std(
#'     window_size = 2, weights = c(0.25, 0.75)
#'   )
#' )
#'
#' # Center the values in the window
#' df$with_columns(
#'   rolling_std = pl$col("a")$rolling_std(window_size = 3, center = TRUE)
#' )
expr__rolling_std <- function(
  window_size,
  weights = NULL,
  ...,
  min_periods = NULL,
  center = FALSE,
  ddof = 1
) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$rolling_std(
      window_size = window_size,
      weights = weights,
      min_periods = min_periods,
      center = center,
      ddof = ddof
    )
  })
}

#' Apply a rolling variance over values
#'
#' @inherit expr__rolling_max description params details
#' @inheritParams expr__var
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:6)
#' df$with_columns(
#'   rolling_var = pl$col("a")$rolling_var(window_size = 2)
#' )
#'
#' # Specify weights to multiply the values in the window with:
#' df$with_columns(
#'   rolling_var = pl$col("a")$rolling_var(
#'     window_size = 2, weights = c(0.25, 0.75)
#'   )
#' )
#'
#' # Center the values in the window
#' df$with_columns(
#'   rolling_var = pl$col("a")$rolling_var(window_size = 3, center = TRUE)
#' )
expr__rolling_var <- function(
  window_size,
  weights = NULL,
  ...,
  min_periods = NULL,
  center = FALSE,
  ddof = 1
) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$rolling_var(
      window_size = window_size,
      weights = weights,
      min_periods = min_periods,
      center = center,
      ddof = ddof
    )
  })
}

#' Create rolling groups based on a temporal or integer column
#'
#' @description
#' If you have a time series `<t_0, t_1, ..., t_n>`, then by default the
#' windows created will be:
#' * `(t_0 - period, t_0]`
#' * `(t_1 - period, t_1]`
#' * …
#' * `(t_n - period, t_n]`
#'
#' whereas if you pass a non-default `offset`, then the windows will be:
#' * `(t_0 + offset, t_0 + offset + period]`
#' * `(t_1 + offset, t_1 + offset + period]`
#' * …
#' * `(t_n + offset, t_n + offset + period]`
#'
#'
#' @inherit expr__rolling_max params details
#' @inheritParams pl__date_range
#' @inheritParams rlang::args_dots_empty
#' @param index_column Character. Name of the column used to group based on the
#' time window. Often of type Date/Datetime. This column must be sorted in
#' ascending order. In case of a rolling group by on indices, dtype needs to be
#' one of UInt32, UInt64, Int32, Int64. Note that the first three get cast to
#' Int64, so if performance matters use an Int64 column.
#' @param period Length of the window - must be non-negative.
#' @param offset Offset of the window. Default is `-period`.
#'
#' @inherit as_polars_expr return
#' @examples
#' dates <- as.POSIXct(
#'   c(
#'     "2020-01-01 13:45:48", "2020-01-01 16:42:13", "2020-01-01 16:45:09",
#'     "2020-01-02 18:12:48", "2020-01-03 19:45:32", "2020-01-08 23:16:43"
#'   )
#' )
#' df <- pl$DataFrame(dt = dates, a = c(3, 7, 5, 9, 2, 1))
#'
#' df$with_columns(
#'   sum_a = pl$col("a")$sum()$rolling(index_column = "dt", period = "2d"),
#'   min_a = pl$col("a")$min()$rolling(index_column = "dt", period = "2d"),
#'   max_a = pl$col("a")$max()$rolling(index_column = "dt", period = "2d")
#' )
expr__rolling <- function(
  index_column,
  ...,
  period,
  offset = NULL,
  closed = "right"
) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "right", "none"))
    if (is.null(offset)) {
      offset <- negate_duration_string(parse_as_duration_string(period))
    }
    period <- parse_as_duration_string(period)
    offset <- parse_as_duration_string(offset)
    self$`_rexpr`$rolling(index_column, period, offset, closed)
  })
}

#' Apply a rolling max based on another column
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Given a `by` column `<t_0, t_1, ..., t_n>`, then `closed = "right"` (the
#' default) means the windows will be:
#' * `(t_0 - window_size, t_0]`
#' * `(t_1 - window_size, t_1]`
#' * …
#' * `(t_n - window_size, t_n]`
#'
#' @inheritParams rlang::args_dots_empty
#' @param by Should be DateTime, Date, UInt64, UInt32, Int64, or Int32 data
#' type after conversion by [as_polars_expr()]. Note that the
#' integer ones require using `"i"` in `window_size`. Accepts expression input.
#' Strings are parsed as column names.
#' @param window_size The length of the window. Can be a dynamic temporal size
#' indicated by a timedelta or the following string language:
#' - 1ns (1 nanosecond)
#' - 1us (1 microsecond)
#' - 1ms (1 millisecond)
#' - 1s (1 second)
#' - 1m (1 minute)
#' - 1h (1 hour)
#' - 1d (1 calendar day)
#' - 1w (1 calendar week)
#' - 1mo (1 calendar month)
#' - 1q (1 calendar quarter)
#' - 1y (1 calendar year)
#'
#' Or combine them: `"3d12h4m25s"` # 3 days, 12 hours, 4 minutes, and 25 seconds
#'
#' By "calendar day", we mean the corresponding time on the next day
#' (which may not be 24 hours, due to daylight savings). Similarly for
#' "calendar week", "calendar month", "calendar quarter", and "calendar year".
#' @param min_periods The number of values in the window that should be
#' non-null before computing a result. If `NULL` (default), it will be set
#' equal to `window_size`.
#' @param closed Define which sides of the interval are closed (inclusive).
#' Default is `"right"`.
#'
#' @details
#' If you want to compute multiple aggregation statistics over the same dynamic
#' window, consider using [`$rolling()`][expr__rolling] - this method can cache
#' the window size computation.
#'
#' @inherit as_polars_expr return
#' @examples
#' df_temporal <- pl$select(
#'   index = 0:24,
#'   date = pl$datetime_range(
#'     as.POSIXct("2001-01-01"),
#'     as.POSIXct("2001-01-02"),
#'     "1h"
#'   )
#' )
#'
#' # Compute the rolling max with the temporal windows closed on the right
#' # (default)
#' df_temporal$with_columns(
#'   rolling_row_max = pl$col("index")$rolling_max_by(
#'     "date",
#'     window_size = "2h"
#'   )
#' )
#'
#' # Compute the rolling max with the closure of windows on both sides
#' df_temporal$with_columns(
#'   rolling_row_max = pl$col("index")$rolling_max_by(
#'     "date",
#'     window_size = "2h",
#'     closed = "both"
#'   )
#' )
expr__rolling_max_by <- function(
  by,
  window_size,
  ...,
  min_periods = 1,
  closed = c("right", "both", "left", "none")
) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "right", "none"))
    self$`_rexpr`$rolling_max_by(
      by = as_polars_expr(by)$`_rexpr`,
      window_size = window_size,
      min_periods = min_periods,
      closed = closed
    )
  })
}

#' Apply a rolling min based on another column
#'
#' @inherit expr__rolling_max_by description params details
#'
#' @inherit as_polars_expr return
#' @examples
#' df_temporal <- pl$select(
#'   index = 0:24,
#'   date = pl$datetime_range(
#'     as.POSIXct("2001-01-01"),
#'     as.POSIXct("2001-01-02"),
#'     "1h"
#'   )
#' )
#'
#' # Compute the rolling min with the temporal windows closed on the right
#' # (default)
#' df_temporal$with_columns(
#'   rolling_row_min = pl$col("index")$rolling_min_by(
#'     "date",
#'     window_size = "2h"
#'   )
#' )
#'
#' # Compute the rolling min with the closure of windows on both sides
#' df_temporal$with_columns(
#'   rolling_row_min = pl$col("index")$rolling_min_by(
#'     "date",
#'     window_size = "2h",
#'     closed = "both"
#'   )
#' )
expr__rolling_min_by <- function(
  by,
  window_size,
  ...,
  min_periods = 1,
  closed = c("right", "both", "left", "none")
) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "right", "none"))
    self$`_rexpr`$rolling_min_by(
      by = as_polars_expr(by)$`_rexpr`,
      window_size = window_size,
      min_periods = min_periods,
      closed = closed
    )
  })
}

#' Apply a rolling mean based on another column
#'
#' @inherit expr__rolling_max_by description params details
#'
#' @inherit as_polars_expr return
#' @examples
#' df_temporal <- pl$select(
#'   index = 0:24,
#'   date = pl$datetime_range(
#'     as.POSIXct("2001-01-01"),
#'     as.POSIXct("2001-01-02"),
#'     "1h"
#'   )
#' )
#'
#' # Compute the rolling mean with the temporal windows closed on the right
#' # (default)
#' df_temporal$with_columns(
#'   rolling_row_mean = pl$col("index")$rolling_mean_by(
#'     "date",
#'     window_size = "2h"
#'   )
#' )
#'
#' # Compute the rolling mean with the closure of windows on both sides
#' df_temporal$with_columns(
#'   rolling_row_mean = pl$col("index")$rolling_mean_by(
#'     "date",
#'     window_size = "2h",
#'     closed = "both"
#'   )
#' )
expr__rolling_mean_by <- function(
  by,
  window_size,
  ...,
  min_periods = 1,
  closed = c("right", "both", "left", "none")
) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "right", "none"))
    self$`_rexpr`$rolling_mean_by(
      by = as_polars_expr(by)$`_rexpr`,
      window_size = window_size,
      min_periods = min_periods,
      closed = closed
    )
  })
}

#' Apply a rolling median based on another column
#'
#' @inherit expr__rolling_max_by description params details
#'
#' @inherit as_polars_expr return
#' @examples
#' df_temporal <- pl$select(
#'   index = 0:24,
#'   date = pl$datetime_range(
#'     as.POSIXct("2001-01-01"),
#'     as.POSIXct("2001-01-02"),
#'     "1h"
#'   )
#' )
#'
#' # Compute the rolling median with the temporal windows closed on the right
#' # (default)
#' df_temporal$with_columns(
#'   rolling_row_median = pl$col("index")$rolling_median_by(
#'     "date",
#'     window_size = "2h"
#'   )
#' )
#'
#' # Compute the rolling median with the closure of windows on both sides
#' df_temporal$with_columns(
#'   rolling_row_median = pl$col("index")$rolling_median_by(
#'     "date",
#'     window_size = "2h",
#'     closed = "both"
#'   )
#' )
expr__rolling_median_by <- function(
  by,
  window_size,
  ...,
  min_periods = 1,
  closed = c("right", "both", "left", "none")
) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "right", "none"))
    self$`_rexpr`$rolling_median_by(
      by = as_polars_expr(by)$`_rexpr`,
      window_size = window_size,
      min_periods = min_periods,
      closed = closed
    )
  })
}

#' Apply a rolling sum based on another column
#'
#' @inherit expr__rolling_max_by description params details
#'
#' @inherit as_polars_expr return
#' @examples
#' df_temporal <- pl$select(
#'   index = 0:24,
#'   date = pl$datetime_range(
#'     as.POSIXct("2001-01-01"),
#'     as.POSIXct("2001-01-02"),
#'     "1h"
#'   )
#' )
#'
#' # Compute the rolling sum with the temporal windows closed on the right
#' # (default)
#' df_temporal$with_columns(
#'   rolling_row_sum = pl$col("index")$rolling_sum_by(
#'     "date",
#'     window_size = "2h"
#'   )
#' )
#'
#' # Compute the rolling sum with the closure of windows on both sides
#' df_temporal$with_columns(
#'   rolling_row_sum = pl$col("index")$rolling_sum_by(
#'     "date",
#'     window_size = "2h",
#'     closed = "both"
#'   )
#' )
expr__rolling_sum_by <- function(
  by,
  window_size,
  ...,
  min_periods = 1,
  closed = c("right", "both", "left", "none")
) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "right", "none"))
    self$`_rexpr`$rolling_sum_by(
      by = as_polars_expr(by)$`_rexpr`,
      window_size = window_size,
      min_periods = min_periods,
      closed = closed
    )
  })
}

#' Apply a rolling quantile based on another column
#'
#' @inherit expr__rolling_max_by description params details
#' @inheritParams expr__quantile
#'
#' @inherit as_polars_expr return
#' @examples
#' df_temporal <- pl$select(
#'   index = 0:24,
#'   date = pl$datetime_range(
#'     as.POSIXct("2001-01-01"),
#'     as.POSIXct("2001-01-02"),
#'     "1h"
#'   )
#' )
#'
#' # Compute the rolling quantile with the temporal windows closed on the right
#' # (default)
#' df_temporal$with_columns(
#'   rolling_row_quantile = pl$col("index")$rolling_quantile_by(
#'     "date",
#'     window_size = "2h",
#'     quantile = 0.3
#'   )
#' )
#'
#' # Compute the rolling quantile with the closure of windows on both sides
#' df_temporal$with_columns(
#'   rolling_row_quantile = pl$col("index")$rolling_quantile_by(
#'     "date",
#'     window_size = "2h",
#'     quantile = 0.3,
#'     closed = "both"
#'   )
#' )
expr__rolling_quantile_by <- function(
  by,
  window_size,
  ...,
  quantile,
  interpolation = c("nearest", "higher", "lower", "midpoint", "linear"),
  min_periods = 1,
  closed = c("right", "both", "left", "none")
) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "right", "none"))
    interpolation <- arg_match0(
      interpolation,
      values = c("nearest", "higher", "lower", "midpoint", "linear")
    )
    self$`_rexpr`$rolling_quantile_by(
      by = as_polars_expr(by)$`_rexpr`,
      window_size = window_size,
      quantile = quantile,
      interpolation = interpolation,
      min_periods = min_periods,
      closed = closed
    )
  })
}

#' Apply a rolling standard deviation based on another column
#'
#' @inherit expr__rolling_max_by description params details
#' @inheritParams expr__std
#'
#' @inherit as_polars_expr return
#' @examples
#' df_temporal <- pl$select(
#'   index = 0:24,
#'   date = pl$datetime_range(
#'     as.POSIXct("2001-01-01"),
#'     as.POSIXct("2001-01-02"),
#'     "1h"
#'   )
#' )
#'
#' # Compute the rolling std with the temporal windows closed on the right
#' # (default)
#' df_temporal$with_columns(
#'   rolling_row_std = pl$col("index")$rolling_std_by(
#'     "date",
#'     window_size = "2h"
#'   )
#' )
#'
#' # Compute the rolling std with the closure of windows on both sides
#' df_temporal$with_columns(
#'   rolling_row_std = pl$col("index")$rolling_std_by(
#'     "date",
#'     window_size = "2h",
#'     closed = "both"
#'   )
#' )
expr__rolling_std_by <- function(
  by,
  window_size,
  ...,
  min_periods = 1,
  closed = c("right", "both", "left", "none"),
  ddof = 1
) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "right", "none"))
    self$`_rexpr`$rolling_std_by(
      by = as_polars_expr(by)$`_rexpr`,
      window_size = window_size,
      min_periods = min_periods,
      closed = closed,
      ddof = ddof
    )
  })
}

#' Apply a rolling variance based on another column
#'
#' @inherit expr__rolling_max_by description params details
#' @inheritParams expr__var
#'
#' @inherit as_polars_expr return
#' @examples
#' df_temporal <- pl$select(
#'   index = 0:24,
#'   date = pl$datetime_range(
#'     as.POSIXct("2001-01-01"),
#'     as.POSIXct("2001-01-02"),
#'     "1h"
#'   )
#' )
#'
#' # Compute the rolling var with the temporal windows closed on the right
#' # (default)
#' df_temporal$with_columns(
#'   rolling_row_var = pl$col("index")$rolling_var_by(
#'     "date",
#'     window_size = "2h"
#'   )
#' )
#'
#' # Compute the rolling var with the closure of windows on both sides
#' df_temporal$with_columns(
#'   rolling_row_var = pl$col("index")$rolling_var_by(
#'     "date",
#'     window_size = "2h",
#'     closed = "both"
#'   )
#' )
expr__rolling_var_by <- function(
  by,
  window_size,
  ...,
  min_periods = 1,
  closed = c("right", "both", "left", "none"),
  ddof = 1
) {
  wrap({
    check_dots_empty0(...)
    closed <- arg_match0(closed, values = c("both", "left", "right", "none"))
    self$`_rexpr`$rolling_var_by(
      by = as_polars_expr(by)$`_rexpr`,
      window_size = window_size,
      min_periods = min_periods,
      closed = closed,
      ddof = ddof
    )
  })
}

#' Compute exponentially-weighted moving variance
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams expr__rolling_max
#' @param com Specify decay in terms of center of mass, \eqn{\gamma}, with
#' \deqn{\alpha = \frac{1}{1 + \gamma} \; \forall \; \gamma \geq 0}.
#' @param span Specify decay in terms of span, \eqn{\theta}, with
#' \deqn{\alpha = \frac{2}{\theta + 1} \; \forall \; \theta \geq 1}
#' @param half_life Specify decay in terms of half-life, \eqn{\lambda}, with
#' \deqn{\alpha = 1 - \exp \left\{ \frac{ -\ln(2) }{ \lambda } \right\} \;
#' \forall \; \lambda > 0}
#' @param alpha Specify smoothing factor alpha directly, \eqn{0 < \alpha
#' \leq 1}.
#' @param adjust Divide by decaying adjustment factor in beginning periods to
#' account for imbalance in relative weightings:
#' * when `TRUE` (default), the EW function is calculated using weights
#'  \eqn{w_i = (1 - \alpha)^i};
#' * when `FALSE`, the EW function is calculated recursively by \deqn{y_0 = x_0}
#'   \deqn{y_t = (1 - \alpha)y_{t - 1} + \alpha x_t}
#' @param bias If `FALSE` (default), apply a correction to make the estimate
#' statistically unbiased.
#' @param ignore_nulls Ignore missing values when calculating weights.
#' * when `FALSE` (default), weights are based on absolute positions. For
#'   example, the weights of \eqn{x_0} and \eqn{x_2} used in calculating the
#'   final weighted average of (\eqn{x_0}, null, \eqn{x_2}) are
#'   \eqn{(1-\alpha)^2} and \eqn{1} if `adjust = TRUE`, and \eqn{(1-\alpha)^2}
#'   and \eqn{\alpha} if `adjust = FALSE`.
#' * when `TRUE`, weights are based on relative positions. For example, the
#'   weights of \eqn{x_0} and \eqn{x_2} used in calculating the final weighted
#'   average of (\eqn{x_0}, null, \eqn{x_2}) are \eqn{1-\alpha} and \eqn{1} if
#'   `adjust = TRUE`, and \eqn{1-\alpha} and \eqn{\alpha} if `adjust = FALSE`.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:3)
#' df$select(pl$col("a")$ewm_var(com = 1, ignore_nulls = FALSE))
expr__ewm_var <- function(
  ...,
  com,
  span,
  half_life,
  alpha,
  adjust = TRUE,
  bias = FALSE,
  min_periods = 1,
  ignore_nulls = FALSE
) {
  wrap({
    check_dots_empty0(...)
    alpha <- prepare_alpha(com, span, half_life, alpha)
    self$`_rexpr`$ewm_var(
      alpha = alpha,
      adjust = adjust,
      bias = bias,
      min_periods = min_periods,
      ignore_nulls = ignore_nulls
    )
  })
}

#' Compute exponentially-weighted moving standard deviation
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams expr__ewm_var
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:3)
#' df$select(pl$col("a")$ewm_std(com = 1, ignore_nulls = FALSE))
expr__ewm_std <- function(
  ...,
  com,
  span,
  half_life,
  alpha,
  adjust = TRUE,
  bias = FALSE,
  min_periods = 1,
  ignore_nulls = FALSE
) {
  wrap({
    check_dots_empty0(...)
    alpha <- prepare_alpha(com, span, half_life, alpha)
    self$`_rexpr`$ewm_std(
      alpha = alpha,
      adjust = adjust,
      bias = bias,
      min_periods = min_periods,
      ignore_nulls = ignore_nulls
    )
  })
}

#' Compute exponentially-weighted moving mean
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams expr__ewm_var
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:3)
#' df$select(pl$col("a")$ewm_mean(com = 1, ignore_nulls = FALSE))
expr__ewm_mean <- function(
  ...,
  com,
  span,
  half_life,
  alpha,
  adjust = TRUE,
  min_periods = 1,
  ignore_nulls = FALSE
) {
  wrap({
    check_dots_empty0(...)
    alpha <- prepare_alpha(com, span, half_life, alpha)
    self$`_rexpr`$ewm_mean(
      alpha = alpha,
      adjust = adjust,
      min_periods = min_periods,
      ignore_nulls = ignore_nulls
    )
  })
}

#' Compute time-based exponentially weighted moving average
#'
#' Given observations \eqn{x_0}, \eqn{x_1}, \ldots, \eqn{x_{n-1}} at times
#' \eqn{t_0}, \eqn{t_1}, \ldots, \eqn{t_{n-1}}, the EWMA is calculated as
#' \deqn{y_0 = x_0}
#' \deqn{\alpha_i = 1 - \exp \left\{ \frac{ -\ln(2)(t_i-t_{i-1}) } { \tau } \right\}}
#' \deqn{y_i = \alpha_i x_i + (1 - \alpha_i) y_{i-1}; \quad i > 0}
#' where \eqn{\tau} is the `half_life`.
#'
#' @inheritParams rlang::args_dots_empty
#' @param by Times to calculate average by. Should be DateTime, Date, UInt64,
#' UInt32, Int64, or Int32 data type.
#' @param half_life Unit over which observation decays to half its value. Can
#' be created either from a timedelta, or by using the following string
#' language:
#' - 1ns (1 nanosecond)
#' - 1us (1 microsecond)
#' - 1ms (1 millisecond)
#' - 1s (1 second)
#' - 1m (1 minute)
#' - 1h (1 hour)
#' - 1d (1 calendar day)
#' - 1w (1 calendar week)
#' - 1mo (1 calendar month)
#' - 1q (1 calendar quarter)
#' - 1y (1 calendar year)
#'
#' Or combine them: `"3d12h4m25s"` # 3 days, 12 hours, 4 minutes, and 25 seconds
#'
#' By "calendar day", we mean the corresponding time on the next day
#' (which may not be 24 hours, due to daylight savings). Similarly for
#' "calendar week", "calendar month", "calendar quarter", and "calendar year".
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   values = c(0, 1, 2, NA, 4),
#'   times = as.Date(
#'     c("2020-01-01", "2020-01-03", "2020-01-10", "2020-01-15", "2020-01-17")
#'   )
#' )
#' df$with_columns(
#'   result = pl$col("values")$ewm_mean_by("times", half_life = "4d")
#' )
expr__ewm_mean_by <- function(by, ..., half_life) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$ewm_mean_by(
      times = as_polars_expr(by)$`_rexpr`,
      half_life = half_life
    )
  })
}

#' Append expressions
#'
#' @inheritParams rlang::args_dots_empty
#' @param other Expression to append.
#' @param upcast If `TRUE` (default), cast both Series to the same supertype.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 8:10, b = c(NA, 4, 4))
#' df$select(pl$all()$head(1)$append(pl$all()$tail(1)))
expr__append <- function(other, ..., upcast = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$append(as_polars_expr(other)$`_rexpr`, upcast)
  })
}

#' Fill missing values with the next non-null value
#'
#' `r lifecycle::badge("superseded")`
#' This is an alias of [`$fill_null(strategy = "backward")`][expr__fill_null].
#'
#' @param limit The number of consecutive null values to backward fill.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 2, NA),
#'   b = c(4, NA, 6),
#'   c = c(NA, NA, 2)
#' )
#' df$select(pl$all()$backward_fill())
#' df$select(pl$all()$backward_fill(limit = 1))
expr__backward_fill <- function(limit = NULL) {
  self$fill_null(strategy = "backward", limit = limit) |>
    wrap()
}

#' Fill missing values with the last non-null value
#'
#' `r lifecycle::badge("superseded")`
#' This is an alias of [`$fill_null(strategy = "forward")`][expr__fill_null].
#'
#' @param limit The number of consecutive null values to forward fill.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 2, NA),
#'   b = c(4, NA, 6),
#'   c = c(2, NA, NA)
#' )
#' df$select(pl$all()$forward_fill())
#' df$select(pl$all()$forward_fill(limit = 1))
expr__forward_fill <- function(limit = NULL) {
  self$fill_null(strategy = "forward", limit = limit) |>
    wrap()
}

#' Return the `k` smallest elements
#'
#' Non-null elements are always preferred over null elements. The output is not
#' guaranteed to be in any particular order, call [$sort()][expr__sort] after
#' this function if you wish the output to be sorted. This has time complexity
#' \eqn{O(n)}.
#'
#' @param k Number of elements to return.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(value = c(1, 98, 2, 3, 99, 4))
#' df$select(
#'   top_k = pl$col("value")$top_k(k = 3),
#'   bottom_k = pl$col("value")$bottom_k(k = 3)
#' )
expr__bottom_k <- function(k = 5) {
  wrap({
    self$`_rexpr`$bottom_k(as_polars_expr(k)$`_rexpr`)
  })
}

#' Return the `k` largest elements
#'
#' @inherit expr__bottom_k description params
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(value = c(1, 98, 2, 3, 99, 4))
#' df$select(
#'   top_k = pl$col("value")$top_k(k = 3),
#'   bottom_k = pl$col("value")$bottom_k(k = 3)
#' )
expr__top_k <- function(k = 5) {
  wrap({
    self$`_rexpr`$top_k(as_polars_expr(k)$`_rexpr`)
  })
}

#' Return the elements corresponding to the `k` smallest elements of the `by`
#' column(s)
#'
#' @inherit expr__bottom_k description params
#' @inheritParams rlang::args_dots_empty
#' @param by Column(s) used to determine the smallest elements. Accepts
#' expression input. Strings are parsed as column names.
#' @param reverse Consider the `k` largest elements of the `by` column(s)
#' (instead of the `k` smallest). This can be specified per column by passing a
#' sequence of booleans.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = 1:6,
#'   b = 6:1,
#'   c = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#'
#' # Get the bottom 2 rows by column a or b:
#' df$select(
#'   pl$all()$bottom_k_by("a", 2)$name$suffix("_btm_by_a"),
#'   pl$all()$bottom_k_by("b", 2)$name$suffix("_btm_by_b")
#' )
#'
#' # Get the bottom 2 rows by multiple columns with given order.
#' df$select(
#'   pl$all()$
#'     bottom_k_by(c("c", "a"), 2, reverse = c(FALSE, TRUE))$
#'     name$suffix("_btm_by_ca"),
#'   pl$all()$
#'     bottom_k_by(c("c", "b"), 2, reverse = c(FALSE, TRUE))$
#'     name$suffix("_btm_by_cb"),
#' )
#'
#' # Get the bottom 2 rows by column a in each group
#' df$group_by("c", .maintain_order = TRUE)$agg(
#'   pl$all()$bottom_k_by("a", 2)
#' )$explode(pl$all()$exclude("c"))
expr__bottom_k_by <- function(by, k = 5, ..., reverse = FALSE) {
  wrap({
    check_dots_empty0(...)
    by <- parse_into_list_of_expressions(!!!by)
    self$`_rexpr`$bottom_k_by(by, as_polars_expr(k)$`_rexpr`, reverse)
  })
}

#' Return the elements corresponding to the `k` largest elements of the `by`
#' column(s)
#'
#' @inherit expr__bottom_k_by description params
#' @param reverse Consider the `k` smallest elements of the `by` column(s)
#' (instead of the `k` largest). This can be specified per column by passing a
#' sequence of booleans.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = 1:6,
#'   b = 6:1,
#'   c = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#'
#' # Get the top 2 rows by column a or b:
#' df$select(
#'   pl$all()$top_k_by("a", 2)$name$suffix("_btm_by_a"),
#'   pl$all()$top_k_by("b", 2)$name$suffix("_btm_by_b")
#' )
#'
#' # Get the top 2 rows by multiple columns with given order.
#' df$select(
#'   pl$all()$
#'     top_k_by(c("c", "a"), 2, reverse = c(FALSE, TRUE))$
#'     name$suffix("_btm_by_ca"),
#'   pl$all()$
#'     top_k_by(c("c", "b"), 2, reverse = c(FALSE, TRUE))$
#'     name$suffix("_btm_by_cb"),
#' )
#'
#' # Get the top 2 rows by column a in each group
#' df$group_by("c", .maintain_order = TRUE)$agg(
#'   pl$all()$top_k_by("a", 2)
#' )$explode(pl$all()$exclude("c"))
expr__top_k_by <- function(by, k = 5, ..., reverse = FALSE) {
  wrap({
    check_dots_empty0(...)
    by <- parse_into_list_of_expressions(!!!by)
    self$`_rexpr`$top_k_by(by, as_polars_expr(k)$`_rexpr`, reverse)
  })
}

#' Rounds up to the nearest integer value
#'
#' This only works on floating point Series.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(0.3, 0.5, 1.0, 1.1))
#' df$with_columns(
#'   ceil = pl$col("a")$ceil()
#' )
expr__ceil <- function() {
  wrap({
    self$`_rexpr`$ceil()
  })
}

#' Rounds down to the nearest integer value
#'
#' @inherit expr__ceil description
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(0.3, 0.5, 1.0, 1.1))
#' df$with_columns(
#'   floor = pl$col("a")$floor()
#' )
expr__floor <- function() {
  wrap({
    self$`_rexpr`$floor()
  })
}

#' Set values outside the given boundaries to the boundary value
#'
#' This method only works for numeric and temporal columns. To clip other data
#' types, consider writing a when-then-otherwise expression.
#'
#' @param lower_bound Lower bound. Accepts expression input. Non-expression
#' inputs are parsed as literals.
#' @param upper_bound Upper bound. Accepts expression input. Non-expression
#' inputs are parsed as literals.
#'
#' @details
#' This method only works for numeric and temporal columns. To clip other data
#' types, consider writing a when-then-otherwise expression.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(-50, 5, 50, NA))
#'
#' # Specifying both a lower and upper bound:
#' df$with_columns(
#'   clip = pl$col("a")$clip(1, 10)
#' )
#'
#' # Specifying only a single bound:
#' df$with_columns(
#'   clip = pl$col("a")$clip(upper_bound = 10)
#' )
expr__clip <- function(lower_bound = NULL, upper_bound = NULL) {
  wrap({
    if (!is.null(lower_bound)) {
      lower_bound <- as_polars_expr(lower_bound)$`_rexpr`
    }
    if (!is.null(upper_bound)) {
      upper_bound <- as_polars_expr(upper_bound)$`_rexpr`
    }
    self$`_rexpr`$clip(lower_bound, upper_bound)
  })
}

#' Drop all floating point NaN values
#'
#' @description
#' The original order of the remaining elements is preserved. A `NaN` value is
#' not the same as a `null` value. To drop `null` values, use
#' [$drop_nulls()][expr__drop_nulls].
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, NA, 3, NaN))
#' df$select(pl$col("a")$drop_nans())
expr__drop_nans <- function() {
  wrap({
    self$`_rexpr`$drop_nans()
  })
}

#' Drop all floating point null values
#'
#' @description
#' The original order of the remaining elements is preserved. A `null` value is
#' not the same as a `NaN` value. To drop `NaN` values, use
#' [$drop_nans()][expr__drop_nans].
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, NA, 3, NaN))
#' df$select(pl$col("a")$drop_nulls())
expr__drop_nulls <- function() {
  wrap({
    self$`_rexpr`$drop_nulls()
  })
}

#' Explode a list expression
#'
#' This means that every item is expanded to a new row.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   groups = c("a", "b"),
#'   values = list(1:2, 3:4)
#' )
#'
#' df$select(pl$col("values")$explode())
expr__explode <- function() {
  wrap({
    self$`_rexpr`$explode()
  })
}

#' Flatten a list or string column
#'
#' This is an alias for [$explode()][expr__explode].
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   group = c("a", "b", "b"),
#'   values = list(1:2, 2:3, 4)
#' )
#'
#' df$group_by("group")$agg(pl$col("values")$flatten())
expr__flatten <- function() {
  wrap({
    self$explode()
  })
}

#' Extend the Series with `n` copies of a value
#'
#' @param value A constant literal value or a unit expression with which to
#' extend the expression result Series. This can be `NA` to extend with nulls.
#' @param n The number of additional values that will be added.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(values = 1:3)
#' df$select(pl$col("values")$extend_constant(99, n = 2))
expr__extend_constant <- function(value, n) {
  wrap({
    self$`_rexpr`$extend_constant(
      as_polars_expr(value, as_lit = TRUE)$`_rexpr`,
      as_polars_expr(n)$`_rexpr`
    )
  })
}

#' Fill floating point `NaN` value with a fill value
#'
#' @param value Value used to fill `NaN` values.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, NA, 2, NaN))
#' df$with_columns(
#'   filled_nan = pl$col("a")$fill_nan(99)
#' )
expr__fill_nan <- function(value) {
  wrap({
    self$`_rexpr`$fill_nan(as_polars_expr(value, as_lit = TRUE)$`_rexpr`)
  })
}

#' Fill floating point null value with a fill value
#'
#' @param value Value used to fill null values. Can be missing if `strategy` is
#' specified. Accepts expression input, strings are parsed as column names.
#' @param strategy Strategy used to fill null values. Must be one of
#' `"forward"`, `"backward"`, `"min"`, `"max"`, `"mean"`, `"zero"`, `"one"`.
#' @param limit Number of consecutive null values to fill when using the
#' `"forward"` or `"backward"` strategy.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, NA, 2, NaN))
#' df$with_columns(
#'   filled_null_zero = pl$col("a")$fill_null(strategy = "zero"),
#'   filled_null_99 = pl$col("a")$fill_null(99),
#'   filled_null_forward = pl$col("a")$fill_null(strategy = "forward"),
#'   filled_null_expr = pl$col("a")$fill_null(pl$col("a")$median())
#' )
expr__fill_null <- function(value, strategy = NULL, limit = NULL) {
  wrap({
    check_exclusive_or_null(value, strategy)
    if (!is.null(strategy)) {
      strategy <- arg_match0(
        strategy,
        values = c("forward", "backward", "min", "max", "mean", "zero", "one")
      )
    }
    if (!strategy %in% c("forward", "backward") && !is.null(limit)) {
      abort('Can only specify `limit` when strategy is set to "backward" or "forward".')
    }
    if (!missing(value)) {
      self$`_rexpr`$fill_null(as_polars_expr(value, as_lit = TRUE)$`_rexpr`)
    } else {
      self$`_rexpr`$fill_null_with_strategy(strategy, limit)
    }
  })
}

#' Take values by index
#'
#' @param indices An expression that leads to a UInt32 dtyped Series.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   group = c("one", "one", "one", "two", "two", "two"),
#'   value = c(1, 98, 2, 3, 99, 4)
#' )
#' df$group_by("group", maintain_order = TRUE)$agg(
#'   pl$col("value")$gather(c(2, 1))
#' )
expr__gather <- function(indices) {
  wrap({
    self$`_rexpr`$gather(as_polars_expr(indices)$cast(pl$Int64, strict = TRUE)$`_rexpr`)
  })
}

# TODO: difference with "gather" is unclear
#' Return a single value by index
#'
#' @param index An expression that leads to a UInt32 dtyped Series.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   group = c("one", "one", "one", "two", "two", "two"),
#'   value = c(1, 98, 2, 3, 99, 4)
#' )
#' df$group_by("group", maintain_order = TRUE)$agg(
#'   pl$col("value")$get(1)
#' )
expr__get <- function(index) {
  wrap({
    self$`_rexpr`$get(as_polars_expr(index)$cast(pl$Int64, strict = TRUE)$`_rexpr`)
  })
}

#' Take every `n`-th value in the Series and return as a new Series
#'
#' @param n Gather every n-th row.
#' @param offset Starting index.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(foo = 1:9)
#' df$select(pl$col("foo")$gather_every(3))
#' df$select(pl$col("foo")$gather_every(3, offset = 1))
expr__gather_every <- function(n, offset = 0) {
  wrap({
    self$`_rexpr`$gather_every(n, offset)
  })
}

#' Fill null values using interpolation
#'
#' @param method Interpolation method. Must be one of `"linear"` or `"nearest"`.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, NA, 3), b = c(1, NaN, 3))
#' df$with_columns(
#'   a_interpolated = pl$col("a")$interpolate(),
#'   b_interpolated = pl$col("b")$interpolate()
#' )
expr__interpolate <- function(method = c("linear", "nearest")) {
  wrap({
    method <- arg_match0(method, values = c("linear", "nearest"))
    self$`_rexpr`$interpolate(method)
  })
}

#' Fill null values using interpolation based on another column
#'
#' @param by Column to interpolate values based on.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, NA, NA, 3), b = c(1, 2, 7, 8))
#' df$with_columns(
#'   a_interpolated = pl$col("a")$interpolate_by("b")
#' )
expr__interpolate_by <- function(by) {
  wrap({
    self$`_rexpr`$interpolate_by(as_polars_expr(by)$`_rexpr`)
  })
}

#' Get the first n rows
#'
#' This is an alias for [$head()][expr__head].
#'
#' @param n Number of rows to return.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:9)
#' df$select(pl$col("a")$limit(3))
expr__limit <- function(n = 10) {
  wrap({
    self$head(n)
  })
}

#' Calculate the lower bound
#'
#' Returns a unit Series with the lowest value possible for the dtype of this
#' expression.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:3)
#' df$select(pl$col("a")$lower_bound())
expr__lower_bound <- function() {
  wrap({
    self$`_rexpr`$lower_bound()
  })
}

#' Calculate the upper bound
#'
#' Returns a unit Series with the highest value possible for the dtype of this
#' expression.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:3)
#' df$select(pl$col("a")$upper_bound())
expr__upper_bound <- function() {
  wrap({
    self$`_rexpr`$upper_bound()
  })
}

#' Bin continuous values into discrete categories
#'
#' `r lifecycle::badge("experimental")`
#'
#' @inheritParams rlang::args_dots_empty
#' @param breaks List of unique cut points.
#' @param labels Names of the categories. The number of labels must be equal to
#' the number of cut points plus one.
#' @param left_closed Set the intervals to be left-closed instead of
#' right-closed.
#' @param include_breaks Include a column with the right endpoint of the bin
#' each observation falls in. This will change the data type of the output from
#' a Categorical to a Struct.
#'
#' @inherit as_polars_expr return
#' @examples
#' # Divide a column into three categories.
#' df <- pl$DataFrame(foo = -2:2)
#' df$with_columns(
#'   cut = pl$col("foo")$cut(c(-1, 1), labels = c("a", "b", "c"))
#' )
#'
#' # Add both the category and the breakpoint.
#' df$with_columns(
#'   cut = pl$col("foo")$cut(c(-1, 1), include_breaks = TRUE)
#' )$unnest("cut")
expr__cut <- function(
  breaks,
  ...,
  labels = NULL,
  left_closed = FALSE,
  include_breaks = FALSE
) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$cut(
      breaks = breaks,
      labels = labels,
      left_closed = left_closed,
      include_breaks = include_breaks
    )
  })
}

#' Bin continuous values into discrete categories based on their quantiles
#'
#' `r lifecycle::badge("experimental")`
#'
#' @inheritParams rlang::args_dots_empty
#' @inheritParams expr__cut
#' @param quantiles Either a vector of quantile probabilities between 0 and 1
#' or a positive integer determining the number of bins with uniform
#' probability.
#' @param labels Names of the categories. The number of labels must be equal to
#' the number of categories.
#' @param allow_duplicates If `TRUE`, duplicates in the resulting quantiles are
#' dropped, rather than raising an error. This can happen even with unique
#' probabilities, depending on the data.
#'
#' @inherit as_polars_expr return
#' @examples
#' # Divide a column into three categories according to pre-defined quantile
#' # probabilities.
#' df <- pl$DataFrame(foo = -2:2)
#' df$with_columns(
#'   qcut = pl$col("foo")$qcut(c(0.25, 0.75), labels = c("a", "b", "c"))
#' )
#'
#' # Divide a column into two categories using uniform quantile probabilities.
#' df$with_columns(
#'   qcut = pl$col("foo")$qcut(2, labels = c("low", "high"), left_closed = TRUE)
#' )
#'
#' # Add both the category and the breakpoint.
#' df$with_columns(
#'   qcut = pl$col("foo")$qcut(c(0.25, 0.75), include_breaks = TRUE)
#' )$unnest("qcut")
expr__qcut <- function(
  quantiles,
  ...,
  labels = NULL,
  left_closed = FALSE,
  allow_duplicates = FALSE,
  include_breaks = FALSE
) {
  wrap({
    check_dots_empty0(...)
    if (is_scalar_integerish(quantiles)) {
      self$`_rexpr`$qcut_uniform(
        n_bins = quantiles,
        labels = labels,
        left_closed = left_closed,
        allow_duplicates = allow_duplicates,
        include_breaks = include_breaks
      )
    } else {
      self$`_rexpr`$qcut(
        probs = quantiles,
        labels = labels,
        left_closed = left_closed,
        allow_duplicates = allow_duplicates,
        include_breaks = include_breaks
      )
    }
  })
}

#' Create a single chunk of memory for this Series
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 1, 2))
#'
#' # Create a Series with 3 nulls, append column a then rechunk
#' df$select(pl$repeat_(NA, 3)$append(pl$col("a"))$rechunk())
expr__rechunk <- function() {
  wrap({
    self$`_rexpr`$rechunk()
  })
}

#' Reinterpret the underlying bits as a signed/unsigned integer
#'
#' This operation is only allowed for 64-bit integers. For lower bits integers,
#' you can safely use the [$cast()][expr__cast] operation.
#'
#' @inheritParams rlang::args_dots_empty
#' @param signed If `TRUE` (default), reinterpret as pl$Int64. Otherwise,
#' reinterpret as pl$UInt64.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 1, 2))$cast(pl$UInt64)
#'
#' # Create a Series with 3 nulls, append column a then rechunk
#' df$with_columns(
#'   reinterpreted = pl$col("a")$reinterpret()
#' )
expr__reinterpret <- function(..., signed = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$reinterpret(signed)
  })
}

#' Repeat the elements in this Series as specified in the given expression
#'
#' The repeated elements are expanded into a List dtype.
#'
#' @param by Numeric column that determines how often the values will be
#' repeated. The column will be coerced to UInt32. Give this dtype to make the
#' coercion a no-op. Accepts expression input, strings are parsed as column
#' names.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c("x", "y", "z"), n = 1:3)
#'
#' df$with_columns(
#'   repeated = pl$col("a")$repeat_by("n")
#' )
expr__repeat_by <- function(by) {
  wrap({
    self$`_rexpr`$repeat_by(as_polars_expr(by)$`_rexpr`)
  })
}

#' Replace the given values by different values of the same data type.
#'
#' This allows one to recode values in a column, leaving all other values
#' unchanged. See [`$replace_strict()`][expr__replace_strict] to give a default
#' value to all other values and to specify the output datatype.
#'
#' @param old Value or vector of values to replace. Accepts expression input.
#' Vectors are parsed as Series, other non-expression inputs are parsed as
#' literals. Also accepts a list of values like `list(old = new)`.
#' @param new Value or vector of values to replace by. Accepts expression
#' input. Vectors are parsed as Series, other non-expression inputs are parsed
#' as literals. Length must match the length of `old` or have length 1.
#'
#' @details
#' The global string cache must be enabled when replacing categorical values.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 2, 2, 3))
#'
#' # "old" and "new" can take vectors of length 1 or of same length
#' df$with_columns(replaced = pl$col("a")$replace(2, 100))
#' df$with_columns(replaced = pl$col("a")$replace(c(2, 3), c(100, 200)))
#'
#' # "old" can be a named list where names are values to replace, and values are
#' # the replacements
#' mapping <- list(`2` = 100, `3` = 200)
#' df$with_columns(replaced = pl$col("a")$replace(mapping))
#'
#' # The original data type is preserved when replacing by values of a
#' # different data type. Use $replace_strict() to replace and change the
#' # return data type.
#' df <- pl$DataFrame(a = c("x", "y", "z"))
#' mapping <- list(x = 1, y = 2, z = 3)
#' df$with_columns(replaced = pl$col("a")$replace(mapping))
#'
#' # "old" and "new" can take Expr
#' df <- pl$DataFrame(a = c(1, 2, 2, 3), b = c(1.5, 2.5, 5, 1))
#' df$with_columns(
#'   replaced = pl$col("a")$replace(
#'     old = pl$col("a")$max(),
#'     new = pl$col("b")$sum()
#'   )
#' )
expr__replace <- function(old, new) {
  wrap({
    if (missing(new)) {
      if (!is.list(old)) {
        abort("`new` argument is required if `old` argument is not a list.")
      }
      new <- unlist(old, use.names = FALSE)
      old <- names(old)
    }
    self$`_rexpr`$replace(
      as_polars_expr(old, as_lit = TRUE)$`_rexpr`,
      as_polars_expr(new, as_lit = TRUE)$`_rexpr`
    )
  })
}

#' Replace all values by different values
#'
#' This changes all the values in a column, either using a specific replacement
#' or a default one. See [`$replace()`][expr__replace] to replace only a subset
#' of values.
#'
#' @inheritParams rlang::args_dots_empty
#' @inherit expr__replace params details
#' @param default Set values that were not replaced to this value. If `NULL`
#' (default), an error is raised if any values were not replaced. Accepts
#' expression input. Non-expression inputs are parsed as literals.
#' @param return_dtype The data type of the resulting expression. If `NULL`
#' (default), the data type is determined automatically based on the other
#' inputs.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 2, 2, 3))
#'
#' # "old" and "new" can take vectors of length 1 or of same length
#' df$with_columns(replaced = pl$col("a")$replace_strict(2, 100, default = 1))
#' df$with_columns(
#'   replaced = pl$col("a")$replace_strict(c(2, 3), c(100, 200), default = 1)
#' )
#'
#' # "old" can be a named list where names are values to replace, and values are
#' # the replacements
#' mapping <- list(`2` = 100, `3` = 200)
#' df$with_columns(replaced = pl$col("a")$replace_strict(mapping, default = -1))
#'
#' # By default, an error is raised if any non-null values were not replaced.
#' # Specify a default to set all values that were not matched.
#' tryCatch(
#'   df$with_columns(replaced = pl$col("a")$replace_strict(mapping)),
#'   error = function(e) print(e)
#' )
#'
#' # one can specify the data type to return instead of automatically
#' # inferring it
#' df$with_columns(
#'   replaced = pl$col("a")$replace_strict(
#'     mapping,
#'     default = 1, return_dtype = pl$Int32
#'   )
#' )
#'
#' # "old", "new", and "default" can take Expr
#' df <- pl$DataFrame(a = c(1, 2, 2, 3), b = c(1.5, 2.5, 5, 1))
#' df$with_columns(
#'   replaced = pl$col("a")$replace_strict(
#'     old = pl$col("a")$max(),
#'     new = pl$col("b")$sum(),
#'     default = pl$col("b"),
#'   )
#' )
expr__replace_strict <- function(
  old,
  new,
  ...,
  default = NULL,
  return_dtype = NULL
) {
  wrap({
    check_dots_empty0(...)
    if (missing(new)) {
      if (!is.list(old)) {
        abort("`new` argument is required if `old` argument is not a list.")
      }
      new <- unlist(old, use.names = FALSE)
      old <- names(old)
    }
    if (!is.null(default)) {
      default <- as_polars_expr(default, as_lit = TRUE)$`_rexpr`
    }
    self$`_rexpr`$replace_strict(
      as_polars_expr(old, as_lit = TRUE)$`_rexpr`,
      as_polars_expr(new, as_lit = TRUE)$`_rexpr`,
      default = default,
      return_dtype = return_dtype$`_dt`
    )
  })
}

#' Compress the column data using run-length encoding
#'
#' Run-length encoding (RLE) encodes data by storing each run of identical
#' values as a single value and its length.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(1, 1, 2, 1, NA, 1, 3, 3))
#'
#' df$select(pl$col("a")$rle())$unnest("a")
expr__rle <- function() {
  wrap({
    self$`_rexpr`$rle()
  })
}

#' Get a distinct integer ID for each run of identical values
#'
#' The ID starts at 0 and increases by one each time the value of the column
#' changes.
#'
#' @details
#' This functionality is especially useful for defining a new group for every
#' time a column’s value changes, rather than for every distinct value of that
#' column.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 2, 1, 1, 1),
#'   b = c("x", "x", NA, "y", "y")
#' )
#'
#' df$with_columns(
#'   rle_id_a = pl$col("a")$rle_id(),
#'   rle_id_ab = pl$struct("a", "b")$rle_id()
#' )
expr__rle_id <- function() {
  wrap({
    self$`_rexpr`$rle_id()
  })
}

#' Sample from this expression
#'
#' @inheritParams rlang::args_dots_empty
#' @param n Number of items to return. Cannot be used with `fraction.` Defaults
#' to 1 if `fraction` is `NULL`.
#' @param fraction Fraction of items to return. Cannot be used with `n`.
#' @param with_replacement Allow values to be sampled more than once.
#' @param shuffle Shuffle the order of sampled data points.
#' @param seed Seed for the random number generator. If `NULL` (default), a
#' random seed is generated for each sample operation.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:3)
#' df$select(pl$col("a")$sample(
#'   fraction = 1, with_replacement = TRUE, seed = 1
#' ))
expr__sample <- function(
  n = NULL,
  ...,
  fraction = NULL,
  with_replacement = FALSE,
  shuffle = FALSE,
  seed = NULL
) {
  wrap({
    check_dots_empty0(...)
    if (!is.null(fraction)) {
      if (!is.null(n)) {
        abort("Can't specify both `n` and `fraction`.")
      }
      self$`_rexpr`$sample_frac(
        as_polars_expr(fraction, as_lit = TRUE)$`_rexpr`,
        with_replacement = with_replacement,
        shuffle = shuffle,
        seed = seed
      )
    } else {
      if (is.null(n)) {
        n <- 1
      }
      self$`_rexpr`$sample_n(
        as_polars_expr(n, as_lit = TRUE)$`_rexpr`,
        with_replacement = with_replacement,
        shuffle = shuffle,
        seed = seed
      )
    }
  })
}

#' Round underlying floating point data by decimals digits
#'
#' @param decimals Number of decimals to round by.
#' @param mode Rounding mode. One of `"half_to_even"` (default) or `"half_away_from_zero"`.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(0.5, 1.5, 2.5, 3.5))
#'
#' df$with_columns(
#'   half_to_even = pl$col("a")$round(0),
#'   half_away_from_zero = pl$col("a")$round(0, "half_away_from_zero"),
#' )
expr__round <- function(decimals, mode = c("half_to_even", "half_away_from_zero")) {
  wrap({
    mode <- arg_match0(mode, values = c("half_to_even", "half_away_from_zero"))
    self$`_rexpr`$round(decimals, mode)
  })
}

#' Round to a number of significant figures
#'
#' @param digits Number of significant figures to round to.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(0.01234, 3.333, 1234))
#'
#' df$with_columns(
#'   rounded = pl$col("a")$round_sig_figs(2)
#' )
expr__round_sig_figs <- function(digits) {
  wrap({
    self$`_rexpr`$round_sig_figs(digits)
  })
}

#' Shift values by the given number of indices
#'
#' @inheritParams rlang::args_dots_empty
#' @param n Number of indices to shift forward. If a negative value is
#' passed, values are shifted in the opposite direction instead.
#' @param fill_value Fill the resulting null values with this value.
#'
#' @inherit as_polars_expr return
#' @examples
#' # By default, values are shifted forward by one index.
#' df <- pl$DataFrame(a = 1:4)
#' df$with_columns(shift = pl$col("a")$shift())
#'
#' # Pass a negative value to shift in the opposite direction instead.
#' df$with_columns(shift = pl$col("a")$shift(-2))
#'
#' # Specify fill_value to fill the resulting null values.
#' df$with_columns(shift = pl$col("a")$shift(-2, fill_value = 100))
expr__shift <- function(n = 1, ..., fill_value = NULL) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$shift(
      as_polars_expr(n)$`_rexpr`,
      as_polars_expr(fill_value)$`_rexpr`
    )
  })
}

#' Shrink numeric columns to the minimal required datatype
#'
#' Shrink to the dtype needed to fit the extrema of this Series. This can be
#' used to reduce memory pressure.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = c(-112, 2, 112))$cast(pl$Int64)
#' df$with_columns(
#'   shrunk = pl$col("a")$shrink_dtype()
#' )
expr__shrink_dtype <- function() {
  wrap({
    self$`_rexpr`$shrink_dtype()
  })
}

#' Shuffle the contents of this expression
#'
#' Note this is shuffled independently of any other column or Expression.
#' If you want each row to stay the same use
#' [`df$sample(shuffle = TRUE)`][dataframe__sample].
#'
#' @param seed Integer indicating the seed for the random number generator. If
#' `NULL` (default), a random seed is generated each time the shuffle is called.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:3)
#' df$with_columns(
#'   shuffled = pl$col("a")$shuffle(seed = 1)
#' )
expr__shuffle <- function(seed = NULL) {
  wrap({
    self$`_rexpr`$shuffle(seed)
  })
}

#' Flags the expression as "sorted"
#'
#' @description
#' Enables downstream code to user fast paths for sorted arrays.
#'
#' **Warning:** This can lead to incorrect results if the data is NOT sorted!!
#' Use with care!
#'
#' @inheritParams rlang::args_dots_empty
#' @param descending Whether the Series order is descending.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = 1:3)
#' df$select(pl$col("a")$set_sorted()$max())
expr__set_sorted <- function(..., descending = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$set_sorted_flag(descending)
  })
}

#' Cast to physical representation of the logical dtype
#'
#' @description
#' The following data types will be changed:
#' * Date -> Int32
#' * Datetime -> Int64
#' * Time -> Int64
#' * Duration -> Int64
#' * Categorical -> UInt32
#' * List(inner) -> List(physical of inner)
#'
#' Other data types will be left unchanged.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = factor(c("a", "x", NA, "a")))
#' df$with_columns(
#'   phys = pl$col("a")$to_physical()
#' )
expr__to_physical <- function() {
  wrap({
    self$`_rexpr`$to_physical()
  })
}

#' Used in ewm_* functions
#' @noRd
prepare_alpha <- function(com = NULL, span = NULL, half_life = NULL, alpha = NULL) {
  check_exclusive(com, span, half_life, alpha, .call = caller_env())

  if (!missing(com)) {
    check_number_decimal(com, min = 0, call = caller_env())
    1 / (1 + com)
  } else if (!missing(span)) {
    check_number_decimal(span, min = 1, call = caller_env())
    2 / (span + 1)
  } else if (!missing(half_life)) {
    check_number_decimal(half_life, min = 0, call = caller_env())
    1 - exp(-log(2) / half_life)
  } else if (!missing(alpha)) {
    # Can't use "min" arg in check_number_decimal() since requirement is > 0
    check_number_decimal(alpha, call = caller_env())
    if (!(alpha > 0 && alpha <= 1)) {
      abort("`alpha` must be between greater than 0 and lower or equal to 1.", call = caller_env())
    }

    alpha
  }
}
#' Evaluate the number of set bits.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(n = c(-1L, 0L, 2L, 1L))
#' df$with_columns(set_bits = pl$col("n")$bitwise_count_ones())
expr__bitwise_count_ones <- function() {
  self$`_rexpr`$bitwise_count_ones() |>
    wrap()
}

#' Evaluate the number of unset bits.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(n = c(-1L, 0L, 2L, 1L))
#' df$with_columns(unset_bits = pl$col("n")$bitwise_count_zeros())
expr__bitwise_count_zeros <- function() {
  self$`_rexpr`$bitwise_count_zeros() |>
    wrap()
}

#' Evaluate the number most-significant set bits before seeing an unset bit.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(n = c(-1L, 0L, 2L, 1L))
#' df$with_columns(leading_ones = pl$col("n")$bitwise_leading_ones())
expr__bitwise_leading_ones <- function() {
  self$`_rexpr`$bitwise_leading_ones() |>
    wrap()
}

#' Evaluate the number most-significant unset bits before seeing a set bit.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(n = c(-1L, 0L, 2L, 1L))
#' df$with_columns(leading_zeros = pl$col("n")$bitwise_leading_zeros())
expr__bitwise_leading_zeros <- function() {
  self$`_rexpr`$bitwise_leading_zeros() |>
    wrap()
}

#' Evaluate the number least-significant set bits before seeing an unset bit.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(n = c(-1L, 0L, 2L, 1L))
#' df$with_columns(trailing_ones = pl$col("n")$bitwise_trailing_ones())
expr__bitwise_trailing_ones <- function() {
  self$`_rexpr`$bitwise_trailing_ones() |>
    wrap()
}

#' Evaluate the number least-significant unset bits before seeing a set bit.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(n = c(-1L, 0L, 2L, 1L))
#' df$with_columns(trailing_zeros = pl$col("n")$bitwise_trailing_zeros())
expr__bitwise_trailing_zeros <- function() {
  self$`_rexpr`$bitwise_trailing_zeros() |>
    wrap()
}

#' Perform an aggregation of bitwise ANDs.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(n = -1:1)
#' df$select(pl$col("n")$bitwise_and())
#'
#' df <- pl$DataFrame(
#'   grouper = c("a", "a", "a", "b", "b"),
#'   n = c(-1L, 0L, 1L, -1L, 1L)
#' )
#' df$group_by("grouper", .maintain_order = TRUE)$agg(pl$col("n")$bitwise_and())
expr__bitwise_and <- function() {
  self$`_rexpr`$bitwise_and() |>
    wrap()
}

#' Perform an aggregation of bitwise ORs.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(n = -1:1)
#' df$select(pl$col("n")$bitwise_or())
#'
#' df <- pl$DataFrame(
#'   grouper = c("a", "a", "a", "b", "b"),
#'   n = c(-1L, 0L, 1L, -1L, 1L)
#' )
#' df$group_by("grouper", .maintain_order = TRUE)$agg(pl$col("n")$bitwise_or())
expr__bitwise_or <- function() {
  self$`_rexpr`$bitwise_or() |>
    wrap()
}

#' Perform an aggregation of bitwise XORs.
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(n = -1:1)
#' df$select(pl$col("n")$bitwise_xor())
#'
#' df <- pl$DataFrame(
#'   grouper = c("a", "a", "a", "b", "b"),
#'   n = c(-1L, 0L, 1L, -1L, 1L)
#' )
#' df$group_by("grouper", .maintain_order = TRUE)$agg(pl$col("n")$bitwise_xor())
expr__bitwise_xor <- function() {
  self$`_rexpr`$bitwise_xor() |>
    wrap()
}
