#' @title Operations on Polars grouped DataFrame
#'
#' @name GroupBy_class
NULL

# The GroupBy class in R, is just another interface on top of the DataFrame(R wrapper class) in rust polars.
# Groupby does not use the rust api for groupby+agg because the groupby-struct is a reference to a DataFrame
# and that reference will share lifetime with its parent DataFrame. There is no way to expose lifetime
# limited objects via extendr currently (might be quirky anyhow with R GC). Instead the inputs for the groupby
# are just stored on R side, until also agg is called. Which will end up in a self-owned DataFrame object and
# all is fine.
# groupby aggs are performed via the rust polars LazyGroupBy methods, see DataFrame.groupby_agg method.

GroupBy <- new.env(parent = emptyenv())

#' @export
`$.GroupBy` <- function (self, name) { func <- GroupBy[[name]]; environment(func) <- environment(); func }

#' @export
`[[.GroupBy` <- `$.GroupBy`

#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x GroupBy
#' @param pattern code-stump as string to auto-complete
#' @export
#' @keywords internal
.DollarNames.GroupBy = function(x, pattern = "") {
  paste0(ls(GroupBy, pattern = pattern ),"()")
}


#' The internal GroupBy constructor
#' @noRd
construct_groupby = function(df, groupby_input, maintain_order) {
  if(!inherits(df,"DataFrame")) fstop("internal error: construct_group called not on DataFrame")
  df = df$clone()
  attr(df,"private") = list(groupby_input  = groupby_input, maintain_order = maintain_order)
  class(df) = "GroupBy"
  df
}


#' print GroupBy
#'
#' @param x DataFrame
#' @param ... not used
#' @keywords internal
#' @return self
#' @export
#'
#' @examples pl$DataFrame(iris)$groupby("Species")
print.GroupBy = function(x, ...) {
  .pr$DataFrame$print(x)
  cat("groups: ")
  prv = attr(x,"private")
  print(prv$groupby_input)
  cat("maintain order: ", prv$maintain_order)
  invisible(x)
}


#' GroupBy Aggregate
#' @description Aggregatete a DataFrame over a groupby
#' @param ... exprs to aggregate
#'
#' @return aggregated DataFrame
#' @export
#' @aliases agg
#'
#' @examples
#' pl$DataFrame(
#'   list(
#'     foo = c("one", "two", "two", "one", "two"),
#'     bar = c(5, 3, 2, 4, 1)
#'   )
#' )$groupby(
#' "foo"
#' )$agg(
#'  pl$col("bar")$sum()$alias("bar_sum"),
#'  pl$col("bar")$mean()$alias("bar_tail_sum")
#' )
#'
GroupBy_agg = function(...) {

  .pr$DataFrame$by_agg(
    self = self,
    group_exprs = attr(self,"private")$groupby_input,
    agg_exprs   = list2(...),
    maintain_order = attr(self,"private")$maintain_order
  ) |>
    unwrap("in $agg():")
}


#' GroupBy First
#' @description Reduce the groups to the first value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'         a = c(1, 2, 2, 3, 4, 5),
#'         b = c(0.5, 0.5, 4, 10, 13, 14),
#'         c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'         d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$groupby("d", maintain_order=TRUE)$first()
GroupBy_first = function() {
  self$agg(pl$all()$first())
}

#' GroupBy Last
#' @description Reduce the groups to the last value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'         a = c(1, 2, 2, 3, 4, 5),
#'         b = c(0.5, 0.5, 4, 10, 13, 14),
#'         c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'         d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$groupby("d", maintain_order=TRUE)$last()
GroupBy_last = function() {
  self$agg(pl$all()$last())
}

#' GroupBy Max
#' @description Reduce the groups to the maximum value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'         a = c(1, 2, 2, 3, 4, 5),
#'         b = c(0.5, 0.5, 4, 10, 13, 14),
#'         c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'         d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$groupby("d", maintain_order=TRUE)$max()
GroupBy_max = function() {
  self$agg(pl$all()$max())
}

#' GroupBy Mean
#' @description Reduce the groups to the mean value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'         a = c(1, 2, 2, 3, 4, 5),
#'         b = c(0.5, 0.5, 4, 10, 13, 14),
#'         c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'         d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$groupby("d", maintain_order=TRUE)$mean()
GroupBy_mean = function() {
  self$agg(pl$all()$mean())
}

