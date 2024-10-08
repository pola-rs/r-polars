#' Sum all elements in an array
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   values = list(c(1, 2), c(3, 4), c(NA_real_, 6)),
#'   schema = list(values = pl$Array(pl$Float64, 2))
#' )
#' df$with_columns(sum = pl$col("values")$arr$sum())
ExprArr_sum = function() .pr$Expr$arr_sum(self)

#' Find the maximum value in an array
#'
#' @return Expr
#' @inherit ExprStr_to_titlecase details
#' @examples
#' df = pl$DataFrame(
#'   values = list(c(1, 2), c(3, 4), c(NA_real_, NA_real_)),
#'   schema = list(values = pl$Array(pl$Float64, 2))
#' )
#' df$with_columns(max = pl$col("values")$arr$max())
ExprArr_max = function() {
  .pr$Expr$arr_max(self)
}

#' Find the minimum value in an array
#'
#' @inherit ExprStr_to_titlecase details
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   values = list(c(1, 2), c(3, 4), c(NA_real_, NA_real_)),
#'   schema = list(values = pl$Array(pl$Float64, 2))
#' )
#' df$with_columns(min = pl$col("values")$arr$min())
ExprArr_min = function() {
  .pr$Expr$arr_min(self)
}

#' Find the median in an array
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   values = list(c(2, 1, 4), c(8.4, 3.2, 1)),
#'   schema = list(values = pl$Array(pl$Float64, 3))
#' )
#' df$with_columns(median = pl$col("values")$arr$median())
ExprArr_median = function() {
  .pr$Expr$arr_median(self)
}

#' Find the standard deviation in an array
#'
#' @inheritParams DataFrame_std
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   values = list(c(2, 1, 4), c(8.4, 3.2, 1)),
#'   schema = list(values = pl$Array(pl$Float64, 3))
#' )
#' df$with_columns(std = pl$col("values")$arr$std())
ExprArr_std = function(ddof = 1) {
  .pr$Expr$arr_std(self, ddof)
}

#' Find the variance in an array
#'
#' @inheritParams DataFrame_var
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   values = list(c(2, 1, 4), c(8.4, 3.2, 1)),
#'   schema = list(values = pl$Array(pl$Float64, 3))
#' )
#' df$with_columns(var = pl$col("values")$arr$var())
ExprArr_var = function(ddof = 1) {
  .pr$Expr$arr_var(self, ddof)
}

#' Sort values in an array
#'
#' @inheritParams Expr_sort
#' @examples
#' df = pl$DataFrame(
#'   values = list(c(2, 1), c(3, 4), c(NA_real_, 6)),
#'   schema = list(values = pl$Array(pl$Float64, 2))
#' )
#' df$with_columns(sort = pl$col("values")$arr$sort(nulls_last = TRUE))
ExprArr_sort = function(descending = FALSE, nulls_last = FALSE) .pr$Expr$arr_sort(self, descending, nulls_last)

#' Reverse values in an array
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   values = list(c(1, 2), c(3, 4), c(NA_real_, 6)),
#'   schema = list(values = pl$Array(pl$Float64, 2))
#' )
#' df$with_columns(reverse = pl$col("values")$arr$reverse())
ExprArr_reverse = function() .pr$Expr$arr_reverse(self)

#' Get unique values in an array
#'
#' @inheritParams Expr_unique
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   values = list(c(1, 1, 2), c(4, 4, 4), c(NA_real_, 6, 7)),
#'   schema = list(values = pl$Array(pl$Float64, 3))
#' )
#' df$with_columns(unique = pl$col("values")$arr$unique())
ExprArr_unique = function(maintain_order = FALSE) .pr$Expr$arr_unique(self, maintain_order)


#' Get the value by index in an array
#'
#' This allows to extract one value per array only.
#'
#' @inherit ExprList_get params return
#' @param index An Expr or something coercible to an Expr, that must return a
#'   single index. Values are 0-indexed (so index 0 would return the first item
#'   of every sub-array) and negative values start from the end (index `-1`
#'   returns the last item).
#' @examples
#' df = pl$DataFrame(
#'   values = list(c(1, 2), c(3, 4), c(NA_real_, 6)),
#'   idx = c(1, NA, 3),
#'   schema = list(values = pl$Array(pl$Float64, 2))
#' )
#' df$with_columns(
#'   using_expr = pl$col("values")$arr$get("idx"),
#'   val_0 = pl$col("values")$arr$get(0),
#'   val_minus_1 = pl$col("values")$arr$get(-1),
#'   val_oob = pl$col("values")$arr$get(10)
#' )
ExprArr_get = function(index, ..., null_on_oob = TRUE) {
  .pr$Expr$arr_get(self, index, null_on_oob) |>
    unwrap("in $arr$get():")
}

