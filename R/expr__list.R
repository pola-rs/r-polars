# this file sources list-expression functions to be bundled in the 'expr$list' sub namespace
# the sub name space is instantiated from Expr_arr- function
# bundling these functions into an environment, depends on a macro call in zzz.R
# expr_list_make_sub_ns = macro_new_subnamespace("^ExprArr_", "ExprArrNameSpace")


## TODO revisit array, list terminology and pick one way, e.g list of sublists or list of elements

#' Lengths arrays in list
#' @rdname list_lengths
#' @name list_lengths
#' @description
#' Get the length of the arrays as UInt32
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases lengths arr.lengths list_lengths
#' @examples
#' df = pl$DataFrame(list_of_strs = pl$Series(list(c("a", "b"), "c")))
#' df$with_columns(pl$col("list_of_strs")$list$lengths()$alias("list_of_strs_lengths"))
ExprArr_lengths = function() .pr$Expr$list_lengths(self)

#' Sum lists
#' @name list_sum
#' @description
#' Sum all the lists in the array.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases list_sum arr.sum
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L, 2:3)))
#' df$select(pl$col("values")$list$sum())
ExprArr_sum = function() .pr$Expr$list_sum(self)

#' Max lists
#' @name list_max
#' @description
#' Compute the max value of the lists in the array.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases Expr_list_max Expr_arr.max
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L, 2:3)))
#' df$select(pl$col("values")$list$max())
ExprArr_max = function() .pr$Expr$list_max(self)

#'  #' Min lists
#' @name list_min
#' @description
#' Compute the min value of the lists in the array.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases Expr_list_min Expr_arr.min
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L, 2:3)))
#' df$select(pl$col("values")$list$min())
ExprArr_min = function() .pr$Expr$list_min(self)

#' Mean of lists
#' @name list_mean
#' @description
#' Compute the mean value of the lists in the array.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases list_mean arr.mean
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L, 2:3)))
#' df$select(pl$col("values")$list$mean())
ExprArr_mean = function() .pr$Expr$list_mean(self)

#' @inherit Expr_sort title description return
#' @param descending Sort values in descending order
#' @name list_sort
ExprArr_sort = function(descending = FALSE) .pr$Expr$list_sort(self, descending)

#' Reverse list
#' @name list_reverse
#' @description
#' Reverse the arrays in the list.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases list_reverse arr.reverse
#' @examples
#' df = pl$DataFrame(list(
#'   values = list(3:1, c(9L, 1:2))
#' ))
#' df$select(pl$col("values")$list$reverse())
ExprArr_reverse = function() .pr$Expr$list_reverse(self)

#' Unique list
#' @name list_unique
#' @description
#' Get the unique/distinct values in the list.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases list_unique arr.unique
#' @examples
#' df = pl$DataFrame(list(a = list(1, 1, 2)))
#' df$select(pl$col("a")$list$unique())
ExprArr_unique = function() .pr$Expr$list_unique(self)


#' concat another list
#' @description Concat the arrays in a Series dtype List in linear time.
#' @param other Rlist, Expr or column of same type as self.
#' @name list_concat
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases list_concat arr.concat
#' @examples
#' df = pl$DataFrame(
#'   a = list("a", "x"),
#'   b = list(c("b", "c"), c("y", "z"))
#' )
#' df$select(pl$col("a")$list$concat(pl$col("b")))
#'
#' df$select(pl$col("a")$list$concat("hello from R"))
#'
#' df$select(pl$col("a")$list$concat(list("hello", c("hello", "world"))))
ExprArr_concat = function(other) {
  pl$concat_list(list(self, other))
}

#' Get list
#' @name list_get
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
#' @aliases Expr_list_get Expr_arr.get
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$list$get(0))
#' df$select(pl$col("a")$list$get(c(2, 0, -1)))
ExprArr_get = function(index) .pr$Expr$list_get(self, wrap_e(index, str_to_lit = FALSE))

