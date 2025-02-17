# The env for storing all expr list methods
polars_expr_list_methods <- new.env(parent = emptyenv())

namespace_expr_list <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x$`_rexpr`

  lapply(names(polars_expr_list_methods), function(name) {
    fn <- polars_expr_list_methods[[name]]
    environment(fn) <- environment()
    assign(name, fn, envir = self)
  })

  class(self) <- c("polars_namespace_expr", "polars_object")
  self
}

#' Return the number of elements in each sub-list
#'
#' Null values are counted in the total.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(list_of_strs = list(c("a", "b", NA), "c"))
#' df$with_columns(len_list = pl$col("list_of_strs")$list$len())
expr_list_len <- function() {
  self$`_rexpr`$list_len() |>
    wrap()
}

#' Sum all elements in every sub-list
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(values = list(c(1, 2, 3, NA), c(2, 3), NA))
#' df$with_columns(sum = pl$col("values")$list$sum())
expr_list_sum <- function() {
  self$`_rexpr`$list_sum() |>
    wrap()
}

#' Compute the maximum value in every sub-list
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(values = list(c(1, 2, 3, NA), c(2, 3), NA))
#' df$with_columns(max = pl$col("values")$list$max())
expr_list_max <- function() {
  self$`_rexpr`$list_max() |>
    wrap()
}

#' Compute the miminum value in every sub-list
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(values = list(c(1, 2, 3, NA), c(2, 3), NA))
#' df$with_columns(min = pl$col("values")$list$min())
expr_list_min <- function() {
  self$`_rexpr`$list_min() |>
    wrap()
}

#' Compute the mean value in every sub-list
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(values = list(c(1, 2, 3, NA), c(2, 3), NA))
#' df$with_columns(mean = pl$col("values")$list$mean())
expr_list_mean <- function() {
  self$`_rexpr`$list_mean() |>
    wrap()
}

#' Sort values in every sub-list
#'
#' @param descending Sort values in descending order.
#' @param nulls_last Place null values last.
#' @inheritParams rlang::args_dots_empty
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(values = list(c(NA, 2, 1, 3), c(Inf, 2, 3, NaN), NA))
#' df$with_columns(sort = pl$col("values")$list$sort())
expr_list_sort <- function(..., descending = FALSE, nulls_last = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$list_sort(descending, nulls_last)
  })
}

#' Reverse values in every sub-list
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(values = list(c(1, 2, 3, NA), c(2, 3), NA))
#' df$with_columns(reverse = pl$col("values")$list$reverse())
expr_list_reverse <- function() {
  self$`_rexpr`$list_reverse() |>
    wrap()
}

#' Get unique values in a list
#'
#' @param maintain_order Maintain order of data. This requires more work.
#' @inheritParams rlang::args_dots_empty
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(values = list(c(2, 2, NA), c(1, 2, 3), NA))
#' df$with_columns(unique = pl$col("values")$list$unique())
expr_list_unique <- function(..., maintain_order = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$list_unique(maintain_order)
  })
}

#' Count the number of unique values in every sub-lists
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(values = list(c(2, 2, NA), c(1, 2, 3), NA))
#' df$with_columns(unique = pl$col("values")$list$n_unique())
expr_list_n_unique <- function() {
  self$`_rexpr`$list_n_unique() |>
    wrap()
}

#' Concat the lists into a new list
#'
#' @param other Values to concat with. Can be an Expr or something coercible to
#' an Expr.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = list("a", "x"),
#'   b = list(c("b", "c"), c("y", "z"))
#' )
#' df$with_columns(
#'   conc_to_b = pl$col("a")$list$concat(pl$col("b")),
#'   conc_to_lit_str = pl$col("a")$list$concat(pl$lit("some string")),
#'   conc_to_lit_list = pl$col("a")$list$concat(pl$lit(list("hello", c("hello", "world"))))
#' )
expr_list_concat <- function(other) {
  pl$concat_list(wrap(self$`_rexpr`), other) |>
    wrap()
}