#' Check if array contains a given value
#'
#' @param item Expr or something coercible to an Expr. Strings are *not* parsed
#' as columns.
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   values = list(0:2, 4:6, c(NA_integer_, NA_integer_, NA_integer_)),
#'   item = c(0L, 4L, 2L),
#'   schema = list(values = pl$Array(pl$Float64, 3))
#' )
#' df$with_columns(
#'   with_expr = pl$col("values")$arr$contains(pl$col("item")),
#'   with_lit = pl$col("values")$arr$contains(1)
#' )
ExprArr_contains = function(item) .pr$Expr$arr_contains(self, item)

#' Join elements of an array
#'
#' Join all string items in a sub-array and place a separator between them. This
#' only works on columns of type `list[str]`.
#'
#' @param separator String to separate the items with. Can be an Expr. Strings
#'   are *not* parsed as columns.
#' @inheritParams pl_concat_str
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   values = list(c("a", "b", "c"), c("x", "y", "z"), c("e", NA, NA)),
#'   separator = c("-", "+", "/"),
#'   schema = list(values = pl$Array(pl$String, 3))
#' )
#' df$with_columns(
#'   join_with_expr = pl$col("values")$arr$join(pl$col("separator")),
#'   join_with_lit = pl$col("values")$arr$join(" "),
#'   join_ignore_null = pl$col("values")$arr$join(" ", ignore_nulls = TRUE)
#' )
ExprArr_join = function(separator, ignore_nulls = FALSE) {
  .pr$Expr$arr_join(self, separator, ignore_nulls) |>
    unwrap("in $arr$join():")
}

#' Get the index of the minimal value in an array
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   values = list(1:2, 2:1),
#'   schema = list(values = pl$Array(pl$Int32, 2))
#' )
#' df$with_columns(
#'   arg_min = pl$col("values")$arr$arg_min()
#' )
ExprArr_arg_min = function() .pr$Expr$arr_arg_min(self)

#' Get the index of the maximal value in an array
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   values = list(1:2, 2:1),
#'   schema = list(values = pl$Array(pl$Int32, 2))
#' )
#' df$with_columns(
#'   arg_max = pl$col("values")$arr$arg_max()
#' )
ExprArr_arg_max = function() .pr$Expr$arr_arg_max(self)

#' Evaluate whether all boolean values in an array are true
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   values = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), c(NA, NA)),
#'   schema = list(values = pl$Array(pl$Boolean, 2))
#' )
#' df$with_columns(all = pl$col("values")$arr$all())
ExprArr_all = function() .pr$Expr$arr_all(self)

#' Evaluate whether any boolean values in an array are true
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   values = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), c(NA, NA)),
#'   schema = list(values = pl$Array(pl$Boolean, 2))
#' )
#' df$with_columns(any = pl$col("values")$arr$any())
ExprArr_any = function() .pr$Expr$arr_any(self)

#' Shift array values by `n` indices
#'
#' @inheritParams DataFrame_shift
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   values = list(1:3, c(2L, NA_integer_, 5L)),
#'   idx = 1:2,
#'   schema = list(values = pl$Array(pl$Int32, 3))
#' )
#' df$with_columns(
#'   shift_by_expr = pl$col("values")$arr$shift(pl$col("idx")),
#'   shift_by_lit = pl$col("values")$arr$shift(2)
#' )
ExprArr_shift = function(n = 1) {
  .pr$Expr$arr_shift(self, n) |>
    unwrap("in $arr$shift():")
}


#' Convert an Array column into a List column with the same inner data type
#'
#' @return [Expr][Expr_class] of [data type List][DataType_List]
#' @examples
#' df = pl$DataFrame(
#'   a = list(c(1, 2), c(3, 4)),
#'   schema = list(a = pl$Array(pl$Int8, 2))
#' )
#'
#' df$with_columns(
#'   list = pl$col("a")$arr$to_list()
#' )
ExprArr_to_list = function() .pr$Expr$arr_to_list(self)


#' Convert array to struct
#'
#' @inheritParams ExprList_to_struct
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   values = list(1:3, c(2L, NA_integer_, 5L)),
#'   schema = list(values = pl$Array(pl$Int32, 3))
#' )
#' df$with_columns(
#'   struct = pl$col("values")$arr$to_struct()
#' )
#'
#' # pass a custom function that will name all fields by adding a prefix
#' df2 = df$with_columns(
#'   pl$col("values")$arr$to_struct(
#'     fields = \(idx) paste0("col_", idx)
#'   )
#' )
#' df2
#'
#' df2$unnest()
ExprArr_to_struct = function(fields = NULL) {
  .pr$Expr$arr_to_struct(self, fields) |>
    unwrap("in $arr$to_struct():")
}
