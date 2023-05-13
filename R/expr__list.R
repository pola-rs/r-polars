# this file sources list-expression functions to be bundled in the 'expr$arr' sub namespace
# the sub name space is instanciated from Expr_arr- function
# bundling these functions into an environment, depends on a macro call in zzz.R
# expr_arr_make_sub_ns = macro_new_subnamespace("^ExprArr_", "ExprArrNameSpace")


## TODO revisit array, list terminology and pick one way, e.g list of sublists or list of elements

#' Lengths arrays in list
#' @rdname arr_lengths
#' @name arr_lengths
#' @description
#' Get the length of the arrays as UInt32
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases lengths arr.lengths arr_lengths
#' @examples
#' df = pl$DataFrame(list_of_strs = pl$Series(list(c("a", "b"), "c")))
#' df$with_column(pl$col("list_of_strs")$arr$lengths()$alias("list_of_strs_lengths"))
ExprArr_lengths = function() .pr$Expr$arr_lengths(self)

#' Sum lists
#' @name arr_sum
#' @description
#' Sum all the lists in the array.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_sum arr.sum
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L, 2:3)))
#' df$select(pl$col("values")$arr$sum())
ExprArr_sum = function() .pr$Expr$lst_sum(self)

#' Max lists
#' @name arr_max
#' @description
#' Compute the max value of the lists in the array.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases Expr_arr_max Expr_arr.max
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L, 2:3)))
#' df$select(pl$col("values")$arr$max())
ExprArr_max = function() .pr$Expr$lst_max(self)

#'  #' Min lists
#' @name arr_min
#' @description
#' Compute the min value of the lists in the array.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases Expr_arr_min Expr_arr.min
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L, 2:3)))
#' df$select(pl$col("values")$arr$min())
ExprArr_min = function() .pr$Expr$lst_min(self)

#' Mean of lists
#' @name arr_mean
#' @description
#' Compute the mean value of the lists in the array.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_mean arr.mean
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L, 2:3)))
#' df$select(pl$col("values")$arr$mean())
ExprArr_mean = function() .pr$Expr$lst_mean(self)

#' Get list
#' @name arr_sort
#' @description Get the value by index in the sublists.
#' @param index numeric vector or Expr of length 1 or same length of Series.
#' if length 1 pick same value from each sublist, if length as Series/column,
#' pick by individual index across sublists.
#'
#' So index `0` would return the first item of every sublist
#' and index `-1` would return the last item of every sublist
#' if an index is out of bounds, it will return a `None`.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases Expr_arr_sort Expr_arr.sort
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$arr$get(0))
#' df$select(pl$col("a")$arr$get(c(2, 0, -1)))
ExprArr_sort = function(reverse = FALSE) .pr$Expr$lst_sort(self, reverse)

#' Reverse list
#' @name arr_reverse
#' @description
#' Reverse the arrays in the list.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_reverse arr.reverse
#' @examples
#' df = pl$DataFrame(list(
#'   values = list(3:1, c(9L, 1:2))
#' ))
#' df$select(pl$col("values")$arr$reverse())
ExprArr_reverse = function() .pr$Expr$lst_reverse(self)

#' Unique list
#' @name arr_unique
#' @description
#' Get the unique/distinct values in the list.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_unique arr.unique
#' @examples
#' df = pl$DataFrame(list(a = list(1, 1, 2)))
#' df$select(pl$col("a")$arr$unique())
ExprArr_unique = function() .pr$Expr$lst_unique(self)


#' concat another list
#' @description Concat the arrays in a Series dtype List in linear time.
#' @param other Rlist, Expr or column of same tyoe as self.
#' @name arr_concat
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_concat arr.concat
#' @examples
#' df = pl$DataFrame(
#'   a = list("a", "x"),
#'   b = list(c("b", "c"), c("y", "z"))
#' )
#' df$select(pl$col("a")$arr$concat(pl$col("b")))
#'
#' df$select(pl$col("a")$arr$concat("hello from R"))
#'
#' df$select(pl$col("a")$arr$concat(list("hello", c("hello", "world"))))
ExprArr_concat = function(other) {
  pl$concat_list(list(self, other))
}

#' Get list
#' @name arr_get
#' @description Get the value by index in the sublists.
#' @param index numeric vector or Expr of length 1 or same length of Series.
#' if length 1 pick same value from each sublist, if length as Series/column,
#' pick by individual index across sublists.
#'
#' So index `0` would return the first item of every sublist
#' and index `-1` would return the last item of every sublist
#' if an index is out of bounds, it will return a `None`.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases Expr_arr_get Expr_arr.get
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$arr$get(0))
#' df$select(pl$col("a")$arr$get(c(2, 0, -1)))
ExprArr_get = function(index) .pr$Expr$lst_get(self, wrap_e(index, str_to_lit = FALSE))