#' Get the value by index in every sub-list
#'
#' This allows to extract one value per list only. To extract several values by
#' index, use [`$list$gather()`][expr_list_gather].
#'
#' @param index An Expr or something coercible to an Expr, that must return a
#'   single index. Values are 0-indexed (so index 0 would return the first item
#'   of every sub-list) and negative values start from the end (index `-1`
#'   returns the last item).
#' @inheritParams rlang::args_dots_empty
#' @param null_on_oob If `TRUE`, return `null` if an index is out of bounds.
#' Otherwise, raise an error.
#' @return [Expr][expr_class]
#' @examples
#' df <- pl$DataFrame(
#'   values = list(c(2, 2, NA), c(1, 2, 3), NA, NULL),
#'   idx = c(1, 2, NA, 3)
#' )
#' df$with_columns(
#'   using_expr = pl$col("values")$list$get("idx"),
#'   val_0 = pl$col("values")$list$get(0),
#'   val_minus_1 = pl$col("values")$list$get(-1),
#'   val_oob = pl$col("values")$list$get(10)
#' )
expr_list_get <- function(index, ..., null_on_oob = TRUE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$list_get(as_polars_expr(index)$`_rexpr`, null_on_oob)
  })
}

#' Get several values by index in every sub-list
#'
#' This allows to extract several values per list. To extract a single value by
#' index, use [`$list$get()`][expr_list_get]. The indices may be defined in a
#' single column, or by sub-lists in another column of dtype List.
#'
#' @param index An Expr or something coercible to an Expr, that can return
#'   several indices. Values are 0-indexed (so index 0 would return the
#'   first item of every sub-list) and negative values start from the end (index
#'   `-1` returns the last item). If the index is out of bounds, it will return
#'   a `null`. Strings are parsed as column names.
#' @inheritParams expr_list_get
#' @inheritParams rlang::args_dots_empty
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = list(c(3, 2, 1), 1, c(1, 2)),
#'   idx = list(0:1, integer(), c(1L, 999L))
#' )
#' df$with_columns(
#'   gathered = pl$col("a")$list$gather("idx", null_on_oob = TRUE)
#' )
#'
#' df$with_columns(
#'   gathered = pl$col("a")$list$gather(2, null_on_oob = TRUE)
#' )
#'
#' # by some column name, must cast to an Int/Uint type to work
#' df$with_columns(
#'   gathered = pl$col("a")$list$gather(pl$col("a")$cast(pl$List(pl$UInt64)), null_on_oob = TRUE)
#' )
expr_list_gather <- function(index, ..., null_on_oob = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$list_gather(as_polars_expr(index)$`_rexpr`, null_on_oob)
  })
}

#' Take every `n`-th value starting from offset in sub-lists
#'
#' @inheritParams expr__gather_every
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = list(1:5, 6:8, 9:12),
#'   n = c(2, 1, 3),
#'   offset = c(0, 1, 0)
#' )
#'
#' df$with_columns(
#'   gather_every = pl$col("a")$list$gather_every(pl$col("n"), offset = pl$col("offset"))
#' )
expr_list_gather_every <- function(n, offset = 0) {
  self$`_rexpr`$list_gather_every(as_polars_expr(n)$`_rexpr`, as_polars_expr(offset)$`_rexpr`) |>
    wrap()
}

#' Get the first value of the sub-lists
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(a = list(3:1, NULL, 1:2))
#' df$with_columns(
#'   first = pl$col("a")$list$first()
#' )
expr_list_first <- function() {
  self$get(0, null_on_oob = TRUE) |>
    wrap()
}

#' Get the last value of the sub-lists
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(a = list(3:1, NULL, 1:2))
#' df$with_columns(
#'   last = pl$col("a")$list$last()
#' )
expr_list_last <- function() {
  self$get(-1, null_on_oob = TRUE) |>
    wrap()
}

