# this file sources list-expression functions to be bundled in the 'expr$list' sub namespace
# the sub name space is instantiated from Expr_arr- function
# bundling these functions into an environment, depends on a macro call in zzz.R
# expr_list_make_sub_ns = macro_new_subnamespace("^ExprList_", "RPolarsExprListNameSpace")


## TODO revisit array, list terminology and pick one way, e.g list of sublists or list of elements

#' Lengths arrays in list
#' @rdname ExprList_lengths
#'
#' @description
#' Get the length of the arrays as UInt32
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases lengths list_lengths
#' @examples
#' df = pl$DataFrame(list_of_strs = pl$Series(list(c("a", "b"), "c")))
#' df$with_columns(pl$col("list_of_strs")$list$lengths()$alias("list_of_strs_lengths"))
ExprList_lengths = function() .pr$Expr$list_lengths(self)

#' Sum lists
#'
#' @description
#' Sum all the lists in the array.
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases list_sum
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L, 2:3)))
#' df$select(pl$col("values")$list$sum())
ExprList_sum = function() .pr$Expr$list_sum(self)

#' Max lists
#'
#' @description
#' Compute the max value of the lists in the array.
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases Expr_list_max
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L, 2:3)))
#' df$select(pl$col("values")$list$max())
ExprList_max = function() .pr$Expr$list_max(self)

#'  #' Min lists
#'
#' @description
#' Compute the min value of the lists in the array.
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases Expr_list_min
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L, 2:3)))
#' df$select(pl$col("values")$list$min())
ExprList_min = function() .pr$Expr$list_min(self)

#' Mean of lists
#'
#' @description
#' Compute the mean value of the lists in the array.
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases list_mean
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L, 2:3)))
#' df$select(pl$col("values")$list$mean())
ExprList_mean = function() .pr$Expr$list_mean(self)

#' @inherit Expr_sort title description return
#' @param descending Sort values in descending order
#'
ExprList_sort = function(descending = FALSE) .pr$Expr$list_sort(self, descending)

#' Reverse list
#'
#' @description
#' Reverse the arrays in the list.
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases list_reverse
#' @examples
#' df = pl$DataFrame(list(
#'   values = list(3:1, c(9L, 1:2))
#' ))
#' df$select(pl$col("values")$list$reverse())
ExprList_reverse = function() .pr$Expr$list_reverse(self)

#' Unique list
#'
#' @description
#' Get the unique/distinct values in the list.
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases list_unique
#' @examples
#' df = pl$DataFrame(list(a = list(1, 1, 2)))
#' df$select(pl$col("a")$list$unique())
ExprList_unique = function() .pr$Expr$list_unique(self)


#' concat another list
#' @description Concat the arrays in a Series dtype List in linear time.
#' @param other Rlist, Expr or column of same type as self.
#'
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases list_concat
#' @examples
#' df = pl$DataFrame(
#'   a = list("a", "x"),
#'   b = list(c("b", "c"), c("y", "z"))
#' )
#' df$select(pl$col("a")$list$concat(pl$col("b")))
#'
#' df$select(pl$col("a")$list$concat(pl$lit("hello from R")))
#'
#' df$select(pl$col("a")$list$concat(pl$lit(list("hello", c("hello", "world")))))
ExprList_concat = function(other) {
  pl$concat_list(list(self, other))
}

#' Get list
#'
#' @description Get the value by index in the sublists.
#' @param index numeric vector or Expr of length 1 or same length of Series.
#' if length 1 pick same value from each sublist, if length as Series/column,
#' pick by individual index across sublists.
#'
#' So index `0` would return the first item of every sublist
#' and index `-1` would return the last item of every sublist
#' if an index is out of bounds, it will return a `None`.
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases Expr_list_get
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$list$get(0))
#' df$select(pl$col("a")$list$get(c(2, 0, -1)))
ExprList_get = function(index) .pr$Expr$list_get(self, wrap_e(index, str_to_lit = FALSE))

