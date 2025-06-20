# Input IPC functions: scan_ipc, read_ipc, read_ipc_stream

# TODO: swap param inheritance with pl__scan_parquet
#' Lazily read from an Arrow IPC (Feather v2) file or multiple files via glob
#' patterns
#'
#' This allows the query optimizer to push down predicates and projections to
#' the scan level, thereby potentially reducing memory overhead.
#'
#' @inherit pl__LazyFrame return
#' @inheritParams rlang::args_dots_empty
#' @inheritParams pl__scan_parquet
#' @inheritParams pl__scan_csv
#' @param hive_partitioning Infer statistics and schema from Hive partitioned
#' sources and use them to prune reads. If `NULL` (default), it is automatically
#' enabled when a single directory is passed, and otherwise disabled.
#' @param hive_schema A list containing the column names and data types of the
#' columns by which the data is partitioned, e.g.
#' `list(a = pl$String, b = pl$Float32)`. If `NULL` (default), the schema of
#' the Hive partitions is inferred.
#' @param try_parse_hive_dates Whether to try parsing hive values as date /
#' datetime types.
#' @param include_file_paths Character value indicating the column name that
#' will include the path of the source file(s).
#' @examplesIf requireNamespace("arrow", quietly = TRUE) && arrow::arrow_with_dataset()
#' temp_dir <- tempfile()
#' # Write a hive-style partitioned arrow file dataset
#' arrow::write_dataset(
#'   mtcars,
#'   temp_dir,
#'   partitioning = c("cyl", "gear"),
#'   format = "arrow",
#'   hive_style = TRUE
#' )
#' list.files(temp_dir, recursive = TRUE)
#'
#' # If the path is a folder, Polars automatically tries to detect partitions
#' # and includes them in the output
#' pl$scan_ipc(temp_dir)$collect()
#'
#' # We can also impose a schema to the partition
#' pl$scan_ipc(temp_dir, hive_schema = list(cyl = pl$String, gear = pl$Int32))$collect()
pl__scan_ipc <- function(
  source,
  ...,
  n_rows = NULL,
  cache = TRUE,
  rechunk = FALSE,
  row_index_name = NULL,
  row_index_offset = 0L,
  storage_options = NULL,
  retries = 2,
  file_cache_ttl = NULL,
  hive_partitioning = NULL,
  hive_schema = NULL,
  try_parse_hive_dates = TRUE,
  include_file_paths = NULL
) {
  check_dots_empty0(...)
  check_character(source, allow_na = FALSE)
  if (length(source) == 0) {
    abort("`source` must have length > 0.")
  }
  check_list_of_polars_dtype(hive_schema, allow_null = TRUE)

  if (!is.null(hive_schema)) {
    hive_schema <- parse_into_list_of_datatypes(!!!hive_schema)
  }

  PlRLazyFrame$new_from_ipc(
    source = source,
    n_rows = n_rows,
    cache = cache,
    rechunk = rechunk,
    retries = retries,
    file_cache_ttl = file_cache_ttl,
    storage_options = storage_options,
    row_index_name = row_index_name,
    row_index_offset = row_index_offset,
    hive_partitioning = hive_partitioning,
    hive_schema = hive_schema,
    try_parse_hive_dates = try_parse_hive_dates,
    include_file_paths = include_file_paths
  ) |>
    wrap()
}


#' Read into a DataFrame from Arrow IPC (Feather v2) file
#'
#' @inherit pl__DataFrame return
#' @inheritParams pl__scan_ipc
#' @examplesIf requireNamespace("arrow", quietly = TRUE) && arrow::arrow_with_dataset()
#' temp_dir <- tempfile()
#' # Write a hive-style partitioned arrow file dataset
#' arrow::write_dataset(
#'   mtcars,
#'   temp_dir,
#'   partitioning = c("cyl", "gear"),
#'   format = "arrow",
#'   hive_style = TRUE
#' )
#' list.files(temp_dir, recursive = TRUE)
#'
#' # If the path is a folder, Polars automatically tries to detect partitions
#' # and includes them in the output
#' pl$read_ipc(temp_dir)
#'
#' # We can also impose a schema to the partition
#' pl$read_ipc(temp_dir, hive_schema = list(cyl = pl$String, gear = pl$Int32))
pl__read_ipc <- function(
  source,
  ...,
  n_rows = NULL,
  cache = TRUE,
  rechunk = FALSE,
  row_index_name = NULL,
  row_index_offset = 0L,
  storage_options = NULL,
  retries = 2,
  file_cache_ttl = NULL,
  hive_partitioning = NULL,
  hive_schema = NULL,
  try_parse_hive_dates = TRUE,
  include_file_paths = NULL
) {
  check_dots_empty0(...)
  .args <- as.list(environment())
  do.call(pl__scan_ipc, .args)$collect() |>
    wrap()
}

# TODO: read raw vector
# TODO: Allow integer-ish columns
# TODO: rechunk's default value is different from the other read functions
#' Read into a DataFrame from Arrow IPC stream format
#'
#' @inherit pl__DataFrame return
#' @inheritParams pl__scan_ipc
#' @param source A character of the path to an Arrow IPC stream file.
#' @param columns A character vector of column names to read.
#' @param rechunk A logical value to indicate whether to make sure that all data is contiguous.
#' @examplesIf requireNamespace("nanoarrow", quietly = TRUE)
#' temp_file <- tempfile(fileext = ".arrows")
#'
#' mtcars |>
#'   nanoarrow::write_nanoarrow(temp_file)
#'
#' pl$read_ipc_stream(temp_file, columns = c("cyl", "am"))
pl__read_ipc_stream <- function(
  source,
  ...,
  columns = NULL,
  n_rows = NULL,
  row_index_name = NULL,
  row_index_offset = 0L,
  rechunk = TRUE
) {
  check_dots_empty0(...)
  check_character(columns, allow_na = FALSE, allow_null = TRUE)

  PlRDataFrame$read_ipc_stream(
    source = source,
    columns = columns,
    n_rows = n_rows,
    row_index_name = row_index_name,
    row_index_offset = row_index_offset,
    rechunk = rechunk
  ) |>
    wrap()
}