#' Get list
#' @rdname arr_get
#' @export
#' @param x ExprArrNameSpace
#' @param index value to get
#' @details
#' `[.ExprArrNameSpace` used as e.g. `pl$col("a")$arr[0]` same as `pl$col("a")$get(0)`
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$arr[0])
#' df$select(pl$col("a")$arr[c(2, 0, -1)])
`[.ExprArrNameSpace` = function(x, index) { # S3 sub class-name set in zzz.R
  x$get(index)
}


#' take in sublists
#' @name arr_take
#' @description Get the take value of the sublists.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_take arr.take
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' idx = pl$Series(list(0:1, 1L, 1L))
#' df$select(pl$col("a")$arr$take(99))
ExprArr_take = function(index, null_on_oob = FALSE) {
  expr = wrap_e(index, str_to_lit = FALSE)
  .pr$Expr$lst_take(self, expr, null_on_oob)
}

#' First in sublists
#' @name arr_first
#' @description Get the first value of the sublists.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_first arr.first
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$arr$first())
ExprArr_first = function(index) .pr$Expr$lst_get(self, wrap_e(0L, str_to_lit = FALSE))

#' Last in sublists
#' @name arr_last
#' @description Get the last value of the sublists.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_last arr.last
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$arr$last())
ExprArr_last = function(index) .pr$Expr$lst_get(self, wrap_e(-1L, str_to_lit = FALSE))

#' Sublists contains
#' @name arr_contains
#' @description Check if sublists contain the given item.
#' @param item any into Expr/literal
#' @keywords ExprArr
#' @format function
#' @return Expr of a boolean mask
#' @aliases arr_contains arr.contains
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$arr$contains(1L))
ExprArr_contains = function(other) .pr$Expr$arr_contains(self, wrap_e(other))


#' Join sublists
#' @name arr_join
#' @description
#' Join all string items in a sublist and place a separator between them.
#' This errors if inner type of list `!= Utf8`.
#' @param separator string to separate the items with
#' @keywords ExprArr
#' @format function
#' @return Series of dtype Utf8
#' @aliases arr_join arr.join
#' @examples
#' df = pl$DataFrame(list(s = list(c("a", "b", "c"), c("x", "y"))))
#' df$select(pl$col("s")$arr$join(" "))
ExprArr_join = function(separator) .pr$Expr$lst_join(self, separator)

#' Arg min sublists
#' @name arr_arg_min
#' @description Retrieve the index of the minimal value in every sublist.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_arg_min arr.arg_min
#' @examples
#' df = pl$DataFrame(list(s = list(1:2, 2:1)))
#' df$select(pl$col("s")$arr$arg_min())
ExprArr_arg_min = function() .pr$Expr$lst_arg_min(self)

#' Arg max sublists
#' @name arr_arg_max
#' @description Retrieve the index of the maximum value in every sublist.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases Expr_arr_arg_max Expr_arr.arg_max
#' @examples
#' df = pl$DataFrame(list(s = list(1:2, 2:1)))
#' df$select(pl$col("s")$arr$arg_max())
ExprArr_arg_max = function() .pr$Expr$lst_arg_max(self)


## TODO contribute polars support negative n values for Diff sublist

#' Diff sublists
#' @name arr_diff
#' @description Calculate the n-th discrete difference of every sublist.
#' @param n Number of slots to shift
#' @param null_behavior choice "ignore"(default) "drop"
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases Expr_arr_diff Expr_arr.diff
#' @examples
#' df = pl$DataFrame(list(s = list(1:4, c(10L, 2L, 1L))))
#' df$select(pl$col("s")$arr$diff())
ExprArr_diff = function(n = 1, null_behavior = "ignore") {
  unwrap(.pr$Expr$lst_diff(self, n, null_behavior))
}

#' Shift sublists
#' @name arr_shift
#' @description Shift values by the given period.
#' @param periods Value. Number of places to shift (may be negative).
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_shift arr.shift
#' @examples
#' df = pl$DataFrame(list(s = list(1:4, c(10L, 2L, 1L))))
#' df$select(pl$col("s")$arr$shift())
ExprArr_shift = function(periods = 1) unwrap(.pr$Expr$lst_shift(self, periods))