#' Get list
#' @rdname ExprList_get
#' @export
#' @param x RPolarsExprListNameSpace
#' @param index value to get
#' @details
#' `[.RPolarsExprListNameSpace` used as e.g. `pl$col("a")$arr[0]` same as `pl$col("a")$get(0)`
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$list[0])
#' df$select(pl$col("a")$list[c(2, 0, -1)])
`[.RPolarsExprListNameSpace` = function(x, index) { # S3 sub class-name set in zzz.R
  x$get(index)
}


#' take in sublists
#'
#' @description Get the take value of the sublists.
#' @keywords ExprList
#' @param index R list of integers for each sub-element or Expr or Series of type `List[usize]`
#' @param null_on_oob boolean
#' @format function
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

#' First in sublists
#'
#' @description Get the first value of the sublists.
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases list_first
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$list$first())
ExprList_first = function() .pr$Expr$list_get(self, wrap_e(0L, str_to_lit = FALSE))

#' Last in sublists
#'
#' @description Get the last value of the sublists.
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases list_last
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$list$last())
ExprList_last = function() .pr$Expr$list_get(self, wrap_e(-1L, str_to_lit = FALSE))

#' Sublists contains
#'
#' @description Check if sublists contain the given item.
#' @param item any into Expr/literal
#' @keywords ExprList
#' @format function
#' @return Expr of a boolean mask
#' @aliases list_contains
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$list$contains(1L))
ExprList_contains = function(item) .pr$Expr$list_contains(self, wrap_e(item))


#' Join sublists
#'
#' @description
#' Join all string items in a sublist and place a separator between them.
#' This errors if inner type of list `!= String`.
#' @param separator String to separate the items with. Can be an Expr.
#' @keywords ExprList
#' @format function
#' @return Series of dtype String
#' @aliases list_join
#' @examples
#' df = pl$DataFrame(list(s = list(c("a", "b", "c"), c("x", "y"))))
#' df$select(pl$col("s")$list$join(" "))
ExprList_join = function(separator) {
  .pr$Expr$list_join(self, separator) |>
    unwrap("in $list$join():")
}

#' Arg min sublists
#'
#' @description Retrieve the index of the minimal value in every sublist.
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases list_arg_min
#' @examples
#' df = pl$DataFrame(list(s = list(1:2, 2:1)))
#' df$select(pl$col("s")$list$arg_min())
ExprList_arg_min = function() .pr$Expr$list_arg_min(self)

#' Arg max sublists
#'
#' @description Retrieve the index of the maximum value in every sublist.
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases Expr_list_arg_max
#' @examples
#' df = pl$DataFrame(list(s = list(1:2, 2:1)))
#' df$select(pl$col("s")$list$arg_max())
ExprList_arg_max = function() .pr$Expr$list_arg_max(self)


## TODO contribute polars support negative n values for Diff sublist

#' Diff sublists
#'
#' @description Calculate the n-th discrete difference of every sublist.
#' @param n Number of slots to shift
#' @param null_behavior choice "ignore"(default) "drop"
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases Expr_list_diff
#' @examples
#' df = pl$DataFrame(list(s = list(1:4, c(10L, 2L, 1L))))
#' df$select(pl$col("s")$list$diff(1))
ExprList_diff = function(n = 1, null_behavior = c("ignore", "drop")) {
  .pr$Expr$list_diff(self, n, null_behavior) |>
    unwrap("in $list$diff()")
}

#' Shift sublists
#'
#' @description Shift values by the given period.
#' @param periods Value. Number of places to shift (may be negative).
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases list_shift
#' @examples
#' df = pl$DataFrame(list(s = list(1:4, c(10L, 2L, 1L))))
#' df$select(pl$col("s")$list$shift())
ExprList_shift = function(periods = 1) unwrap(.pr$Expr$list_shift(self, periods))

