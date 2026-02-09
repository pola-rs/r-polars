# Input lines functions: scan_lines, read_lines

#' Construct a LazyFrame which scans lines into a string column from a file
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' @inheritParams pl__scan_csv
#' @param name Name to use for the output column.
#'
#' @inherit as_polars_lf return
#' @param batch_size Number of rows to read in each batch.
#' @examplesIf requireNamespace("withr", quietly = TRUE)
#' dest <- withr::local_tempfile()
#' writeLines("Hello\nworld", dest)
#' pl$scan_lines(dest)$collect()
pl__scan_lines <- function(
  source,
  ...,
  name = "lines",
  n_rows = NULL,
  row_index_name = NULL,
  row_index_offset = 0L,
  glob = TRUE,
  storage_options = NULL,
  include_file_paths = NULL
) {
  check_dots_empty0(...)
  check_character(source, allow_na = FALSE)
  if (length(source) == 0) {
    abort("`source` must have length > 0.")
  }
  check_character(storage_options, allow_null = TRUE)

  PlRLazyFrame$new_from_scan_lines(
    source = source,
    name = name,
    n_rows = n_rows,
    row_index_name = row_index_name,
    row_index_offset = row_index_offset,
    storage_options = storage_options,
    include_file_paths = include_file_paths,
    glob = glob
  ) |>
    wrap()
}

#' Read lines into a string column from a file
#'
#' @inherit pl__scan_lines description params
#' @inherit as_polars_df return
#'
#' @examplesIf requireNamespace("withr", quietly = TRUE)
#' dest <- withr::local_tempfile()
#' writeLines("Hello\nworld", dest)
#' pl$read_lines(dest)
pl__read_lines <- function(
  source,
  ...,
  name = "lines",
  n_rows = NULL,
  row_index_name = NULL,
  row_index_offset = 0L,
  glob = TRUE,
  storage_options = NULL,
  include_file_paths = NULL
) {
  check_dots_empty0(...)
  .args <- as.list(environment())
  do.call(pl__scan_lines, .args)$collect() |>
    wrap()
}
