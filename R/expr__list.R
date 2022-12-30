
#' make_expr_arr_namespace
#' @description
#' Internal function to yield methods within arr namespace
#' See the individual method pages for full details
#' @keywords internals
#' @return environment with methods to call on self
make_expr_arr_namespace = function(self) {
  env = new.env()

  #' Lenghts arrays in list
  #' @name arr$lengths
  #' @description
  #' Get the length of the arrays as UInt32.
  #' @keywords ExprArr
  #' @return Expr
  #' @aliases lengths
  #' @examples
  #' df = pl$DataFrame(list_of_strs = pl$Series(list(c("a","b"),"c")))
  #' df$with_column(pl$col("list_of_strs")$arr$lengths()$alias("list_of_strs_lengths"))
  env$lengths = function() .pr$Expr$arr_lengths(self)

  env$min = function() .pr$Expr$lst_min(self)

  env$max = function() .pr$Expr$lst_max(self)

  env$sum = function() .pr$Expr$lst_sum(self)

  env$mean = function() .pr$Expr$lst_mean(self)

  env$sort = function(reverse = FALSE) {
    .pr$Expr$lst_sort(self, reverse)
  }

  env$reverse = function() .pr$Expr$lst_reverse(self)

  env$unique = function() .pr$Expr$lst_unique(self)

  env$get= function(index) {
    .pr$Expr$lst_get(self, wrap_e(index,str_to_lit = FALSE))
  }

  env
}
