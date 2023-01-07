
##TODO docs probably needs some overall when array-list terminology settles in py-polars

#' make_expr_arr_namespace
#' @description
#' Internal function to yield methods within arr namespace
#' See the individual method pages for full details
#' @keywords internals
#' @return environment with methods to call on self
make_expr_arr_namespace = function(self) {
  env = new.env()

  env$lengths  = function() .pr$Expr$arr_lengths(self)

  env$sum      = function() .pr$Expr$lst_sum(self)
  env$max      = function() .pr$Expr$lst_max(self)
  env$min      = function() .pr$Expr$lst_min(self)
  env$mean     = function() .pr$Expr$lst_mean(self)
  env$reverse  = function() .pr$Expr$lst_reverse(self)
  env$unique   = function() .pr$Expr$lst_unique(self)

  env$sort = function(reverse = FALSE) .pr$Expr$lst_sort(self, reverse)
  env$concat = function() stop("missing concat")
  env$get  = function(index) .pr$Expr$lst_get(self, wrap_e(index,str_to_lit = FALSE))

  env$first = function() env$get(0L)  #10
  env$last  = function() env$get(-1L) #11

  env$contains = function() stop("missing")
  env$join = function(separator) .pr$Expr$lst_join(self, separator)
  env$arg_min = function() .pr$Expr$lst_arg_min(self)
  env$arg_max = function() .pr$Expr$lst_arg_max(self)

  env$diff = function(n = 1, null_behavior = "ignore") {
    unwrap(.pr$Expr$lst_diff(self, n, null_behavior))
  }

  env$shift = function(periods = 1) unwrap(.pr$Expr$lst_shift(self, periods))

  env$slice = function(offset, length = NULL) .pr$Expr$lst_slice(self, offset, length)


  class(env) = c("ExprListNameSpace","environment")

  env
}





# roxygen does not like docs inside a function must place them out here

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
#' df = pl$DataFrame(list_of_strs = pl$Series(list(c("a","b"),"c")))
#' df$with_column(pl$col("list_of_strs")$arr$lengths()$alias("list_of_strs_lengths"))
1 #any Robject will trigger documenting

#' Sum lists
#' @name arr_sum
#' @description
#' Sum all the lists in the array.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_sum arr.sum
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L,2:3)))
#' df$select(pl$col("values")$arr$sum())
2

#' Max lists
#' @name arr_max
#' @description
#' Compute the max value of the lists in the array.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_max arr.max
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L,2:3)))
#' df$select(pl$col("values")$arr$max())
3

#'  #' Min lists
#' @name arr_min
#' @description
#' Compute the min value of the lists in the array.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_min arr.min
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L,2:3)))
#' df$select(pl$col("values")$arr$min())
4

#' Mean of lists
#' @name arr_mean
#' @description
#' Compute the mean value of the lists in the array.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_mean arr.mean
#' @examples
#' df = pl$DataFrame(values = pl$Series(list(1L,2:3)))
#' df$select(pl$col("values")$arr$mean())
5

#' Sort lists
#' @name arr_sort
#' @description
#' Sort the arrays in the list.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_sort arr.sort
#' @examples
#' df = pl$DataFrame(list(
#'   values = list(3:1,c(9L,1:2))
#' ))
#' df$select(pl$col("values")$arr$sort())
6

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
7


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
8


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
#' @aliases arr_get arr.get
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
#' df$select(pl$col("a")$arr$get(0))
#' df$select(pl$col("a")$arr$get(c(2,0,-1)))
9

#' Get list
#' @rdname arr_get
#' @export
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
#' df$select(pl$col("a")$arr[0])
#' df$select(pl$col("a")$arr[c(2,0,-1)])
`[.ExprListNameSpace` <- function(x, idx) {
  x$get(idx)
}


#' First in sublists
#' @name arr_first
#' @description Get the first value of the sublists.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_first arr.first
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
#' df$select(pl$col("a")$arr$first())
10

#' Last in sublists
#' @name arr_last
#' @description Get the last value of the sublists.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_last arr.last
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
#' df$select(pl$col("a")$arr$last())
11

#' Sublists contains
#' @name arr_contains
#' @description Check if sublists contain the given item.
#' @param item any into Expr/literal
#' @keywords ExprArr
#' @format function
#' @return Expr of a boolean mask
#' @aliases arr_contains arr.contains
#' @examples
#' df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
#' df$select(pl$col("a")$arr$contains(1))
12

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
#' df = pl$DataFrame(list(s = list(c("a","b","c"), c("x","y"))))
#' df$select(pl$col("s")$arr$join(" "))
13

#' Arg min sublists
#' @name arr_arg_min
#' @description
#'      Retrieve the index of the minimal value in every sublist.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_arg_min arr.arg_min
#' @examples
#' df = pl$DataFrame(list(s = list(1:2,2:1)))
#' df$select(pl$col("s")$arr$arg_min())
14

#' Arg max sublists
#' @name arr_arg_max
#' @description
#'      Retrieve the index of the maximum value in every sublist.
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_max arr.arg_max
#' @examples
#' df = pl$DataFrame(list(s = list(1:2,2:1)))
#' df$select(pl$col("s")$arr$arg_max())
15


#' Diff sublists
#' @name arr_diff
#' @description
#'      Calculate the n-th discrete difference of every sublist.
#' @param n
#' @param null_behavior choice "ignore"(default) "drop"
#' @keywords ExprArr
#' @format function
#' @return Expr
#' @aliases arr_max arr.arg_max
#' @examples
#' df = pl$DataFrame(list(s = list(1:4,c(10L,2L,1L))))
#' df$select(pl$col("s")$arr$diff())
15

