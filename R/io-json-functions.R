#' Lazily read from a local or cloud-hosted NDJSON file(s)
#'
#' @inherit pl__scan_ipc description
#'
#' @inherit pl__LazyFrame return
#' @inheritParams rlang::args_dots_empty
#' @inheritParams pl__scan_parquet
#' @inheritParams pl__scan_csv
#'
#' @examplesIf requireNamespace("jsonlite", quietly = TRUE)
#' ndjson_filename <- tempfile()
#' jsonlite::stream_out(iris, file(ndjson_filename), verbose = FALSE)
#' pl$scan_ndjson(ndjson_filename)$collect()
pl__scan_ndjson <- function(
    source,
    ...,
    schema = NULL,
    schema_overrides = NULL,
    infer_schema_length = 100,
    batch_size = 1024,
    n_rows = NULL,
    low_memory = FALSE,
    rechunk = FALSE,
    row_index_name = NULL,
    row_index_offset = 0L,
    ignore_errors = FALSE,
    storage_options = NULL,
    retries = 2,
    file_cache_ttl = NULL,
    include_file_paths = NULL) {
  check_dots_empty0(...)
  check_character(source, allow_na = FALSE)
  if (length(source) == 0) {
    abort("`source` must have length > 0.")
  }
  check_list_of_polars_dtype(schema, allow_null = TRUE)
  check_list_of_polars_dtype(schema_overrides, allow_null = TRUE)

  if (!is.null(schema)) {
    schema <- parse_into_list_of_datatypes(!!!schema)
  }
  schema_overrides <- parse_into_list_of_datatypes(!!!schema_overrides)

  PlRLazyFrame$new_from_ndjson(
    source = source,
    schema = schema,
    schema_overrides = schema_overrides,
    infer_schema_length = infer_schema_length,
    batch_size = batch_size,
    n_rows = n_rows,
    low_memory = low_memory,
    rechunk = rechunk,
    row_index_name = row_index_name,
    row_index_offset = row_index_offset,
    ignore_errors = ignore_errors,
    storage_options = storage_options,
    retries = retries,
    file_cache_ttl = file_cache_ttl,
    include_file_paths = include_file_paths
  ) |>
    wrap()
}

#' Read into a DataFrame from NDJSON file
#'
#' @inherit pl__DataFrame return
#' @inheritParams pl__scan_ndjson
#' @examplesIf requireNamespace("jsonlite", quietly = TRUE)
#' ndjson_filename <- tempfile()
#' jsonlite::stream_out(iris, file(ndjson_filename), verbose = FALSE)
#' pl$read_ndjson(ndjson_filename)
pl__read_ndjson <- function(
    source,
    ...,
    schema = NULL,
    schema_overrides = NULL,
    infer_schema_length = 100,
    batch_size = 1024,
    n_rows = NULL,
    low_memory = FALSE,
    rechunk = FALSE,
    row_index_name = NULL,
    row_index_offset = 0L,
    ignore_errors = FALSE,
    storage_options = NULL,
    retries = 2,
    file_cache_ttl = NULL,
    include_file_paths = NULL) {
  check_dots_empty0(...)
  .args <- as.list(environment())
  do.call(pl__scan_ndjson, .args)$collect() |>
    wrap()
}
