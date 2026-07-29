# The env for storing all expr cat methods
polars_expr_cat_methods <- new.env(parent = emptyenv())

namespace_expr_cat <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x$`_rexpr`

  class(self) <- c(
    "polars_namespace_expr_cat",
    "polars_namespace_expr",
    "polars_object"
  )
  self
}

#' Get the categories stored in this data type
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' `$cat$get_categories()` is deprecated. To get the distinct values present
#' in a Categorical column, use `$unique()`. For the fixed category list of
#' an Enum, use its `dtype$categories`.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   cats = factor(c("z", "z", "k", "a", "b")),
#'   vals = factor(c(3, 1, 2, 2, 3))
#' )
#' df
#'
#' df$select(
#'   pl$col("cats")$cat$get_categories()
#' )
#' df$select(
#'   pl$col("vals")$cat$get_categories()
#' )
expr_cat_get_categories <- function() {
  deprecate_warn(
    c(
      `!` = sprintf(
        "%s is deprecated as of %s 1.14.0.",
        format_fn("cat$get_categories"),
        format_pkg("polars")
      ),
      i = sprintf(
        "To get the distinct values present in a Categorical column, use %s. For the fixed category list of an Enum, use its %s.", # nolint: line_length_linter
        format_fn("unique"),
        format_code("dtype$categories")
      )
    )
  )
  self$`_rexpr`$cat_get_categories() |>
    wrap()
}

#' Convert to a Categorical or Enum data type
#'
#' `r lifecycle::badge("experimental")`
#' Convert physical values to a Categorical or Enum data type. The input must
#' be of the physical type of the target data type, i.e. `UInt32` for
#' [Categorical][polars_dtype] and `UInt8`, `UInt16` or `UInt32` for
#' [Enum][polars_dtype] (depending on the number of categories).
#'
#' @inheritParams rlang::args_dots_empty
#' @param dtype A Polars DataType or DataTypeExpr. Must be a
#' [Categorical][polars_dtype] or an [Enum][polars_dtype].
#' @param strict If `TRUE` (default), raise an error if a value is not a valid
#' category. If `FALSE`, such values become `null`.
#'
#' @inherit as_polars_expr return
#' @seealso
#' - [`<expr>$cat$physical()`][expr_cat_physical]
#' @examples
#' dtype <- pl$Enum(c("bar", "foo", "x"))
#'
#' df <- pl$DataFrame(x = c(1, 0, 1, 2, NA))$cast(pl$UInt8)
#' df$with_columns(cat = pl$col("x")$cat$to(dtype))
#'
#' # Values that are not valid categories are converted to `null` when
#' # `strict = FALSE`
#' df2 <- pl$DataFrame(x = c(1, 0, 4))$cast(pl$UInt8)
#' df2$with_columns(cat = pl$col("x")$cat$to(dtype, strict = FALSE))
expr_cat_to <- function(dtype, ..., strict = TRUE) {
  wrap({
    check_dots_empty0(...)
    dtype <- as_polars_dtype_expr(dtype)
    self$`_rexpr`$cat_to(dtype$`_datatype_expr`, strict)
  })
}

#' Get the physical values of a Categorical or Enum data type
#'
#' `r lifecycle::badge("experimental")`
#' Get the physical representation of a [Categorical][polars_dtype] or an
#' [Enum][polars_dtype] column, i.e. the integer codes used to store the
#' categories.
#'
#' @inherit as_polars_expr return
#' @seealso
#' - [`<expr>$cat$to()`][expr_cat_to]
#' @examples
#' df <- pl$DataFrame(x = c("foo", "bar", "foo", "x", NA))$cast(
#'   pl$Enum(c("bar", "foo", "x"))
#' )
#'
#' df$with_columns(physical = pl$col("x")$cat$physical())
expr_cat_physical <- function() {
  self$`_rexpr`$cat_physical() |>
    wrap()
}