#' Slice sublists
#'
#' @description Slice every sublist.
#' @param offset value or Expr.  Start index. Negative indexing is supported.
#' @param length value or Expr.
#' Length of the slice. If set to ``None`` (default), the slice is taken to the
#' end of the list.
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases list_slice
#' @examples
#' df = pl$DataFrame(list(s = list(1:4, c(10L, 2L, 1L))))
#' df$select(pl$col("s")$list$slice(2))
ExprList_slice = function(offset, length = NULL) {
  offset = wrap_e(offset, str_to_lit = FALSE)
  if (!is.null(length)) {
    length = wrap_e(length, str_to_lit = FALSE)
  }
  .pr$Expr$list_slice(self, offset, length)
}


# TODO contribute polars let head and tail support negative indicies also regular head tail

#' Heads of sublists
#'
#' @description head the first `n` values of every sublist.
#' @param n Numeric or Expr, number of values to return for each sublist.
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases list_head
#' @examples
#' df = pl$DataFrame(list(a = list(1:4, c(10L, 2L, 1L))))
#' df$select(pl$col("a")$list$head(2))
ExprList_head = function(n = 5L) {
  self$list$slice(0L, n)
}

#' Tails of sublists
#'
#' @description tail the first `n` values of every sublist.
#' @param n Numeric or Expr, number of values to return for each sublist.
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases list_tail
#' @examples
#' df = pl$DataFrame(list(a = list(1:4, c(10L, 2L, 1L))))
#' df$select(pl$col("a")$list$tail(2))
ExprList_tail = function(n = 5L) {
  offset = -wrap_e(n, str_to_lit = FALSE)
  self$list$slice(offset, n)
}



# TODO update rust-polars, this function has likely changed behavior as upper_bound is
# no longer needed

#' List to Struct
#' @param n_field_strategy Strategy to determine the number of fields of the struct.
#'  default = "first_non_null": set number of fields equal to the length of the
#'  first non zero-length sublist. else 'max_width'; else  "max_width":
#'  set number of fields as max length of all sublists.
#' @param name_generator an R function that takes an R scalar double and outputs
#' a string value. It is a f64 because i32 might not be a big enough enumerate all.
#' The default (`NULL`) is equivalent to the R function
#' `\(idx) paste0("field_", idx)`
#' @param upper_bound upper_bound A polars `LazyFrame` needs to know the schema
#' at all time. The caller therefore must provide an `upper_bound` of struct
#' fields that will be set. If set incorrectly, downstream operation may fail.
#' For instance an `all()$sum()` expression will look in the current schema to
#' determine which columns to select. It is advised to set this value in a lazy
#' query.
#'
#'
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases list_to_struct
#' @examples
#' df = pl$DataFrame(list(a = list(1:3, 1:2)))
#' df2 = df$select(pl$col("a")$list$to_struct(
#'   name_generator = \(idx) paste0("hello_you_", idx)
#' ))
#' df2$unnest()
#'
#' df2$to_list()
ExprList_to_struct = function(
    n_field_strategy = c("first_non_null", "max_width"),
    name_generator = NULL,
    upper_bound = 0) {
  .pr$Expr$list_to_struct(self, n_field_strategy, name_generator, upper_bound) |>
    unwrap("in <List>$to_struct():")
}

#' eval sublists (kinda like lapply)
#'
#' @description Run any polars expression against the lists' elements.
#' @param expr Expression to run. Note that you can select an element with
#' `pl$first()`, or `pl$col()`
#' @param parallel Run all expression parallel. Don't activate this blindly.
#' Parallelism is worth it if there is enough work to do per thread. This likely
#' should not be use in the groupby context, because we already do parallel
#' execution per group.
#' @keywords ExprList
#' @format function
#' @return Expr
#' @aliases list_eval
#' @examples
#' df = pl$DataFrame(a = c(1, 8, 3), b = c(4, 5, 2))
#' df$select(pl$all()$cast(pl$dtypes$Int64))$with_columns(
#'   pl$concat_list(c("a", "b"))$list$eval(pl$element()$rank())$alias("rank")
#' )
ExprList_eval = function(expr, parallel = FALSE) {
  .pr$Expr$list_eval(self, expr, parallel)
}
