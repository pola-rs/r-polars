#' Operations on Polars grouped DataFrame
#'
#' The GroupBy class in R, is just another interface on top of the
#' [DataFrame][DataFrame_class] in rust polars.
#' Groupby does not use the rust api for
#' [`<DataFrame>$group_by()`][DataFrame_group_by] + [`$agg()`][GroupBy_agg]
#' because the groupby-struct is a reference to a DataFrame and that reference
#' will share lifetime with its parent DataFrame.
#'
#' There is no way to expose lifetime limited objects via extendr currently
#' (might be quirky anyhow with R GC).
#' Instead the inputs for the `group_by` are just stored on R side, until also `agg` is called.
#' Which will end up in a self-owned DataFrame object and all is fine. groupby aggs are performed
#' via the rust polars LazyGroupBy methods, see DataFrame.groupby_agg method.
#'
#' @section Active bindings:
#'
#' ## columns
#'
#' `$columns` returns a character vector with the column names.
#'
#' @name GroupBy_class
#' @aliases RPolarsGroupBy
#' @examples
#' as_polars_df(mtcars)$group_by("cyl")$agg(
#'   pl$col("mpg")$sum()
#' )
NULL


RPolarsGroupBy = new.env(parent = emptyenv())


# Active bindings

GroupBy_columns = method_as_active_binding(\() self$ungroup()$columns)


#' @export
`$.RPolarsGroupBy` = function(self, name) {
  func = RPolarsGroupBy[[name]]
  environment(func) = environment()
  func
}

#' @export
`[[.RPolarsGroupBy` = `$.RPolarsGroupBy`

#' @export
#' @noRd
.DollarNames.RPolarsGroupBy = function(x, pattern = "") {
  paste0(ls(RPolarsGroupBy, pattern = pattern), completion_symbols$method)
}

#' The internal GroupBy constructor
#' @return The input as grouped DataFrame
#' @noRd
construct_group_by = function(df, groupby_input, maintain_order) {
  if (!inherits(df, "RPolarsDataFrame")) {
    stop("internal error: construct_group called not on DataFrame")
  }
  # Make an empty object. Store everything (including data) in attributes, so
  # that we can keep the RPolarsDataFrame class on the data but still return
  # a RPolarsGroupBy object here.
  out = c(" ")
  attr(out, "private") = list(
    dat = df$clone(),
    groupby_input = unpack_list(groupby_input),
    maintain_order = maintain_order
  )
  class(out) = "RPolarsGroupBy"
  out
}


#' print GroupBy
#'
#' @param x DataFrame
#' @param ... not used
#' @noRd
#' @return self
#' @export
#'
#' @examples
#' as_polars_df(iris)$group_by("Species")
print.RPolarsGroupBy = function(x, ...) {
  prv = attr(x, "private")
  .pr$DataFrame$print(prv$dat)
  cat("groups:", toString(prv$groupby_input))
  cat("\nmaintain order:", prv$maintain_order)
  invisible(x)
}


#' Aggregate over a GroupBy
#' @description Aggregate a DataFrame over a groupby
#' @param ... exprs to aggregate over.
#' ... args can also be passed wrapped in a list `$agg(list(e1,e2,e3))`
#' @return aggregated DataFrame
#' @aliases agg
#' @examples
#' pl$DataFrame(
#'   foo = c("one", "two", "two", "one", "two"),
#'   bar = c(5, 3, 2, 4, 1)
#' )$group_by("foo")$agg(
#'   pl$col("bar")$sum()$name$suffix("_sum"),
#'   pl$col("bar")$mean()$alias("bar_tail_sum")
#' )
GroupBy_agg = function(...) {
  prv = attr(self, "private")
  prv$dat$lazy()$group_by(
    prv$groupby_input,
    maintain_order = prv$maintain_order
  )$
    agg(...)$
    collect(no_optimization = TRUE)
}


#' GroupBy First
#' @description Reduce the groups to the first value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 2, 2, 3, 4, 5),
#'   b = c(0.5, 0.5, 4, 10, 13, 14),
#'   c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'   d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$group_by("d", maintain_order = TRUE)$first()
GroupBy_first = function() {
  self$agg(pl$all()$first())
}

