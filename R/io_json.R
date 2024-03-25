#' New LazyFrame from NDJSON
#'
#' @description
#' Read a file from path into a polars LazyFrame.
#' @rdname IO_scan_ndjson
#' @inheritParams pl_scan_csv
#' @param source Path to a file or URL. It is possible to provide multiple paths
#' provided that all NDJSON files have the same schema. It is not possible to
#' provide several URLs.
#' @param batch_size Number of rows that will be processed per thread.
#' @return A LazyFrame
#'
# we should use @examplesIf but altdoc doesn't know how to parse it yet
#' @examples
#' if (require("jsonlite", quietly = TRUE)) {
#'   ndjson_filename = tempfile()
#'   jsonlite::stream_out(iris, file(ndjson_filename), verbose = FALSE)
#'   pl$scan_ndjson(ndjson_filename)$collect()
#' }
pl_scan_ndjson = function(
    source,
    ...,
    infer_schema_length = 100,
    batch_size = NULL,
    n_rows = NULL,
    low_memory = FALSE,
    rechunk = FALSE,
    row_index_name = NULL,
    row_index_offset = 0,
    reuse_downloaded = TRUE,
    ignore_errors = FALSE) {
  # capture all args and modify some to match lower level function
  args = as.list(environment())

  # check if url link and predownload, wrap in result, robj_to! can unpack R-result
  args[["path"]] = lapply(
    source, check_is_link,
    reuse_downloaded = reuse_downloaded, raise_error = TRUE
  ) |>
    result()

  args[["source"]] = NULL
  args[["reuse_downloaded"]] = NULL

  ## call low level function with args
  check_no_missing_args(new_from_ndjson, args)
  do.call(new_from_ndjson, args) |>
    unwrap("in pl$scan_ndjson():")
}

#' New DataFrame from NDJSON
#'
#' @description
#' Read a file from path into a polars DataFrame.
#' @rdname IO_read_ndjson
#'
#' @inheritParams pl_scan_ndjson
#'
#' @return A DataFrame
#'
# we should use @examplesIf but altdoc doesn't know how to parse it yet
#' @examples
#' if (require("jsonlite", quietly = TRUE)) {
#'   ndjson_filename = tempfile()
#'   jsonlite::stream_out(iris, file(ndjson_filename), verbose = FALSE)
#'   pl$read_ndjson(ndjson_filename)
#' }
pl_read_ndjson = function(
    source,
    ...,
    infer_schema_length = 100,
    batch_size = NULL,
    n_rows = NULL,
    low_memory = FALSE,
    rechunk = FALSE,
    row_index_name = NULL,
    row_index_offset = 0,
    ignore_errors = FALSE) {
  .args = as.list(environment())
  result({
    do.call(pl$scan_ndjson, .args)$collect()
  }) |>
    unwrap("in pl$read_ndjson():")
}