#' GroupBy Median
#' @description Reduce the groups to the median value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'         a = c(1, 2, 2, 3, 4, 5),
#'         b = c(0.5, 0.5, 4, 10, 13, 14),
#'         c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'         d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$groupby("d", maintain_order=TRUE)$median()
GroupBy_median = function() {
  self$agg(pl$all()$median())
}

#' GroupBy Min
#' @description Reduce the groups to the minimum value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'         a = c(1, 2, 2, 3, 4, 5),
#'         b = c(0.5, 0.5, 4, 10, 13, 14),
#'         c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'         d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$groupby("d", maintain_order=TRUE)$min()
GroupBy_min = function() {
  self$agg(pl$all()$min())
}

#' GroupBy Sum
#' @description Reduce the groups to the sum value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'         a = c(1, 2, 2, 3, 4, 5),
#'         b = c(0.5, 0.5, 4, 10, 13, 14),
#'         c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'         d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$groupby("d", maintain_order=TRUE)$sum()
GroupBy_sum = function() {
  self$agg(pl$all()$sum())
}

#' GroupBy Var
#' @description Reduce the groups to the variance value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'         a = c(1, 2, 2, 3, 4, 5),
#'         b = c(0.5, 0.5, 4, 10, 13, 14),
#'         c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'         d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$groupby("d", maintain_order=TRUE)$var()
GroupBy_var = function() {
  self$agg(pl$all()$var())
}

#' GroupBy Std
#' @description Reduce the groups to the standard deviation value.
#' @return aggregated DataFrame
#' @keywords GroupBy
#' @examples
#' df = pl$DataFrame(
#'         a = c(1, 2, 2, 3, 4, 5),
#'         b = c(0.5, 0.5, 4, 10, 13, 14),
#'         c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
#'         d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
#' )
#' df$groupby("d", maintain_order=TRUE)$std()
GroupBy_std = function() {
  self$agg(pl$all()$std())
}

#' @title Quantile
#' @description Aggregate the columns in the DataFrame to their quantile value.
#' @keywords GroupBy
#' @param quantile numeric Quantile between 0.0 and 1.0.
#' @param interpolation string Interpolation method: "nearest", "higher", "lower", "midpoint", or "linear".
#' @return GroupBy
#' @examples pl$DataFrame(mtcars)$lazy()$quantile(.4)$collect()
GroupBy_quantile = function(quantile, interpolation = "nearest") {
  self$agg(pl$all()$quantile(quantile, interpolation))
}

#' @title Shift
#' @description Shift the values by a given period.
#' @keywords GroupBy
#' @param periods integer Number of periods to shift (may be negative).
#' @return GroupBy
#' @examples pl$DataFrame(mtcars)$groupby("cyl")$shift(2)
GroupBy_shift = function(periods = 1) {
  self$agg(pl$all()$shift(periods))
}

#' @title Shift and fill
#' @description Shift and fill the values by a given period.
#' @keywords GroupBy
#' @param fill_value fill None values with the result of this expression.
#' @param periods integer Number of periods to shift (may be negative).
#' @return GroupBy
#' @examples pl$DataFrame(mtcars)$groupby("cyl")$shift_and_fill(99, 1)
GroupBy_shift_and_fill = function(fill_value, periods = 1) {
  self$agg(pl$all()$shift_and_fill(periods, fill_value))
}

#' @title GroupBy null count
#' @description Create a new DataFrame that shows the null counts per column.
#' @keywords DataFrame
#' @return DataFrame
#' @examples
#' x = mtcars
#' x[1:10, 3:5] = NA
#' pl$DataFrame(x)$groupby("cyl")$null_count()
GroupBy_null_count <- function() {
  self$agg(pl$all()$null_count())
}

#' convert to data.frame
#'
#' @param ... not used
#'
#' @return R data.frame
#' @export
#'
#' @examples pl$DataFrame(iris)$to_data_frame() #R-polars back and forth
GroupBy_to_data_frame = function(...) {
  class(self) = "DataFrame"
  self$to_data_frame(...)
}

#TODO REMOVE_AT_BREAKING_CHANGE
#' Alias to GroupBy_to_data_frame (backward compatibility)
#' @noRd
GroupBy_as_data_frame = GroupBy_to_data_frame
