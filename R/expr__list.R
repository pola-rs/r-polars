#' Get the length of each list
#'
#' Return the number of elements in each list. Null values are counted in the
#' total. `$list$lengths()` is deprecated.
#'
#' @return Expr
#' @aliases list_len
#' @examples
#' df = pl$DataFrame(list(list_of_strs = list(c("a", "b", NA), "c")))
#' df$with_columns(len_list = pl$col("list_of_strs")$list$len())
ExprList_len = function() .pr$Expr$list_len(self)

#' Sum all elements in a list
#'
#' @return Expr
#' @aliases list_sum
#' @examples
#' df = pl$DataFrame(list(values = list(c(1, 2, 3, NA), c(2, 3), NA_real_)))
#' df$with_columns(sum = pl$col("values")$list$sum())
ExprList_sum = function() .pr$Expr$list_sum(self)

#' Find the maximum value in a list
#'
#' @return Expr
#' @aliases list_max
#' @examples
#' df = pl$DataFrame(list(values = list(c(1, 2, 3, NA), c(2, 3), NA_real_)))
#' df$with_columns(max = pl$col("values")$list$max())
ExprList_max = function() .pr$Expr$list_max(self)

#' Find the minimum value in a list
#'
#' @return Expr
#' @aliases list_min
#' @examples
#' df = pl$DataFrame(list(values = list(c(1, 2, 3, NA), c(2, 3), NA_real_)))
#' df$with_columns(min = pl$col("values")$list$min())
ExprList_min = function() .pr$Expr$list_min(self)

#' Compute the mean value of a list
#'
#' @return Expr
#' @aliases list_mean
#' @examples
#' df = pl$DataFrame(list(values = list(c(1, 2, 3, NA), c(2, 3), NA_real_)))
#' df$with_columns(mean = pl$col("values")$list$mean())
ExprList_mean = function() .pr$Expr$list_mean(self)

#' Sort values in a list
#'
#' @param descending Sort values in descending order
#' @return Expr
#' @aliases list_sort
#' @examples
#' df = pl$DataFrame(list(values = list(c(1, 2, 3, NA), c(2, 3), NA_real_)))
#' df$with_columns(sort = pl$col("values")$list$sort())
ExprList_sort = function(descending = FALSE) .pr$Expr$list_sort(self, descending)

#' Reverse values in a list
#'
#' @return Expr
#' @aliases list_reverse
#' @examples
#' df = pl$DataFrame(list(values = list(c(1, 2, 3, NA), c(2, 3), NA_real_)))
#' df$with_columns(reverse = pl$col("values")$list$reverse())
ExprList_reverse = function() .pr$Expr$list_reverse(self)

#' Get unique values in a list
#'
#' @description
#' Get the unique/distinct values in the list.
#'
#' @return Expr
#' @aliases list_unique
#' @examples
#' df = pl$DataFrame(list(values = list(c(2, 2, NA), c(1, 2, 3), NA_real_)))
#' df$with_columns(unique = pl$col("values")$list$unique())
ExprList_unique = function() .pr$Expr$list_unique(self)

#' Concat two list variables
#'
#' @param other Values to concat with. Can be an Expr or something coercible to
#' an Expr.
#'
#' @return Expr
#' @aliases list_concat
#' @examples
#' df = pl$DataFrame(
#'   a = list("a", "x"),
#'   b = list(c("b", "c"), c("y", "z"))
#' )
#' df$with_columns(
#'   conc_to_b = pl$col("a")$list$concat(pl$col("b")),
#'   conc_to_lit_str = pl$col("a")$list$concat(pl$lit("some string")),
#'   conc_to_lit_list = pl$col("a")$list$concat(pl$lit(list("hello", c("hello", "world"))))
#' )
ExprList_concat = function(other) {
  pl$concat_list(list(self, other))
}

