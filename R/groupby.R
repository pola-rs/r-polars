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

#' @export
.DollarNames.GroupBy = function(x, pattern = "") {
  paste0(ls(minipolars:::GroupBy),"()")
}

#' print GroupBy
#'
#' @param x polar_frame
#'
#' @return self
#' @export
#'
#' @examples pl$DataFrame(iris)$groupby("Species")
print.GroupBy = function(x) {
  cat("polars GroupBy: ")
  .pr$DataFrame$print(x)
  cat("groups: ")
  .pr$ProtoExprArray$print(attr(x,"private")$groupby_input)
  cat("maintain order: ", attr(x,"private")$maintain_order)
  invisible(x)
}


#' Aggregatete a DataFrame over a groupby
#'
#'
#' @description Hej mor
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