#' Check if sub-lists contains a given value
#'
#' @param item Item that will be checked for membership. Can be an Expr or
#' something coercible to an Expr. Strings are not parsed as columns.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = list(3:1, NULL, 1:2),
#'   item = 0:2
#' )
#' df$with_columns(
#'   with_expr = pl$col("a")$list$contains(pl$col("item")),
#'   with_lit = pl$col("a")$list$contains(1)
#' )
expr_list_contains <- function(item) {
  self$`_rexpr`$list_contains(as_polars_expr(item, as_lit = TRUE)$`_rexpr`) |>
    wrap()
}

#' Join elements of every sub-list
#'
#' Join all string items in a sub-list and place a separator between them. This
#' only works if the inner dtype is `String`.
#'
#' @param separator String to separate the items with. Can be an Expr. Strings
#'   are *not* parsed as columns.
#' @inheritParams pl__concat_str
#' @inheritParams rlang::args_dots_empty
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   s = list(c("a", "b", "c"), c("x", "y"), c("e", NA)),
#'   separator = c("-", "+", "/")
#' )
#' df$with_columns(
#'   join_with_expr = pl$col("s")$list$join(pl$col("separator")),
#'   join_with_lit = pl$col("s")$list$join(" "),
#'   join_ignore_null = pl$col("s")$list$join(" ", ignore_nulls = TRUE)
#' )
expr_list_join <- function(separator, ..., ignore_nulls = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$list_join(as_polars_expr(separator, as_lit = TRUE)$`_rexpr`, ignore_nulls)
  })
}

#' Retrieve the index of the minimum value in every sub-list
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(s = list(1:2, 2:1))
#' df$with_columns(
#'   arg_min = pl$col("s")$list$arg_min()
#' )
expr_list_arg_min <- function() {
  self$`_rexpr`$list_arg_min() |>
    wrap()
}

#' Retrieve the index of the maximum value in every sub-list
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(s = list(1:2, 2:1))
#' df$with_columns(
#'   arg_max = pl$col("s")$list$arg_max()
#' )
expr_list_arg_max <- function() {
  self$`_rexpr`$list_arg_max() |>
    wrap()
}


#' Compute difference between sub-list values
#'
#' This computes the first discrete difference between shifted items of every
#' list. The parameter `n` gives the interval between items to subtract, e.g.
#' if `n = 2` the output will be the difference between the 1st and the 3rd
#' value, the 2nd and 4th value, etc.
#'
#' @param n Number of slots to shift. If negative, then it starts from the end.
#' @param null_behavior How to handle `null` values. Either `"ignore"` (default)
#'   or `"drop"`.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(s = list(1:4, c(10L, 2L, 1L)))
#' df$with_columns(diff = pl$col("s")$list$diff(2))
#'
#' # negative value starts shifting from the end
#' df$with_columns(diff = pl$col("s")$list$diff(-2))
expr_list_diff <- function(n = 1, null_behavior = c("ignore", "drop")) {
  wrap({
    null_behavior <- arg_match0(null_behavior, values = c("ignore", "drop"))
    self$`_rexpr`$list_diff(n, null_behavior)
  })
}

#' Shift list values by the given number of indices
#'
#' @inheritParams dataframe__shift
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   s = list(1:4, c(10L, 2L, 1L)),
#'   idx = 1:2
#' )
#' df$with_columns(
#'   shift_by_expr = pl$col("s")$list$shift(pl$col("idx")),
#'   shift_by_lit = pl$col("s")$list$shift(2),
#'   shift_by_negative_lit = pl$col("s")$list$shift(-2)
#' )
expr_list_shift <- function(n = 1) {
  self$`_rexpr`$list_shift(as_polars_expr(n)$`_rexpr`) |>
    wrap()
}

#' Slice every sub-list
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
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   s = list(1:4, c(10L, 2L, 1L)),
#'   idx_off = 1:2,
#'   len = c(4, 1)
#' )
#' df$with_columns(
#'   slice_by_expr = pl$col("s")$list$slice("idx_off", "len"),
#'   slice_by_lit = pl$col("s")$list$slice(2, 3)
#' )
expr_list_slice <- function(offset, length = NULL) {
  wrap({
    offset <- as_polars_expr(offset, as_lit = FALSE)$`_rexpr`
    if (!is.null(length)) {
      length <- as_polars_expr(length, as_lit = FALSE)$`_rexpr`
    }
    self$`_rexpr`$list_slice(offset, length)
  })
}