#' Get the value by index in a list
#'
#' This allows to extract one value per list only. To extract several values by
#' index, use [`$list$gather()`][ExprList_gather].
#'
#' @param index An Expr or something coercible to an Expr, that must return a
#'   single index. Values are 0-indexed (so index 0 would return the first item
#'   of every sublist) and negative values start from the end (index `-1`
#'   returns the last item). If the index is out of bounds, it will return a
#'   `null`. Strings are parsed as column names.
#'
#' @return Expr
#' @aliases list_get
#' @examples
#' df = pl$DataFrame(
#'   values = list(c(2, 2, NA), c(1, 2, 3), NA_real_, NULL),
#'   idx = c(1, 2, NA, 3)
#' )
#' df$with_columns(
#'   using_expr = pl$col("values")$list$get("idx"),
#'   val_0 = pl$col("values")$list$get(0),
#'   val_minus_1 = pl$col("values")$list$get(-1),
#'   val_oob = pl$col("values")$list$get(10)
#' )
ExprList_get = function(index) .pr$Expr$list_get(self, wrap_e(index, str_to_lit = FALSE))

#' Get several values by index in a list
#'
#' This allows to extract several values per list. To extract a single value by
#' index, use [`$list$get()`][ExprList_get].
#'
#' @param index An Expr or something coercible to an Expr, that can return
#'   several single indices. Values are 0-indexed (so index 0 would return the
#'   first item of every sublist) and negative values start from the end (index
#'   `-1` returns the last item). If the index is out of bounds, it will return
#'   a `null`. Strings are parsed as column names.
#' @param null_on_oob Return a `null` value if index is out of bounds.
#'
#' @return Expr
#' @aliases list_gather
#' @examples
#' df = pl$DataFrame(list(a = list(c(3, 2, 1), 1, c(1, 2)))) #
#' idx = pl$Series(list(0:1, integer(), c(1L, 999L)))
#' df$select(pl$col("a")$list$gather(pl$lit(idx), null_on_oob = TRUE))
#'
#' # with implicit conversion to Expr
#' df$select(pl$col("a")$list$gather(list(0:1, integer(), c(1L, 999L)), null_on_oob = TRUE))
#'
#' # by some column name, must cast to an Int/Uint type to work
#' df$select(pl$col("a")$list$gather(pl$col("a")$cast(pl$List(pl$UInt64)), null_on_oob = TRUE))
ExprList_gather = function(index, null_on_oob = FALSE) {
  expr = wrap_e(index, str_to_lit = FALSE)
  .pr$Expr$list_gather(self, expr, null_on_oob) |>
    unwrap("in $gather()")
}

#' Get the first value in a list
#'
#' @return Expr
#' @aliases list_first
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2)))
#' df$with_columns(
#'   first = pl$col("a")$list$first()
#' )
ExprList_first = function() .pr$Expr$list_get(self, wrap_e(0L, str_to_lit = FALSE))

#' Get the last value in a list
#'
#' @return Expr
#' @aliases list_last
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2)))
#' df$with_columns(
#'   last = pl$col("a")$list$last()
#' )
ExprList_last = function() .pr$Expr$list_get(self, wrap_e(-1L, str_to_lit = FALSE))

#' Check if list contains a given value
#'
#' @param item Expr or something coercible to an Expr. Strings are *not* parsed
#' as columns.
#'
#' @return Expr
#' @aliases list_contains
#' @examples
#' df = pl$DataFrame(
#'   a = list(3:1, NULL, 1:2),
#'   item = 0:2
#' )
#' df$with_columns(
#'   with_expr = pl$col("a")$list$contains(pl$col("item")),
#'   with_lit = pl$col("a")$list$contains(1)
#' )
ExprList_contains = function(item) .pr$Expr$list_contains(self, wrap_e(item))

#' Join elements of a list
#'
#' Join all string items in a sublist and place a separator between them. This
#' only works on columns of type `list[str]`.
#'
#' @param separator String to separate the items with. Can be an Expr. Strings
#'   are *not* parsed as columns.
#' @inheritParams pl_concat_str
#'
#' @return Expr
#' @aliases list_join
#' @examples
#' df = pl$DataFrame(
#'   s = list(c("a", "b", "c"), c("x", "y"), c("e", NA)),
#'   separator = c("-", "+", "/")
#' )
#' df$with_columns(
#'   join_with_expr = pl$col("s")$list$join(pl$col("separator")),
#'   join_with_lit = pl$col("s")$list$join(" "),
#'   join_ignore_null = pl$col("s")$list$join(" ", ignore_nulls = TRUE)
#' )
ExprList_join = function(separator, ignore_nulls = FALSE) {
  .pr$Expr$list_join(self, separator, ignore_nulls) |>
    unwrap("in $list$join():")
}

