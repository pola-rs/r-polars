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

#' print GroupBy
#'
#' @param x DataFrame
#' @param ... not used
#' @return self
#' @export
#'
#' @examples pl$DataFrame(iris)$groupby("Species")
print.GroupBy = function(x, ...) {
  cat("polars GroupBy: ")
  .pr$DataFrame$print(x)
  cat("groups: ")
  .pr$ProtoExprArray$print(attr(x,"private")$groupby_input)
  cat("maintain order: ", attr(x,"private")$maintain_order)
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
  unwrap(
    .pr$DataFrame$by_agg(
      self = self,
      group_exprs = attr(self,"private")$groupby_input,
      agg_exprs   = construct_ProtoExprArray(...),
      maintain_order = attr(self,"private")$maintain_order
    )
  )
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
#' @param ... any opt param passed to R as.data.frame
#'
#' @return R data.frame
#' @export
#'
#' @examples pl$DataFrame(iris)$as_data_frame() #R-polars back and forth
GroupBy_as_data_frame = function(...) {
  as.data.frame(
    x = unwrap(.pr$DataFrame$to_list(self)),
    col.names = .pr$DataFrame$columns(self),
    ...
  )
}
