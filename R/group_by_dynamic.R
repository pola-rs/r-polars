#' Operations on Polars DataFrame grouped on time or integer values
#'
#' @return not applicable
#' @name DynamicGroupBy_class
NULL

RPolarsDynamicGroupBy = new.env(parent = emptyenv())

#' @export
`$.RPolarsDynamicGroupBy` = function(self, name) {
  func = RPolarsDynamicGroupBy[[name]]
  environment(func) = environment()
  func
}

#' @export
`[[.RPolarsDynamicGroupBy` = `$.RPolarsDynamicGroupBy`

#' @export
#' @noRd
.DollarNames.RPolarsDynamicGroupBy = function(x, pattern = "") {
  paste0(ls(RPolarsDynamicGroupBy, pattern = pattern), "()")
}

#' The internal DynamicGroupBy constructor
#' @return The input as grouped DataFrame
#' @noRd
construct_group_by_dynamic = function(
    df, index_column, every, period, offset, include_boundaries, closed, label,
    by, start_by, check_sorted) {
  if (!inherits(df, "RPolarsDataFrame")) {
    stop("internal error: construct_group called not on DataFrame")
  }
  # Make an empty object. Store everything (including data) in attributes, so
  # that we can keep the RPolarsDataFrame class on the data but still return
  # a RPolarsDynamicGroupBy object here.
  out = c(" ")
  attr(out, "private") = list(
    dat = df$clone(),
    index_column = index_column,
    every = every,
    period = period,
    offset = offset,
    include_boundaries = include_boundaries,
    closed = closed,
    label = label,
    by = by,
    start_by = start_by,
    check_sorted = check_sorted
  )
  class(out) = "RPolarsDynamicGroupBy"
  out
}

#' print DynamicGroupBy
#'
#' @param x DataFrame
#' @param ... not used
#' @noRd
#' @return self
#' @export
#'
#' @examples
#' df = pl$DataFrame(
#'   time = pl$date_range(
#'     start = strptime("2021-12-16 00:00:00", format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
#'     end = strptime("2021-12-16 03:00:00", format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
#'     interval = "30m",
#'     eager = TRUE,
#'   ),
#'   n = 0:6
#' )
#'
#' # get the sum in the following hour relative to the "time" column
#' df$group_by_dynamic("time", every = "1h")
print.RPolarsDynamicGroupBy = function(x, ...) {
  .pr$DataFrame$print(attr(x, "private")$dat)
}


#' Aggregate over a DynamicGroupBy
#'
#' Aggregate a DataFrame over a time or integer window created with
#' `$group_by_dynamic()`.
#'
#' @param ... Exprs to aggregate over. Those can also be passed wrapped in a
#' list, e.g `$agg(list(e1,e2,e3))`.
#'
#' @return An aggregated [DataFrame][DataFrame_class]
#' @inherit DataFrame_group_by_dynamic examples
DynamicGroupBy_agg = function(...) {
  prv = attr(self, "private")
  prv$dat$
    lazy()$
    group_by_dynamic(
    index_column = prv$index_column,
    every = prv$every,
    period = prv$period,
    offset = prv$offset,
    include_boundaries = prv$include_boundaries,
    closed = prv$closed,
    label = prv$label,
    by = prv$by,
    start_by = prv$start_by,
    check_sorted = prv$check_sorted
  )$
    agg(unpack_list(..., .context = "in $agg():"))$
    collect(no_optimization = TRUE)
}

#' Ungroup a DynamicGroupBy object
#'
#' Revert the `$group_by_dynamic()` operation. Doing
#' `<DataFrame>$group_by_dynamic(...)$ungroup()` returns the original `DataFrame`.
#'
#' @return [DataFrame][DataFrame_class]
#' @examples
#' df = pl$DataFrame(
#'   time = pl$date_range(
#'     start = strptime("2021-12-16 00:00:00", format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
#'     end = strptime("2021-12-16 03:00:00", format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
#'     interval = "30m",
#'     eager = TRUE,
#'   ),
#'   n = 0:6
#' )
#' df
#'
#' df$group_by_dynamic("time", every = "1h")$ungroup()
DynamicGroupBy_ungroup = function() {
  prv = attr(self, "private")
  prv$dat
}