#' Slice sublists
#' @name arr_slice
#' @description Slice every sublist.
#' @param offset value or Expr.  Start index. Negative indexing is supported.
#' @param length value or Expr.
#' Length of the slice. If set to ``None`` (default), the slice is taken to the
#' end of the list.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_slice arr.slice
#' @examples
#' df = pl$DataFrame(list(s = list(1:4, c(10L, 2L, 1L))))
#' df$select(pl$col("s")$arr$slice(2))
ExprArr_slice = function(offset, length = NULL) {
  offset = wrap_e(offset, str_to_lit = FALSE)
  if (!is.null(length)) {
    length = wrap_e(length, str_to_lit = FALSE)
  }
  .pr$Expr$lst_slice(self, offset, length)
}


# TODO contribute polars let head and tail support negative indicies also regular head tail

#' Heads of sublists
#' @name arr_head
#' @description head the first `n` values of every sublist.
#' @param n Numeric or Expr, number of values to return for each sublist.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_head arr.head
#' @examples
#' df = pl$DataFrame(list(a = list(1:4, c(10L, 2L, 1L))))
#' df$select(pl$col("a")$arr$head(2))
ExprArr_head = function(n = 5L) {
  self$arr$slice(0L, n)
}

#' Tails of sublists
#' @name arr_tail
#' @description tail the first `n` values of every sublist.
#' @param n Numeric or Expr, number of values to return for each sublist.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_tail arr.tail
#' @examples
#' df = pl$DataFrame(list(a = list(1:4, c(10L, 2L, 1L))))
#' df$select(pl$col("a")$arr$tail(2))
ExprArr_tail = function(n = 5L) {
  offset = -wrap_e(n, str_to_lit = FALSE)
  self$arr$slice(offset, n)
}



# TODO update rust-polars, this function has likely changed behavior as upper_bound is
# no longer needed

#' List to Struct
#' @param n_field_strategy Strategy to determine the number of fields of the struct.
#'  default = 'first_non_null' else 'max_width'
#' @param name_generator an R function that takes a scalar column number
#' and outputs a string value. The default NULL is equivalent to the R function
#' `\(idx) paste0("field_",idx)`
#' @param upper_bound upper_bound numeric
#' A polars `LazyFrame` needs to know the schema at all time.
#' The caller therefore must provide an `upper_bound` of
#' struct fields that will be set.
#' If this is incorrectly downstream operation may fail.
#' For instance an `all().sum()` expression will look in
#' the current schema to determine which columns to select.
#' It is adviced to set this value in a lazy query.
#'
#' @name arr_to_struct
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_to_struct arr.to_struct
#' @examples
#' df = pl$DataFrame(list(a = list(1:3, 1:2)))
#' df2 = df$select(pl$col("a")$arr$to_struct(
#'   name_generator = \(idx) paste0("hello_you_", idx)
#' ))
#' df2$unnest()
#'
#' df2$to_list()
ExprArr_to_struct = function(
    n_field_strategy = "first_non_null", name_generator = NULL, upper_bound = 0) {
  # extendr_concurrent now only supports series communication, wrap out of series
  # wrapped into series on rust side
  if (!is.null(name_generator)) {
    if (!is.function(name_generator)) {
      stopf("name_generator must be an R function")
    }
    name_generator_wrapped = \(s) {
      .pr$Series$rename_mut(s, name_generator(s$to_r())[1])
      s
    }
  } else {
    name_generator_wrapped = NULL
  }

  unwrap(.pr$Expr$lst_to_struct(
    self, n_field_strategy, name_generator_wrapped, upper_bound
  ))
}

#' eval sublists (kinda like lapply)
#' @name arr_eval
#' @description Run any polars expression against the lists' elements.
#' @param Expr Expression to run. Note that you can select an element with `pl$first()`, or
#' `pl$col()`
#' @param parallel bool
#' Run all expression parallel. Don't activate this blindly.
#'             Parallelism is worth it if there is enough work to do per thread.
#'             This likely should not be use in the groupby context, because we already
#'             parallel execution per group
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_eval arr.eval
#' @examples
#' df = pl$DataFrame(a = list(c(1, 8, 3), b = c(4, 5, 2)))
#' df$select(pl$all()$cast(pl$dtypes$Int64))$with_column(
#'   pl$concat_list(c("a", "b"))$arr$eval(pl$element()$rank())$alias("rank")
#' )
ExprArr_eval = function(expr, parallel = FALSE) {
  .pr$Expr$lst_eval(self, expr, parallel)
}
