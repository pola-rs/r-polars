#' @title Operations on Polars grouped DataFrame
#' @return not applicable
#' @details The GroupBy class in R, is just another interface on top of the DataFrame(R wrapper class) in
#' rust polars. Groupby does not use the rust api for groupby+agg because the groupby-struct is a
#' reference to a DataFrame and that reference will share lifetime with its parent DataFrame. There
#' is no way to expose lifetime limited objects via extendr currently (might be quirky anyhow with R
#'  GC). Instead the inputs for the groupby are just stored on R side, until also agg is called.
#' Which will end up in a self-owned DataFrame object and all is fine. groupby aggs are performed
#' via the rust polars LazyGroupBy methods, see DataFrame.groupby_agg method.
#'
#' @name GroupBy_class
NULL



RPolarsGroupBy = new.env(parent = emptyenv())

#' @export
`$.RPolarsGroupBy` = function(self, name) {
  func = RPolarsGroupBy[[name]]
  environment(func) = environment()
  func
}

#' @export
`[[.RPolarsGroupBy` = `$.RPolarsGroupBy`

#' @title auto complete $-access into a polars object
#' @description called by the interactive R session internally
#' @param x GroupBy
#' @param pattern code-stump as string to auto-complete
#' @return char vec
#' @export
#' @inherit .DollarNames.RPolarsDataFrame return
#' @noRd
.DollarNames.RPolarsGroupBy = function(x, pattern = "") {
  paste0(ls(RPolarsGroupBy, pattern = pattern), completion_symbols$method)
}


#' The internal GroupBy constructor
#' @return The input as grouped DataFrame
#' @noRd
construct_group_by = function(df, groupby_input, maintain_order) {
  if (!inherits(df, "RPolarsDataFrame")) stop("internal error: construct_group called not on DataFrame")
  df = df$clone()
  attr(df, "private") = list(groupby_input = groupby_input, maintain_order = maintain_order)
  class(df) = "RPolarsGroupBy"
  df
}


#' print GroupBy
#'
#' @param x DataFrame
#' @param ... not used
#' @noRd
#' @return self
#' @export
#'
#' @examples pl$DataFrame(iris)$group_by("Species")
print.RPolarsGroupBy = function(x, ...) {
  .pr$DataFrame$print(x)
  cat("groups: ")
  prv = attr(x, "private")
  print(prv$groupby_input)
  cat("maintain order: ", prv$maintain_order)
  invisible(x)
}



#' Get and set column names of a GroupBy
#' @name GroupBy_columns
#' @rdname GroupBy_columns
#'
#' @return A character vector with the column names.
#' @keywords GroupBy
#'
#' @examples
#' gb = pl$GroupBy(iris)$group_by("Species")
#'
#' # get values
#' gb$columns
GroupBy_columns = method_as_property(function() {
  self$ungroup()$columns
})


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
#' )$
#'   group_by("foo")$
#'   agg(
#'   pl$col("bar")$sum()$name$suffix("_sum"),
#'   pl$col("bar")$mean()$alias("bar_tail_sum")
#' )
GroupBy_agg = function(...) {
  .pr$DataFrame$by_agg(
    self = self,
    group_exprs = attr(self, "private")$groupby_input,
    agg_exprs = unpack_list(...),
    maintain_order = attr(self, "private")$maintain_order
  ) |>
    unwrap("in $agg():")
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
#' @examples pl$DataFrame(mtcars)$lazy()$quantile(.4)$collect()
GroupBy_quantile = function(quantile, interpolation = "nearest") {
  self$agg(pl$all()$quantile(quantile, interpolation))
}

#' @title Shift
#' @description Shift the values by a given period.
#' @keywords GroupBy
#' @param periods integer Number of periods to shift (may be negative).
#' @return GroupBy
#' @examples pl$DataFrame(mtcars)$group_by("cyl")$shift(2)
GroupBy_shift = function(periods = 1) {
  self$agg(pl$all()$shift(periods))
}

#' @title Shift and fill
#' @description Shift and fill the values by a given period.
#' @keywords GroupBy
#' @param fill_value fill None values with the result of this expression.
#' @param periods integer Number of periods to shift (may be negative).
#' @return GroupBy
#' @examples pl$DataFrame(mtcars)$group_by("cyl")$shift_and_fill(99, 1)
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
#' pl$DataFrame(x)$group_by("cyl")$null_count()
GroupBy_null_count = function() {
  self$agg(pl$all()$null_count())
}


#' GroupBy_ungroup
#'
#' Revert the group by operation.
#' @return [DataFrame][DataFrame_class]
#' @examples
#' gb = pl$DataFrame(mtcars)$group_by("cyl")
#' gb
#'
#' gb$ungroup()
GroupBy_ungroup = function() {
  self = .pr$DataFrame$clone_in_rust(self)
  class(self) = "RPolarsDataFrame"
  attr(self, "private") = NULL
  self
}
