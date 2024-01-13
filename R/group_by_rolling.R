#' Operations on Polars DataFrame grouped by rolling windows
#'
#' @return not applicable
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

#' @export
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
  # Make an empty object. Store everything (including data) in attributes, so
  # that we can keep the RPolarsDataFrame class on the data but still return
  # a RPolarsRollingGroupBy object here.
  out = c(" ")
  attr(out, "private") = list(
    dat = df$clone(),
    index_column = index_column,
    period = period,
    offset = offset,
    closed = closed,
    by = by,
    check_sorted = check_sorted
  )
  class(out) = "RPolarsRollingGroupBy"
  out
}

#' print RollingGroupBy
#'
#' @param x DataFrame
#' @param ... not used
#' @noRd
#' @return self
#' @export
#'
#' @examples
#' df = pl$DataFrame(
#'   dt = c("2020-01-01", "2020-01-01", "2020-01-01", "2020-01-02", "2020-01-03", "2020-01-08"),
#'   a = c(3, 7, 5, 9, 2, 1)
#' )$with_columns(
#'   pl$col("dt")$str$strptime(pl$Date, format = NULL)$set_sorted()
#' )
#'
#' df$rolling(index_column = "dt", period = "2d")
print.RPolarsRollingGroupBy = function(x, ...) {
  prv = attr(x, "private")
  .pr$DataFrame$print(prv$dat)
  cat(paste("index column:", prv$index))
  cat(paste("\nother groups:", toString(prv$by)))
  cat(paste("\nperiod:", prv$period))
  cat(paste("\noffset:", prv$offset))
  cat(paste("\nclosed:", prv$closed))
}


#' Aggregate over a RollingGroupBy
#'
#' Aggregate a DataFrame over a rolling window created with `$rolling()`.
#'
#' @param ... Exprs to aggregate over. Those can also be passed wrapped in a
#' list, e.g `$agg(list(e1,e2,e3))`.
#'
#' @return An aggregated [DataFrame][DataFrame_class]
#' @examples
#' df = pl$DataFrame(
#'   dt = c("2020-01-01", "2020-01-01", "2020-01-01", "2020-01-02", "2020-01-03", "2020-01-08"),
#'   a = c(3, 7, 5, 9, 2, 1)
#' )$with_columns(
#'   pl$col("dt")$str$strptime(pl$Date, format = NULL)$set_sorted()
#' )
#'
#' df$rolling(index_column = "dt", period = "2d")$agg(
#'   pl$col("a"),
#'   pl$sum("a")$alias("sum_a"),
#'   pl$min("a")$alias("min_a"),
#'   pl$max("a")$alias("max_a")
#' )
RollingGroupBy_agg = function(...) {
  prv = attr(self, "private")
  prv$dat$
    lazy()$
    rolling(
    index_column = prv$index,
    period = prv$period,
    offset = prv$offset,
    closed = prv$closed,
    by = prv$by,
    check_sorted = prv$check_sorted
  )$
    agg(unpack_list(..., .context = "in $agg():"))$
    collect(no_optimization = TRUE)
}

#' Ungroup a RollingGroupBy object
#'
#' Revert the `$rolling()` operation. Doing `<DataFrame>$rolling(...)$ungroup()`
#' returns the original `DataFrame`.
#'
#' @return [DataFrame][DataFrame_class]
#' @examples
#' df = pl$DataFrame(
#'   dt = c("2020-01-01", "2020-01-01", "2020-01-01", "2020-01-02", "2020-01-03", "2020-01-08"),
#'   a = c(3, 7, 5, 9, 2, 1)
#' )$with_columns(
#'   pl$col("dt")$str$strptime(pl$Date, format = NULL)$set_sorted()
#' )
#'
#' df$rolling(index_column = "dt", period = "2d")$ungroup()
RollingGroupBy_ungroup = function() {
  prv = attr(self, "private")
  prv$dat
}