#' Slice the first `n` values of every sub-list
#'
#' @param n Number of values to return for each sub-list. Can be an Expr.
#' Strings are parsed as column names.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   s = list(1:4, c(10L, 2L, 1L)),
#'   n = 1:2
#' )
#' df$with_columns(
#'   head_by_expr = pl$col("s")$list$head("n"),
#'   head_by_lit = pl$col("s")$list$head(2)
#' )
expr_list_head <- function(n = 5L) {
  self$`_rexpr`$list_slice(as_polars_expr(0)$`_rexpr`, as_polars_expr(n)$`_rexpr`) |>
    wrap()
}

#' Slice the last `n` values of every sub-list
#'
#' @param n Number of values to return for each sub-list. Can be an Expr. Strings
#'   are parsed as column names.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   s = list(1:4, c(10L, 2L, 1L)),
#'   n = 1:2
#' )
#' df$with_columns(
#'   tail_by_expr = pl$col("s")$list$tail("n"),
#'   tail_by_lit = pl$col("s")$list$tail(2)
#' )
expr_list_tail <- function(n = 5L) {
  wrap({
    offset <- -as_polars_expr(n)
    self$`_rexpr`$list_slice(offset$`_rexpr`, as_polars_expr(n)$`_rexpr`)
  })
}

# TODO-REWRITE: implement this
# #' Convert a Series of type `List` to `Struct`
# #'
# #' @param n_field_strategy Strategy to determine the number of fields of the
# #'   struct. If `"first_non_null"` (default), set number of fields equal to the
# #'   length of the first non zero-length list. If `"max_width"`, the number of
# #'   fields is the maximum length of a list.
# #'
# #' @param fields If the name and number of the desired fields is known in
# #'   advance, a list of field names can be given, which will be assigned by
# #'   index. Otherwise, to dynamically assign field names, a custom R function
# #'   that takes an R double and outputs a string value can be used. If
# #'   `NULL` (default), fields will be `field_0`, `field_1` ... `field_n`.

# #' @param upper_bound A `LazyFrame` needs to know the schema at all time. The
# #'   caller therefore must provide an `upper_bound` of struct fields that will
# #'   be set. If set incorrectly, downstream operation may fail. For instance an
# #'   `all()$sum()` expression will look in the current schema to determine which
# #'   columns to select. When operating on a `DataFrame`, the schema does not
# #'   need to be tracked or pre-determined, as the result will be eagerly
# #'   evaluated, so you can leave this parameter unset.
# #'
# #' @inherit as_polars_expr return
# #'
# #' @examples
# #' df <- pl$DataFrame(a = list(1:2, 1:3))
# #'
# #' # this discards the third value of the second list as the struct length is
# #' # determined based on the length of the first non-empty list
# #' df$with_columns(
# #'   struct = pl$col("a")$list$to_struct()
# #' )
# #'
# #' # we can use "max_width" to keep all values
# #' df$with_columns(
# #'   struct = pl$col("a")$list$to_struct(n_field_strategy = "max_width")
# #' )
# #'
# #' # pass a custom function that will name all fields by adding a prefix
# #' df2 <- df$with_columns(
# #'   pl$col("a")$list$to_struct(
# #'     fields = \(idx) paste0("col_", idx)
# #'   )
# #' )
# #' df2
# #'
# #' df2$unnest()
# expr_list_to_struct <- function(
#     n_field_strategy = c("first_non_null", "max_width"),
#     fields = NULL,
#     upper_bound = 0) {
#   wrap({
#     n_field_strategy <- arg_match0(n_field_strategy, values = c("first_non_null", "max_width"))
#     self$`_rexpr`$list_to_struct(n_field_strategy, fields, upper_bound)
#   })
# }

