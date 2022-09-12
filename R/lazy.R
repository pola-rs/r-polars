
#' @export
.DollarNames.LazyFrame = function(x, pattern = "") {
  paste0(ls(minipolars:::LazyFrame),"()")
}

#' print GroupBy
#'
#' @param x polar_frame
#'
#' @return self
#' @export
#'
#' @examples pl$DataFrame(iris)$groupby("Species")
print.LazyFrame= function(x) {
  print("polars LazyFrame naive plan: (run ldf$describe_optimized_plan() to see the optimized plan)")
  x$print()
  invisible(x)
}

Lazy_select = function(...) {
  pra = construct_ProtoExprArray(...)
  .pr$LazyFrame$select(self,pra)
}


#' @title Lazy_groupby
#' @description
#' groupby on lazy_polar_frame.
#' @param ... any single Expr or string naming a column
#' @return A new `lazy_polar_frame` object with applied filter.
Lazy_groupby = function(..., maintain_order = FALSE) {
  pra = construct_ProtoExprArray(...)
  .pr$LazyFrame$groupby(self,pra,maintain_order)
}


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
#' @return A new `lazy_polar_frame` object.
LazyGroupBy_agg = agg = function(...) {
  pra = construct_ProtoExprArray(...)
  .pr$LazyGroupBy$agg(self,pra)
}

#' @title LazyGroupBy_apply
#' @description
#' one day this will apply
#' @param f lambda function to apply
#' @return A new `lazy_polar_frame` object.
LazyGroupBy_apply = function(f) {
  abort("this function is not yet implemented")
}

#' @title LazyGroupBy_head
#' @description
#' get n rows of head of group
#' @param n integer number of rows to get
#' @importFrom rlang is_integerish
#' @return A new `lazy_polar_frame` object.
LazyGroupBy_head = function(n=1L) {
  if(!is_integerish(n) && n>=1L) abort("n rows must be a whole positive number")
  .pr$LazyGroupBy$head(n)
}


#' @title LazyGroupBy_tail
#' @description
#' get n tail rows of group
#' @param n integer number of rows to get
#' @return A new `lazy_polar_frame` object.
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