#' Get the index of the minimal value in list
#'
#' @return Expr
#' @aliases list_arg_min
#' @examples
#' df = pl$DataFrame(list(s = list(1:2, 2:1)))
#' df$with_columns(
#'   arg_min = pl$col("s")$list$arg_min()
#' )
ExprList_arg_min = function() .pr$Expr$list_arg_min(self)

#' Get the index of the maximal value in list
#'
#' @return Expr
#' @aliases list_arg_max
#' @examples
#' df = pl$DataFrame(list(s = list(1:2, 2:1)))
#' df$with_columns(
#'   arg_max = pl$col("s")$list$arg_max()
#' )
ExprList_arg_max = function() .pr$Expr$list_arg_max(self)


## TODO contribute polars support negative n values for Diff sublist

#' Compute difference between list values
#'
#' This computes the first discrete difference between shifted items of every
#' list. The parameter `n` gives the interval between items to subtract, e.g `n
#' = 2` the output will be the difference between the 1st and the 3rd value, the
#' 2nd and 4th value, etc.
#'
#' @param n Number of slots to shift.
#' @param null_behavior How to handle `null` values. Either `"ignore"` (default)
#'   or `"drop"`.
#'
#' @return Expr
#' @aliases list_diff
#' @examples
#' df = pl$DataFrame(list(s = list(1:4, c(10L, 2L, 1L))))
#' df$with_columns(diff = pl$col("s")$list$diff(2))
ExprList_diff = function(n = 1, null_behavior = c("ignore", "drop")) {
  .pr$Expr$list_diff(self, n, null_behavior) |>
    unwrap("in $list$diff()")
}

#' Shift list values by `n` indices
#'
#' @param periods Number of places to shift (may be negative). Can be an Expr.
#' Strings are *not* parsed as columns.
#'
#' @return Expr
#' @aliases list_shift
#' @examples
#' df = pl$DataFrame(
#'   s = list(1:4, c(10L, 2L, 1L)),
#'   idx = 1:2
#' )
#' df$with_columns(
#'   shift_by_expr = pl$col("s")$list$shift(pl$col("idx")),
#'   shift_by_lit = pl$col("s")$list$shift(2)
#' )
ExprList_shift = function(periods = 1) unwrap(.pr$Expr$list_shift(self, periods))

#' Slice list
#'
#' This extracts `length` values at most, starting at index `offset`. This can
#' return less than `length` values if `length` is larger than the number of
#' values.
#'
#' @param offset Start index. Negative indexing is supported. Can be an Expr.
#'   Strings are parsed as column names.
#' @param length Length of the slice. If `NULL` (default), the slice is taken to
#'   the end of the list. Can be an Expr. Strings are parsed as column names.
#'
#' @return Expr
#' @aliases list_slice
#' @examples
#' df = pl$DataFrame(
#'   s = list(1:4, c(10L, 2L, 1L)),
#'   idx_off = 1:2,
#'   len = c(4, 1)
#' )
#' df$with_columns(
#'   slice_by_expr = pl$col("s")$list$slice("idx_off", "len"),
#'   slice_by_lit = pl$col("s")$list$slice(2, 3)
#' )
ExprList_slice = function(offset, length = NULL) {
  offset = wrap_e(offset, str_to_lit = FALSE)
  if (!is.null(length)) {
    length = wrap_e(length, str_to_lit = FALSE)
  }
  .pr$Expr$list_slice(self, offset, length)
}


# TODO contribute polars let head and tail support negative indicies also regular head tail