#' Run any polars expression on the sub-lists' values
#'
#' @param expr Expression to run. Note that you can select an element with
#'   `pl$element()`, `pl$first()`, and more. See Examples.
#' @param parallel Run all expressions in parallel. Don't activate this blindly.
#'   Parallelism is worth it if there is enough work to do per thread. This
#'   likely should not be used in the `$group_by()` context, because groups are
#'   already executed in parallel.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = list(c(1, 8, 3), c(3, 2), c(NA, NA, 1)),
#'   b = list(c("R", "is", "amazing"), c("foo", "bar"), "text")
#' )
#'
#' df
#'
#' # standardize each value inside a list, using only the values in this list
#' df$select(
#'   a_stand = pl$col("a")$list$eval(
#'     (pl$element() - pl$element()$mean()) / pl$element()$std()
#'   )
#' )
#'
#' # count characters for each element in list. Since column "b" is list[str],
#' # we can apply all `$str` functions on elements in the list:
#' df$select(
#'   b_len_chars = pl$col("b")$list$eval(
#'     pl$element()$str$len_chars()
#'   )
#' )
#'
#' # concat strings in each list
#' df$select(
#'   pl$col("b")$list$eval(pl$element()$str$join(" "))$list$first()
#' )
expr_list_eval <- function(expr, ..., parallel = FALSE) {
  wrap({
    check_dots_empty0(...)
    self$`_rexpr`$list_eval(as_polars_expr(expr)$`_rexpr`, parallel)
  })
}

#' Evaluate whether all boolean values in a sub-list are true
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), NA, c())
#' )
#' df$with_columns(all = pl$col("a")$list$all())
expr_list_all <- function() {
  self$`_rexpr`$list_all() |>
    wrap()
}

#' Evaluate whether any boolean value in a sub-list is true
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), NA, c())
#' )
#' df$with_columns(any = pl$col("a")$list$any())
expr_list_any <- function() {
  self$`_rexpr`$list_any() |>
    wrap()
}

#' Compute the union of elements of a list and other elements
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
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = list(1:3, NA, c(NA, 3L), 5:7),
#'   b = list(2:4, 3L, c(3L, 4L, NA), c(6L, 8L))
#' )
#'
#' df$with_columns(union = pl$col("a")$list$set_union("b"))
expr_list_set_union <- function(other) {
  self$`_rexpr`$list_set_operation(as_polars_expr(other)$`_rexpr`, "union") |>
    wrap()
}

#' Compute the intersection between elements of a list and other elements
#'
#' @inherit expr_list_set_union params details return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = list(1:3, NA, c(NA, 3L), 5:7),
#'   b = list(2:4, 3L, c(3L, 4L, NA), c(6L, 8L))
#' )
#'
#' df$with_columns(intersection = pl$col("a")$list$set_intersection("b"))
expr_list_set_intersection <- function(other) {
  self$`_rexpr`$list_set_operation(as_polars_expr(other)$`_rexpr`, "intersection") |>
    wrap()
}

#' Compute the set difference between elements of a list and other elements
#'
#' This returns the "asymmetric difference", meaning only the elements of the
#' first list that are not in the second list. To get all elements that are in
#' only one of the two lists, use
#' [`$set_symmetric_difference()`][expr_list_set_symmetric_difference].
#'
#' @inherit expr_list_set_union params details return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = list(1:3, NA, c(NA, 3L), 5:7),
#'   b = list(2:4, 3L, c(3L, 4L, NA), c(6L, 8L))
#' )
#'
#' df$with_columns(difference = pl$col("a")$list$set_difference("b"))
expr_list_set_difference <- function(other) {
  self$`_rexpr`$list_set_operation(as_polars_expr(other)$`_rexpr`, "difference") |>
    wrap()
}

#' Compute the set symmetric difference between elements of a list and other elements
#'
#' This returns all elements that are in only one of the two lists. To get only
#' elements that are in the first list but not in the second one, use
#' [`$set_difference()`][expr_list_set_difference].
#'
#' @inherit expr_list_set_union params details return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = list(1:3, NA, c(NA, 3L), 5:7),
#'   b = list(2:4, 3L, c(3L, 4L, NA), c(6L, 8L))
#' )
#'
#' df$with_columns(
#'   symmetric_difference = pl$col("a")$list$set_symmetric_difference("b")
#' )
expr_list_set_symmetric_difference <- function(other) {
  self$`_rexpr`$list_set_operation(as_polars_expr(other)$`_rexpr`, "symmetric_difference") |>
    wrap()
}

