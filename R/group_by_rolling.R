#' @title Operations on Polars grouped DataFrame
#' @return not applicable
#' @details The RollingGroupBy class in R, is just another interface on top of the DataFrame(R wrapper class) in
#' rust polars. Groupby does not use the rust api for groupby+agg because the groupby-struct is a
#' reference to a DataFrame and that reference will share lifetime with its parent DataFrame. There
#' is no way to expose lifetime limited objects via extendr currently (might be quirky anyhow with R
#'  GC). Instead the inputs for the groupby are just stored on R side, until also agg is called.
#' Which will end up in a self-owned DataFrame object and all is fine. groupby aggs are performed
#' via the rust polars LazyGroupBy methods, see DataFrame.groupby_agg method.
#'
#' @name RollingGroupBy_class
NULL



RPolarsRollingGroupBy = new.env(parent = emptyenv())

#' @export
`$.RPolarsRollingGroupBy` = function(self, name) {
  func = RPolarsRollingGroupBy[[name]]
  environment(func) = environment()
  func
}

#' @export
`[[.RPolarsRollingGroupBy` = `$.RPolarsRollingGroupBy`

#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x RollingGroupBy
#' @param pattern code-stump as string to auto-complete
#' @return char vec
#' @export
#' @inherit .DollarNames.RPolarsDataFrame return
#' @noRd
.DollarNames.RPolarsRollingGroupBy = function(x, pattern = "") {
  paste0(ls(RPolarsRollingGroupBy, pattern = pattern), "()")
}

#' The internal RollingGroupBy constructor
#' @return The input as grouped DataFrame
#' @noRd
construct_rolling_group_by = function(df, index_column, period, offset, closed, by, check_sorted) {
  if (!inherits(df, "RPolarsDataFrame")) {
    stop("internal error: construct_group called not on DataFrame")
  }
  df = df$clone()
  attr(df, "private") = list(
    index_column = index_column,
    period = period,
    offset = offset,
    closed = closed,
    by = by,
    check_sorted = check_sorted
  )
  class(df) = "RPolarsRollingGroupBy"
  df
}

#' print RollingGroupBy
#'
#' @param x DataFrame
#' @param ... not used
#' @noRd
#' @return self
#' @export
#'
#' @examples pl$DataFrame(iris)$group_by("Species")
print.RPolarsRollingGroupBy = function(x, ...) {
  .pr$DataFrame$print(x)
  prv = attr(x, "private")
  index = prv$index_column
  period = prv$period
  offset = prv$offset
  closed = prv$closed
  by = prv$by
  cat(paste("index column:", index))
  cat(paste("\nother groups:", toString(by)))
  cat(paste("\nperiod:", period))
  cat(paste("\noffset:", offset))
  cat(paste("\nclosed:", closed))
  invisible(x)
}


#' Aggregate over a RollingGroupBy
#' @description Aggregate a DataFrame over a groupby
#' @param ... exprs to aggregate over.
#' ... args can also be passed wrapped in a list `$agg(list(e1,e2,e3))`
#' @return aggregated DataFrame
#' @aliases agg
#' @examples
#' pl$DataFrame(
#'   foo = c("one", "two", "two", "one", "two"),
#'   bar = c(5, 3, 2, 4, 1)
#' )$
#'   group_by("foo")$
#'   agg(
#'   pl$col("bar")$sum()$name$suffix("_sum"),
#'   pl$col("bar")$mean()$alias("bar_tail_sum")
#' )
RollingGroupBy_agg = function(...) {
  class(self) = "RPolarsLazyGroupBy"
  self$agg(unpack_list(..., .context = "in $agg():"))$collect(no_optimization = TRUE)
}

#' RollingGroupBy_ungroup
#'
#' Revert the group by operation.
#' @return [DataFrame][DataFrame_class]
#' @examples
#' gb = pl$DataFrame(mtcars)$group_by("cyl")
#' gb
#'
#' gb$ungroup()
RollingGroupBy_ungroup = function() {
  class(self) = "RPolarsLazyGroupBy"
  self$ungroup()$collect(no_optimization = TRUE)
}