#' Get the first `n` values of a list
#'
#' @param n Number of values to return for each sublist. Can be an Expr. Strings
#'   are parsed as column names.
#'
#' @return Expr
#' @aliases list_head
#' @examples
#' df = pl$DataFrame(
#'   s = list(1:4, c(10L, 2L, 1L)),
#'   n = 1:2
#' )
#' df$with_columns(
#'   head_by_expr = pl$col("s")$list$head("n"),
#'   head_by_lit = pl$col("s")$list$head(2)
#' )
ExprList_head = function(n = 5L) {
  self$list$slice(0L, n)
}

#' Get the last `n` values of a list
#'
#' @param n Number of values to return for each sublist. Can be an Expr. Strings
#'   are parsed as column names.
#'
#' @return Expr
#' @aliases list_tail
#' @examples
#' df = pl$DataFrame(
#'   s = list(1:4, c(10L, 2L, 1L)),
#'   n = 1:2
#' )
#' df$with_columns(
#'   tail_by_expr = pl$col("s")$list$tail("n"),
#'   tail_by_lit = pl$col("s")$list$tail(2)
#' )
ExprList_tail = function(n = 5L) {
  offset = -wrap_e(n, str_to_lit = FALSE)
  self$list$slice(offset, n)
}

#' Convert a Series of type `List` to `Struct`
#'
#' @param n_field_strategy Strategy to determine the number of fields of the
#'   struct. If `"first_non_null"` (default), set number of fields equal to the
#'   length of the first non zero-length list. If `"max_width"`, the number of
#'   fields is the maximum length of a list.
#'
#' @param fields If the name and number of the desired fields is known in
#'   advance, a list of field names can be given, which will be assigned by
#'   index. Otherwise, to dynamically assign field names, a custom R function
#'   that takes an R scalar double and outputs a string value can be used. If
#'   `NULL` (default), fields will be `field_0`, `field_1` ... `field_n`.

#' @param upper_bound A `LazyFrame` needs to know the schema at all time. The
#'   caller therefore must provide an `upper_bound` of struct fields that will
#'   be set. If set incorrectly, downstream operation may fail. For instance an
#'   `all()$sum()` expression will look in the current schema to determine which
#'   columns to select. When operating on a `DataFrame`, the schema does not
#'   need to be tracked or pre-determined, as the result will be eagerly
#'   evaluated, so you can leave this parameter unset.
#'
#' @return Expr
#' @aliases list_to_struct
#' @examples
#' df = pl$DataFrame(list(a = list(1:2, 1:3)))
#'
#' # this discards the third value of the second list as the struct length is
#' # determined based on the length of the first non-empty list
#' df$with_columns(
#'   struct = pl$col("a")$list$to_struct()
#' )
#'
#' # we can use "max_width" to keep all values
#' df$with_columns(
#'   struct = pl$col("a")$list$to_struct(n_field_strategy = "max_width")
#' )
#'
#' # pass a custom function that will name all fields by adding a prefix
#' df2 = df$with_columns(
#'   pl$col("a")$list$to_struct(
#'     fields = \(idx) paste0("col_", idx)
#'   )
#' )
#' df2
#'
#' df2$unnest()
#'
#' df2$to_list()
ExprList_to_struct = function(
    n_field_strategy = c("first_non_null", "max_width"),
    fields = NULL,
    upper_bound = 0) {
  .pr$Expr$list_to_struct(self, n_field_strategy, fields, upper_bound) |>
    unwrap("in <List>$to_struct():")
}

#' Run any polars expression on the list values
#'
#' @param expr Expression to run. Note that you can select an element with
#'   `pl$element()`, `pl$first()`, and more. See Examples.
#' @param parallel Run all expression parallel. Don't activate this blindly.
#'   Parallelism is worth it if there is enough work to do per thread. This
#'   likely should not be used in the `$group_by()` context, because we already
#'   do parallel execution per group.
#'
#' @return Expr
#' @aliases list_eval
#' @examples
#' df = pl$DataFrame(
#'   a = list(c(1, 8, 3), c(3, 2), c(NA, NA, 1)),
#'   b = list(c("R", "is", "amazing"), c("foo", "bar"), "text")
#' )
#' df$with_columns(
#'   # standardize each value inside a list, using only the values in this list
#'   a_stand = pl$col("a")$list$eval(
#'     (pl$element() - pl$element()$mean()) / pl$element()$std()
#'   ),
#'
#'   # count characters for each element in list. Since column "b" is list[str],
#'   # we can apply all `$str` functions on elements in the list:
#'   b_len_chars = pl$col("b")$list$eval(
#'     pl$element()$str$len_chars()
#'   )
#' )
ExprList_eval = function(expr, parallel = FALSE) {
  .pr$Expr$list_eval(self, expr, parallel)
}

