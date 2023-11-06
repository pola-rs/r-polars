#' New LazyFrame from NDJSON
#'
#' @description
#' Read a file from path into a polars LazyFrame.
#' @name scan_ndjson
#' @rdname IO_scan_ndjson
#'
#' @param path Path to a file or URL. It is possible to provide multiple paths
#' provided that all NDJSON files have the same schema. It is not possible to
#' provide several URLs.
#' @param infer_schema_length Maximum number of rows to read to infer the column
#' types. If set to 0, all columns will be read as UTF-8. If `NULL`, a full
#' table scan will be done (slow).
#' @param batch_size Number of rows that will be processed per thread.
#' @param n_rows Maximum number of rows to read.
#' @param low_memory Reduce memory usage (will yield a lower performance).
#' @param rechunk Reallocate to contiguous memory when all chunks / files are
#' parsed.
#' @param row_count_name If not `NULL`, this will insert a row count column with
#' the given name into the DataFrame.
#' @param row_count_offset Offset to start the row_count column (only used if
#' the name is set).
#'
#' @return A LazyFrame
#' @examples
#' ndjson_filename = tempfile()
#' jsonlite::stream_out(iris, file(ndjson_filename), verbose = FALSE)
#' pl$scan_ndjson(ndjson_filename)$collect()
pl$scan_ndjson = function(
    path,
    infer_schema_length = 100,
    batch_size = NULL,
    n_rows = NULL,
    low_memory = FALSE,
    rechunk = TRUE,
    row_count_name = NULL,
    row_count_offset = 0) {

  # capture all args and modify some to match lower level function
  args = as.list(environment())

  # single path and vector of paths are handled separately on the Rust side
  if (length(path) > 1) {
    args = append(args, list(paths = path), after = 1)
    args["path"] = list(NULL)
  } else {
    args[["path"]] = check_is_link(args[["path"]], reuse_downloaded = reuse_downloaded)
    args = append(args, list(paths = NULL), after = 1)
  }
  args[["reuse_downloaded"]] = NULL

  if (is.null(row_count_name) && !is.null(row_count_offset)) {
    args["row_count_offset"] = list(NULL)
  }

  ## call low level function with args
  check_no_missing_args(new_from_ndjson, args)
  unwrap(do.call(new_from_ndjson, args))
}

#' New DataFrame from NDJSON
#'
#' @description
#' Read a file from path into a polars DataFrame.
#' @name read_ndjson
#' @rdname IO_read_ndjson
#'
#' @param path Path to a file or URL. It is possible to provide multiple paths
#' provided that all NDJSON files have the same schema. It is not possible to
#' provide several URLs.
#' @param infer_schema_length Maximum number of rows to read to infer the column
#' types. If set to 0, all columns will be read as UTF-8. If `NULL`, a full
#' table scan will be done (slow).
#' @param batch_size Number of rows that will be processed per thread.
#' @param n_rows Maximum number of rows to read.
#' @param low_memory Reduce memory usage (will yield a lower performance).
#' @param rechunk Reallocate to contiguous memory when all chunks / files are
#' parsed.
#' @param row_count_name If not `NULL`, this will insert a row count column with
#' the given name into the DataFrame.
#' @param row_count_offset Offset to start the row_count column (only used if
#' the name is set).
#'
#' @return A DataFrame
#' @examples
#' ndjson_filename = tempfile()
#' jsonlite::stream_out(iris, file(ndjson_filename), verbose = FALSE)
#' pl$read_ndjson(ndjson_filename)
pl$read_ndjson = function(
    path,
    infer_schema_length = 100,
    batch_size = NULL,
    n_rows = NULL,
    low_memory = FALSE,
    rechunk = TRUE,
    row_count_name = NULL,
    row_count_offset = 0) {
  mc = match.call()
  mc[[1]] = get("pl", envir = asNamespace("polars"))$scan_ndjson
  eval.parent(mc)$collect()
}

