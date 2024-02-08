#' Sum all elements in an array
#'
#' @return Expr
#' @aliases arr_sum
#' @examples
#' df = pl$DataFrame(list(values = list(c(1, 2, 3, NA), c(2, 3), NA_real_)))
#' df$with_columns(sum = pl$col("values")$arr$sum())
ExprArr_sum = function() .pr$Expr$arr_sum(self)

#' Find the maximum value in an array
#'
#' @return Expr
#' @aliases arr_max
#' @examples
#' df = pl$DataFrame(list(values = list(c(1, 2, 3, NA), c(2, 3), NA_real_)))
#' df$with_columns(max = pl$col("values")$arr$max())
ExprArr_max = function() .pr$Expr$arr_max(self)

#' Find the minimum value in an array
#'
#' @return Expr
#' @aliases arr_min
#' @examples
#' df = pl$DataFrame(list(values = list(c(1, 2, 3, NA), c(2, 3), NA_real_)))
#' df$with_columns(min = pl$col("values")$arr$min())
ExprArr_min = function() .pr$Expr$arr_min(self)

#' Sort values in an array
#'
#' @param descending Sort values in descending order
#' @return Expr
#' @aliases arr_sort
#' @examples
#' df = pl$DataFrame(list(values = list(c(1, 2, 3, NA), c(2, 3), NA_real_)))
#' df$with_columns(sort = pl$col("values")$arr$sort())
ExprArr_sort = function(descending = FALSE) .pr$Expr$arr_sort(self, descending)

#' Reverse values in an array
#'
#' @return Expr
#' @aliases arr_reverse
#' @examples
#' df = pl$DataFrame(list(values = list(c(1, 2, 3, NA), c(2, 3), NA_real_)))
#' df$with_columns(reverse = pl$col("values")$arr$reverse())
ExprArr_reverse = function() .pr$Expr$arr_reverse(self)

#' Get unique values in an array
#'
#' @return Expr
#' @aliases arr_unique
#' @examples
#' df = pl$DataFrame(list(values = list(c(2, 2, NA), c(1, 2, 3), NA_real_)))
#' df$with_columns(unique = pl$col("values")$arr$unique())
ExprArr_unique = function() .pr$Expr$arr_unique(self)


#' Get the value by index in an array
#'
#' This allows to extract one value per array only.
#'
#' @param index An Expr or something coercible to an Expr, that must return a
#'   single index. Values are 0-indexed (so index 0 would return the first item
#'   of every subarray) and negative values start from the end (index `-1`
#'   returns the last item). If the index is out of bounds, it will return a
#'   `null`. Strings are parsed as column names.
#'
#' @return Expr
#' @aliases arr_get
#' @examples
#' df = pl$DataFrame(
#'   values = list(c(2, 2, NA), c(1, 2, 3), NA_real_, NULL),
#'   idx = c(1, 2, NA, 3)
#' )
#' df$with_columns(
#'   using_expr = pl$col("values")$arr$get("idx"),
#'   val_0 = pl$col("values")$arr$get(0),
#'   val_minus_1 = pl$col("values")$arr$get(-1),
#'   val_oob = pl$col("values")$arr$get(10)
#' )
ExprArr_get = function(index) .pr$Expr$arr_get(self, wrap_e(index, str_to_lit = FALSE))

#' Check if array contains a given value
#'
#' @param item Expr or something coercible to an Expr. Strings are *not* parsed
#' as columns.
#'
#' @return Expr
#' @aliases arr_contains
#' @examples
#' df = pl$DataFrame(
#'   a = list(3:1, NULL, 1:2),
#'   item = 0:2
#' )
#' df$with_columns(
#'   with_expr = pl$col("a")$arr$contains(pl$col("item")),
#'   with_lit = pl$col("a")$arr$contains(1)
#' )
ExprArr_contains = function(item) .pr$Expr$arr_contains(self, wrap_e(item))

#' Join elements of an array
#'
#' Join all string items in a subarray and place a separator between them. This
#' only works on columns of type `list[str]`.
#'
#' @param separator String to separate the items with. Can be an Expr. Strings
#'   are *not* parsed as columns.
#' @inheritParams pl_concat_str
#'
#' @return Expr
#' @aliases arr_join
#' @examples
#' df = pl$DataFrame(
#'   s = list(c("a", "b", "c"), c("x", "y"), c("e", NA)),
#'   separator = c("-", "+", "/")
#' )
#' df$with_columns(
#'   join_with_expr = pl$col("s")$arr$join(pl$col("separator")),
#'   join_with_lit = pl$col("s")$arr$join(" "),
#'   join_ignore_null = pl$col("s")$arr$join(" ", ignore_nulls = TRUE)
#' )
ExprArr_join = function(separator, ignore_nulls = FALSE) {
  .pr$Expr$arr_join(self, separator, ignore_nulls) |>
    unwrap("in $arr$join():")
}

#' Get the index of the minimal value in an array
#'
#' @return Expr
#' @aliases arr_arg_min
#' @examples
#' df = pl$DataFrame(list(s = list(1:2, 2:1)))
#' df$with_columns(
#'   arg_min = pl$col("s")$arr$arg_min()
#' )
ExprArr_arg_min = function() .pr$Expr$arr_arg_min(self)

#' Get the index of the maximal value in an array
#'
#' @return Expr
#' @aliases arr_arg_max
#' @examples
#' df = pl$DataFrame(list(s = list(1:2, 2:1)))
#' df$with_columns(
#'   arg_max = pl$col("s")$arr$arg_max()
#' )
ExprArr_arg_max = function() .pr$Expr$arr_arg_max(self)

#' Evaluate whether all boolean values in an array are true
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   list(a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), NA, c()))
#' )
#' df$with_columns(all = pl$col("a")$arr$all())
ExprArr_all = function() .pr$Expr$arr_all(self)

#' Evaluate whether any boolean values in an array are true
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   list(a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), NA, c()))
#' )
#' df$with_columns(any = pl$col("a")$arr$any())
ExprArr_any = function() .pr$Expr$arr_any(self)
