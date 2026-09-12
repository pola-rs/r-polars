#' @rdname lazyframe__sink_parquet
#' @param min Include stats on the minimum values in the column.
#' @param max Include stats on the maximum values in the column.
#' @param distinct_count Include stats on the number of distinct values in the
#' column.
#' @param null_count Include stats on the number of null values in the column.
#'
#' @export
parquet_statistics <- function(
  ...,
  min = TRUE,
  max = TRUE,
  distinct_count = TRUE,
  null_count = TRUE
) {
  check_dots_empty0(...)
  check_bool(min)
  check_bool(max)
  check_bool(distinct_count)
  check_bool(null_count)

  structure(
    list(
      min = min,
      max = max,
      distinct_count = distinct_count,
      null_count = null_count
    ),
    class = c("polars_parquet_statistics", "list")
  )
}

#' Transforms raw percentiles into our preferred format, adding the 50th
#' percentile.
#' Raises an error if the percentile sequence is invalid (e.g. outside the
#' range `[0, 1]`).
#' @noRd
parse_percentiles <- function(percentiles, inject_median = FALSE) {
  if (!all(percentiles >= 0 & percentiles <= 1)) {
    abort("`percentiles` must all be in the range [0, 1].")
  }
  sub_50_percentiles <- percentiles[percentiles < 50] |>
    sort()
  at_or_above_50_percentiles <- percentiles[percentiles >= 50] |>
    sort()
  if (
    isTRUE(inject_median) &&
      (length(at_or_above_50_percentiles) == 0 || at_or_above_50_percentiles[1] != 0.5)
  ) {
    at_or_above_50_percentiles <- c(0.5, at_or_above_50_percentiles)
  }

  c(sub_50_percentiles, at_or_above_50_percentiles)
}
