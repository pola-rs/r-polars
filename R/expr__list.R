
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
  env$get  = function(index) .pr$Expr$lst_get(self, wrap_e(index,str_to_lit = FALSE))

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
#' @description
#' Get the value by index in the sublists.
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
9
