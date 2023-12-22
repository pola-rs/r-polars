## ----- LazyGroupBy


#' print LazyGroupBy
#'
#' @param x LazyGroupBy
#' @param ... not used
#' @return self
#' @noRd
#' @export
#'
print.RPolarsLazyGroupBy = function(x, ...) {
  cat("polars LazyGroupBy: \n")
  x$print()
}

#' @title LazyGroupBy_agg
#' @description
#' aggregate a polar_lazy_group_by
#' @param ... exprs to aggregate over.
#' ... args can also be passed wrapped in a list `$agg(list(e1,e2,e3))`
#' @return A new `LazyFrame` object.
#' @examples
#' lgb = pl$DataFrame(
#'   foo = c("one", "two", "two", "one", "two"),
#'   bar = c(5, 3, 2, 4, 1)
#' )$
#'   lazy()$
#'   group_by("foo")
#'
#'
#' print(lgb)
#'
#' lgb$
#'   agg(
#'   pl$col("bar")$sum()$name$suffix("_sum"),
#'   pl$col("bar")$mean()$alias("bar_tail_sum")
#' )
LazyGroupBy_agg = agg = function(...) {
  .pr$LazyGroupBy$agg(self, unpack_list(...)) |>
    unwrap("in $agg():")
}

#' @title LazyGroupBy_apply
#' @description
#' one day this will apply
#' @param f  R function to apply
#' @return A new `LazyFrame` object.
LazyGroupBy_apply = function(f) {
  stop("this function is not yet implemented")
}

#' @title LazyGroupBy_head
#' @description
#' get n rows of head of group
#' @param n integer number of rows to get
#' @return A new `LazyFrame` object.
LazyGroupBy_head = function(n = 1L) {
  unwrap(.pr$LazyGroupBy$head(n))
}


#' @title LazyGroupBy_tail
#' @description
#' get n tail rows of group
#' @param n integer number of rows to get
#' @return A new `LazyFrame` object.
LazyGroupBy_tail = function(n = 1L) {
  unwrap(.pr$LazyGroupBy$tail(n))
}


#' @title LazyGroupBy_print
#' @description
#' prints opaque groupby, not much to show
#' @return invisible self
LazyGroupBy_print = function() {
  .pr$LazyGroupBy$print(self)
  invisible(self)
}


#' LazyGroupBy_ungroup
#'
#' Revert the group by operation.
#' @inherit LazyGroupBy_agg return
#' @examples
#' lf = pl$LazyFrame(mtcars)
#' lf
#'
#' lgb = lf$group_by("cyl")
#' lgb
#'
#' lgb$ungroup()
LazyGroupBy_ungroup = function() {
  .pr$LazyGroupBy$ungroup(self)
}
