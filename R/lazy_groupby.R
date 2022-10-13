## ----- LazyGroupBy


#' print LazyGroupBy
#'
#' @param x LazyGroupBy
#'
#' @return self
#' @export
#'
print.LazyGroupBy = function(x) {
  cat("polars LazyGroupBy: \n")
  x$print()
}

#' @title LazyGroupBy_agg
#' @description
#' aggregate a polar_lazy_groupby
#' @param ... any Expr or string
#' @return A new `LazyFrame` object.
LazyGroupBy_agg = agg = function(...) {
  pra = construct_ProtoExprArray(...)
  .pr$LazyGroupBy$agg(self,pra)
}

#' @title LazyGroupBy_apply
#' @description
#' one day this will apply
#' @param f lambda function to apply
#' @return A new `LazyFrame` object.
LazyGroupBy_apply = function(f) {
  abort("this function is not yet implemented")
}

#' @title LazyGroupBy_head
#' @description
#' get n rows of head of group
#' @param n integer number of rows to get
#' @importFrom rlang is_integerish
#' @return A new `LazyFrame` object.
LazyGroupBy_head = function(n=1L) {
  if(!is_integerish(n) && n>=1L) abort("n rows must be a whole positive number")
  .pr$LazyGroupBy$head(n)
}


#' @title LazyGroupBy_tail
#' @description
#' get n tail rows of group
#' @param n integer number of rows to get
#' @return A new `LazyFrame` object.
LazyGroupBy_tail = function(n = 1L) {
  if(!is_integerish(n) && n>=1L) abort("n rows must be a whole positive number")
  .pr$LazyGroupBy$tail(n)
}


#' @title LazyGroupBy_print
#' @description
#' prints opague groupby, not much to show
#' @return NULL
LazyGroupBy_print = function() {
  .pr$LazyGroupBy$print(self)
  invisible(self)
}