#' Evaluate whether all boolean values in a list are true
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   list(a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), NA, c()))
#' )
#' df$with_columns(all = pl$col("a")$list$all())
ExprList_all = function() .pr$Expr$list_all(self)

#' Evaluate whether any boolean values in a list are true
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   list(a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), NA, c()))
#' )
#' df$with_columns(any = pl$col("a")$list$any())
ExprList_any = function() .pr$Expr$list_any(self)

#' Get the union of two list variables
#'
#' @param other Other list variable. Can be an Expr or something coercible to an
#' Expr.
#'
#' @details
#' Note that the datatypes inside the list must have a common supertype. For
#' example, the first column can be `list[i32]` and the second one can be
#' `list[i8]` because it can be cast to `list[i32]`. However, the second column
#' cannot be e.g `list[f32]`.
#'
#' @return Expr
#' @examples
#' df = pl$DataFrame(
#'   a = list(1:3, NA_integer_, c(NA_integer_, 3L), 5:7),
#'   b = list(2:4, 3L, c(3L, 4L, NA_integer_), c(6L, 8L))
#' )
#'
#' df$with_columns(union = pl$col("a")$list$set_union("b"))
ExprList_set_union = function(other) {
  .pr$Expr$list_set_operation(self, other, "union") |>
    unwrap("in $list$set_union():")
}

#' Get the intersection of two list variables
#'
#' @inherit ExprList_set_union params details return
#'
#' @examples
#' df = pl$DataFrame(
#'   a = list(1:3, NA_integer_, c(NA_integer_, 3L), 5:7),
#'   b = list(2:4, 3L, c(3L, 4L, NA_integer_), c(6L, 8L))
#' )
#'
#' df$with_columns(intersection = pl$col("a")$list$set_intersection("b"))
ExprList_set_intersection = function(other) {
  .pr$Expr$list_set_operation(self, other, "intersection") |>
    unwrap("in $list$set_intersection():")
}

#' Get the difference of two list variables
#'
#' This returns the "asymmetric difference", meaning only the elements of the
#' first list that are not in the second list. To get all elements that are in
#' only one of the two lists, use
#' [`$set_symmetric_difference()`][ExprList_set_symmetric_difference].
#'
#' @inherit ExprList_set_union params details return
#'
#' @examples
#' df = pl$DataFrame(
#'   a = list(1:3, NA_integer_, c(NA_integer_, 3L), 5:7),
#'   b = list(2:4, 3L, c(3L, 4L, NA_integer_), c(6L, 8L))
#' )
#'
#' df$with_columns(difference = pl$col("a")$list$set_difference("b"))
ExprList_set_difference = function(other) {
  .pr$Expr$list_set_operation(self, other, "difference") |>
    unwrap("in $list$set_difference():")
}

#' Get the symmetric difference of two list variables
#'
#' This returns all elements that are in only one of the two lists. To get only
#' elements that are in the first list but not in the second one, use
#' [`$set_difference()`][ExprList_set_difference].
#'
#' @inherit ExprList_set_union params details return
#'
#' @examples
#' df = pl$DataFrame(
#'   a = list(1:3, NA_integer_, c(NA_integer_, 3L), 5:7),
#'   b = list(2:4, 3L, c(3L, 4L, NA_integer_), c(6L, 8L))
#' )
#'
#' df$with_columns(
#'   symmetric_difference = pl$col("a")$list$set_symmetric_difference("b")
#' )
ExprList_set_symmetric_difference = function(other) {
  .pr$Expr$list_set_operation(self, other, "symmetric_difference") |>
    unwrap("in $list$set_symmetric_difference():")
}