#' GroupBy Last
#' @description Reduce the groups to the last value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 2, 2, 3, 4, 5),
#'   b = c(0.5, 0.5, 4, 10, 13, 14),
#'   c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'   d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$group_by("d", maintain_order = TRUE)$last()
GroupBy_last = function() {
  self$agg(pl$all()$last())
}

#' GroupBy Max
#' @description Reduce the groups to the maximum value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 2, 2, 3, 4, 5),
#'   b = c(0.5, 0.5, 4, 10, 13, 14),
#'   c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'   d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$group_by("d", maintain_order = TRUE)$max()
GroupBy_max = function() {
  self$agg(pl$all()$max())
}

#' GroupBy Mean
#' @description Reduce the groups to the mean value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 2, 2, 3, 4, 5),
#'   b = c(0.5, 0.5, 4, 10, 13, 14),
#'   c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'   d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$group_by("d", maintain_order = TRUE)$mean()
GroupBy_mean = function() {
  self$agg(pl$all()$mean())
}

#' GroupBy Median
#' @description Reduce the groups to the median value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 2, 2, 3, 4, 5),
#'   b = c(0.5, 0.5, 4, 10, 13, 14),
#'   c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'   d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$group_by("d", maintain_order = TRUE)$median()
GroupBy_median = function() {
  self$agg(pl$all()$median())
}

#' GroupBy Min
#' @description Reduce the groups to the minimum value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 2, 2, 3, 4, 5),
#'   b = c(0.5, 0.5, 4, 10, 13, 14),
#'   c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'   d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$group_by("d", maintain_order = TRUE)$min()
GroupBy_min = function() {
  self$agg(pl$all()$min())
}

#' GroupBy Sum
#' @description Reduce the groups to the sum value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 2, 2, 3, 4, 5),
#'   b = c(0.5, 0.5, 4, 10, 13, 14),
#'   c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'   d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$group_by("d", maintain_order = TRUE)$sum()
GroupBy_sum = function() {
  self$agg(pl$all()$sum())
}

#' GroupBy Var
#' @description Reduce the groups to the variance value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 2, 2, 3, 4, 5),
#'   b = c(0.5, 0.5, 4, 10, 13, 14),
#'   c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'   d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$group_by("d", maintain_order = TRUE)$var()
GroupBy_var = function() {
  self$agg(pl$all()$var())
}

#' GroupBy Std
#' @description Reduce the groups to the standard deviation value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'   a = c(1, 2, 2, 3, 4, 5),
#'   b = c(0.5, 0.5, 4, 10, 13, 14),
#'   c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'   d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$group_by("d", maintain_order = TRUE)$std()
GroupBy_std = function() {
  self$agg(pl$all()$std())
}

#' @title Quantile
#' @description Aggregate the columns in the DataFrame to their quantile value.
#' @keywords GroupBy
#' @param quantile numeric Quantile between 0.0 and 1.0.
#' @param interpolation string Interpolation method: "nearest", "higher", "lower", "midpoint", or "linear".
#' @return GroupBy
#' @examples as_polars_df(mtcars)$lazy()$quantile(.4)$collect()
GroupBy_quantile = function(quantile, interpolation = "nearest") {
  self$agg(pl$all()$quantile(quantile, interpolation))
}

#' Shift the values by a given period
#'
#' @inheritParams DataFrame_shift
#'
#' @return GroupBy
#' @examples
#' as_polars_df(mtcars)$group_by("cyl")$shift(2)
GroupBy_shift = function(n = 1, fill_value = NULL) {
  self$agg(pl$all()$shift(n, fill_value))
}

#' @title GroupBy null count
#' @description Create a new DataFrame that shows the null counts per column.
#' @keywords DataFrame
#' @return DataFrame
#' @examples
#' x = mtcars
#' x[1:10, 3:5] = NA
#' pl$DataFrame(x)$group_by("cyl")$null_count()
GroupBy_null_count = function() {
  self$agg(pl$all()$null_count())
}


#' GroupBy_ungroup
#'
#' Revert the group by operation.
#' @return [DataFrame][DataFrame_class]
#' @examples
#' gb = as_polars_df(mtcars)$group_by("cyl")
#' gb
#'
#' gb$ungroup()
GroupBy_ungroup = function() {
  prv = attr(self, "private")
  prv$dat
}