#' Get list
#' @rdname list_get
#' @export
#' @param x ExprArrNameSpace
#' @param index value to get
#' @details
#' `[.ExprArrNameSpace` used as e.g. `pl$col("a")$arr[0]` same as `pl$col("a")$get(0)`
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$list[0])
#' df$select(pl$col("a")$list[c(2, 0, -1)])
`[.ExprArrNameSpace` = function(x, index) { # S3 sub class-name set in zzz.R
  x$get(index)
}


#' take in sublists
#' @name list_take
#' @description Get the take value of the sublists.
#' @keywords ExprArr
#' @param index R list of integers for each sub-element or Expr or Series of type `List[usize]`
#' @param null_on_oob boolean
#' @format function
#' @return Expr
#' @aliases list_take arr.take
#' @examples
#' df = pl$DataFrame(list(a = list(c(3, 2, 1), 1, c(1, 2)))) #
#' idx = pl$Series(list(0:1, integer(), c(1L, 999L)))
#' df$select(pl$col("a")$list$take(pl$lit(idx), null_on_oob = TRUE))
#'
#' # with implicit conversion to Expr
#' df$select(pl$col("a")$list$take(list(0:1, integer(), c(1L, 999L)), null_on_oob = TRUE))
#'
#' # by some column name, must cast to an Int/Uint type to work
#' df$select(pl$col("a")$list$take(pl$col("a")$cast(pl$List(pl$UInt64)), null_on_oob = TRUE))
ExprArr_take = function(index, null_on_oob = FALSE) {
  expr = wrap_e(index, str_to_lit = FALSE)
  .pr$Expr$list_take(self, expr, null_on_oob) |>
    unwrap("in $take()")
}

#' First in sublists
#' @name list_first
#' @description Get the first value of the sublists.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases list_first arr.first
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$list$first())
ExprArr_first = function(index) .pr$Expr$list_get(self, wrap_e(0L, str_to_lit = FALSE))

#' Last in sublists
#' @name list_last
#' @description Get the last value of the sublists.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases list_last arr.last
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$list$last())
ExprArr_last = function(index) .pr$Expr$list_get(self, wrap_e(-1L, str_to_lit = FALSE))

#' Sublists contains
#' @name list_contains
#' @description Check if sublists contain the given item.
#' @param item any into Expr/literal
#' @keywords ExprArr
#' @format function
#' @return Expr of a boolean mask
#' @aliases list_contains arr.contains
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) # NULL or integer() or list()
#' df$select(pl$col("a")$list$contains(1L))
ExprArr_contains = function(other) .pr$Expr$list_contains(self, wrap_e(other))


#' Join sublists
#' @name list_join
#' @description
#' Join all string items in a sublist and place a separator between them.
#' This errors if inner type of list `!= Utf8`.
#' @param separator string to separate the items with
#' @keywords ExprArr
#' @format function
#' @return Series of dtype Utf8
#' @aliases list_join arr.join
#' @examples
#' df = pl$DataFrame(list(s = list(c("a", "b", "c"), c("x", "y"))))
#' df$select(pl$col("s")$list$join(" "))
ExprArr_join = function(separator) .pr$Expr$list_join(self, separator)

#' Arg min sublists
#' @name list_arg_min
#' @description Retrieve the index of the minimal value in every sublist.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases list_arg_min arr.arg_min
#' @examples
#' df = pl$DataFrame(list(s = list(1:2, 2:1)))
#' df$select(pl$col("s")$list$arg_min())
ExprArr_arg_min = function() .pr$Expr$list_arg_min(self)

#' Arg max sublists
#' @name list_arg_max
#' @description Retrieve the index of the maximum value in every sublist.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases Expr_list_arg_max Expr_arr.arg_max
#' @examples
#' df = pl$DataFrame(list(s = list(1:2, 2:1)))
#' df$select(pl$col("s")$list$arg_max())
ExprArr_arg_max = function() .pr$Expr$list_arg_max(self)