#' Returns a column with a separate row for every list element
#'
#' @inherit expr_list_set_union return
#'
#' @examples
#' df <- pl$DataFrame(a = list(c(1, 2, 3), c(4, 5, 6)))
#' df$select(pl$col("a")$list$explode())
expr_list_explode <- function() {
  self$`_rexpr`$explode() |>
    wrap()
}

#' Sample values from every sub-list
#'
#' @inheritParams expr__sample
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   values = list(1:3, NA, c(NA, 3L), 5:7),
#'   n = c(1, 1, 1, 2)
#' )
#'
#' df$with_columns(
#'   sample = pl$col("values")$list$sample(n = pl$col("n"), seed = 1)
#' )
expr_list_sample <- function(
    n = NULL, ..., fraction = NULL, with_replacement = FALSE, shuffle = FALSE,
    seed = NULL) {
  wrap({
    check_dots_empty0(...)
    if (!is.null(n) && !is.null(fraction)) {
      abort("Provide either `n` or `fraction`, not both.")
    } else if (!is.null(n)) {
      self$`_rexpr`$list_sample_n(as_polars_expr(n)$`_rexpr`, with_replacement, shuffle, seed)
    } else {
      self$`_rexpr`$list_sample_frac(as_polars_expr(fraction %||% 1)$`_rexpr`, with_replacement, shuffle, seed)
    }
  })
}

#' Compute the standard deviation in every sub-list
#'
#' @param "Delta Degrees of Freedom": the divisor used in the calculation is
#' `N - ddof`, where `N` represents the number of elements. By default ddof is
#' 1.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(values = list(c(-1, 0, 1), c(1, 10)))
#'
#' df$with_columns(
#'   std = pl$col("values")$list$std()
#' )
expr_list_std <- function(ddof = 1) {
  self$`_rexpr`$list_std(ddof) |>
    wrap()
}

#' Compute the variance in every sub-list
#'
#' @inheritParams expr_list_std
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(values = list(c(-1, 0, 1), c(1, 10)))
#'
#' df$with_columns(
#'   var = pl$col("values")$list$var()
#' )
expr_list_var <- function(ddof = 1) {
  self$`_rexpr`$list_var(ddof) |>
    wrap()
}

#' Compute the median in every sub-list
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(values = list(c(-1, 0, 1), c(1, 10)))
#'
#' df$with_columns(
#'   median = pl$col("values")$list$median()
#' )
expr_list_median <- function() {
  self$`_rexpr`$list_median() |>
    wrap()
}

#' Convert a List column into an Array column with the same inner data type
#'
#' @param width Width of the resulting Array column.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(values = list(c(-1, 0), c(1, 10)))
#'
#' df$with_columns(
#'   array = pl$col("values")$list$to_array(2)
#' )
expr_list_to_array <- function(width) {
  self$`_rexpr`$list_to_array(width) |>
    wrap()
}

#' Drop all null values in every sub-list
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(values = list(c(NA, 0, NA), c(1, NaN), NA))
#'
#' df$with_columns(
#'   without_nulls = pl$col("values")$list$drop_nulls()
#' )
expr_list_drop_nulls <- function() {
  self$`_rexpr`$list_drop_nulls() |>
    wrap()
}

#' Count how often a value produced occurs
#'
#' @param element An expression that produces a single value.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = list(0, 1, c(1, 2, 3, 2), c(1, 2, 1), c(4, 4)))
#'
#' df$with_columns(
#'   number_of_twos = pl$col("a")$list$count_matches(2)
#' )
expr_list_count_matches <- function(element) {
  self$`_rexpr`$list_count_matches(as_polars_expr(element, as_lit = TRUE)$`_rexpr`) |>
    wrap()
}
