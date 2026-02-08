# Input (ND)JSON functions: scan_json, scan_ndjson, read_json, read_ndjson

#' Lazily read from a local or cloud-hosted NDJSON file(s)
#'
#' @inherit pl__scan_ipc description
#' @inherit as_polars_lf return
#' @inheritParams pl__scan_csv
#' @param batch_size Number of rows to read in each batch.
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
  retries = deprecated(),
  file_cache_ttl = deprecated(),
  include_file_paths = NULL
) {
  check_dots_empty0(...)
  check_character(source, allow_na = FALSE)
  if (length(source) == 0) {
    abort("`source` must have length > 0.")
  }
  check_list_of_polars_dtype(schema, allow_null = TRUE)
  check_list_of_polars_dtype(schema_overrides, allow_null = TRUE)

  if (is_present(retries)) {
    deprecate_warn(
      c(
        `!` = sprintf(
          "The %s argument is deprecated as of %s 1.9.0.",
          format_arg("retries"),
          format_pkg("polars")
        ),
        i = sprintf(
          "Specify %s in %s instead.",
          format_code("max_retries"),
          format_arg("storage_options")
        )
      )
    )
    storage_options <- storage_options %||% character()
    storage_options[["max_retries"]] <- as.character(retries)
  }

  if (is_present(file_cache_ttl)) {
    deprecate_warn(
      c(
        `!` = sprintf(
          "The %s argument is deprecated as of %s 1.9.0.",
          format_arg("file_cache_ttl"),
          format_pkg("polars")
        ),
        i = sprintf(
          "Specify %s in %s instead.",
          format_code("file_cache_ttl"),
          format_arg("storage_options")
        )
      )
    )
    storage_options <- storage_options %||% character()
    storage_options[["file_cache_ttl"]] <- as.character(file_cache_ttl)
  }

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
    include_file_paths = include_file_paths
  ) |>
    wrap()
}

#' Read into a DataFrame from NDJSON file
#'
#' @inherit as_polars_df return
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
  retries = deprecated(),
  file_cache_ttl = deprecated(),
  include_file_paths = NULL
) {
  check_dots_empty0(...)
  .args <- as.list(environment())
  do.call(pl__scan_ndjson, .args)$collect() |>
    wrap()
}