## TODO contribute polars support negative n values for Diff sublist

#' Diff sublists
#' @name list_diff
#' @description Calculate the n-th discrete difference of every sublist.
#' @param n Number of slots to shift
#' @param null_behavior choice "ignore"(default) "drop"
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases Expr_list_diff Expr_arr.diff
#' @examples
#' df = pl$DataFrame(list(s = list(1:4, c(10L, 2L, 1L))))
#' df$select(pl$col("s")$list$diff())
ExprArr_diff = function(n = 1, null_behavior = "ignore") {
  unwrap(.pr$Expr$list_diff(self, n, null_behavior))
}

#' Shift sublists
#' @name list_shift
#' @description Shift values by the given period.
#' @param periods Value. Number of places to shift (may be negative).
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases list_shift arr.shift
#' @examples
#' df = pl$DataFrame(list(s = list(1:4, c(10L, 2L, 1L))))
#' df$select(pl$col("s")$list$shift())
ExprArr_shift = function(periods = 1) unwrap(.pr$Expr$list_shift(self, periods))

#' Slice sublists
#' @name list_slice
#' @description Slice every sublist.
#' @param offset value or Expr.  Start index. Negative indexing is supported.
#' @param length value or Expr.
#' Length of the slice. If set to ``None`` (default), the slice is taken to the
#' end of the list.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases list_slice arr.slice
#' @examples
#' df = pl$DataFrame(list(s = list(1:4, c(10L, 2L, 1L))))
#' df$select(pl$col("s")$list$slice(2))
ExprArr_slice = function(offset, length = NULL) {
  offset = wrap_e(offset, str_to_lit = FALSE)
  if (!is.null(length)) {
    length = wrap_e(length, str_to_lit = FALSE)
  }
  .pr$Expr$list_slice(self, offset, length)
}


# TODO contribute polars let head and tail support negative indicies also regular head tail

#' Heads of sublists
#' @name list_head
#' @description head the first `n` values of every sublist.
#' @param n Numeric or Expr, number of values to return for each sublist.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases list_head arr.head
#' @examples
#' df = pl$DataFrame(list(a = list(1:4, c(10L, 2L, 1L))))
#' df$select(pl$col("a")$list$head(2))
ExprArr_head = function(n = 5L) {
  self$list$slice(0L, n)
}

#' Tails of sublists
#' @name list_tail
#' @description tail the first `n` values of every sublist.
#' @param n Numeric or Expr, number of values to return for each sublist.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases list_tail arr.tail
#' @examples
#' df = pl$DataFrame(list(a = list(1:4, c(10L, 2L, 1L))))
#' df$select(pl$col("a")$list$tail(2))
ExprArr_tail = function(n = 5L) {
  offset = -wrap_e(n, str_to_lit = FALSE)
  self$list$slice(offset, n)
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
#' It is advised to set this value in a lazy query.
#'
#' @name list_to_struct
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases list_to_struct arr.to_struct
#' @examples
#' df = pl$DataFrame(list(a = list(1:3, 1:2)))
#' df2 = df$select(pl$col("a")$list$to_struct(
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

  unwrap(.pr$Expr$list_to_struct(
    self, n_field_strategy, name_generator_wrapped, upper_bound
  ))
}

#' eval sublists (kinda like lapply)
#' @name list_eval
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
#' @aliases list_eval arr.eval
#' @examples
#' df = pl$DataFrame(a = list(c(1, 8, 3), b = c(4, 5, 2)))
#' df$select(pl$all()$cast(pl$dtypes$Int64))$with_columns(
#'   pl$concat_list(c("a", "b"))$list$eval(pl$element()$rank())$alias("rank")
#' )
ExprArr_eval = function(expr, parallel = FALSE) {
  .pr$Expr$list_eval(self, expr, parallel)
}
