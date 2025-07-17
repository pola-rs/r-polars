# Input Parquet functions: scan_parquet, read_parquet

#' Lazily read from a local or cloud-hosted parquet file (or files)
#'
#' @inherit pl__scan_ipc description
#'
#' @inherit pl__LazyFrame return
#' @inheritParams pl__scan_ipc
#' @param parallel This determines the direction and strategy of parallelism.
#'   - `"auto"` (default): Will try to determine the optimal direction.
#'   - `"prefiltered"`: `r lifecycle::badge("experimental")`
#'     Strategy first evaluates the pushed-down predicates in parallel and
#'     determines a mask of which rows to read. Then, it parallelizes over both the
#'     columns and the row groups while filtering out rows that do not need to be
#'     read. This can provide significant speedups for large files (i.e. many
#'     row-groups) with a predicate that filters clustered rows or filters heavily.
#'     In other cases, prefiltered may slow down the scan compared other strategies.
#'     Falls back to `"auto"` if no predicate is given.
#'   - `"columns"`, `"row_groups"`: Use the specified direction.
#'   - `"none"`: No parallelism.
#' @param use_statistics Use statistics in the parquet to determine if pages
#' can be skipped from reading.
#' @param glob Expand path given via globbing rules.
#' @param schema `r lifecycle::badge("experimental")`
#'   Named list of [datatypes][DataType] of the columns. The datatypes must match
#'   the datatypes in the file(s). If there are extra columns that are not in the
#'   file(s), consider also enabling `allow_missing_columns`.
#' @param low_memory Reduce memory pressure at the expense of performance
#' @param allow_missing_columns When reading a list of parquet files, if a
#' column existing in the first file cannot be found in subsequent files, the
#' default behavior is to raise an error. However, if `allow_missing_columns`
#' is set to `TRUE`, a full-NULL column is returned instead of erroring for the
#' files that do not contain the column.
#' @examplesIf requireNamespace("withr", quietly = TRUE)
#' # Write a Parquet file than we can then import as DataFrame
#' temp_file <- withr::local_tempfile(fileext = ".parquet")
#' as_polars_df(mtcars)$write_parquet(temp_file)
#' pl$scan_parquet(temp_file)$collect()
#'
#' # Write a hive-style partitioned parquet dataset
#' temp_dir <- withr::local_tempdir()
#' as_polars_df(mtcars)$write_parquet(temp_dir, partition_by = c("cyl", "gear"))
#' list.files(temp_dir, recursive = TRUE)
#'
#' # If the path is a folder, Polars automatically tries to detect partitions
#' # and includes them in the output
#' pl$scan_parquet(temp_dir)$collect()
pl__scan_parquet <- function(
  source,
  ...,
  n_rows = NULL,
  row_index_name = NULL,
  row_index_offset = 0L,
  parallel = c("auto", "columns", "row_groups", "prefiltered", "none"),
  use_statistics = TRUE,
  hive_partitioning = NULL,
  glob = TRUE,
  schema = NULL,
  hive_schema = NULL,
  try_parse_hive_dates = TRUE,
  rechunk = FALSE,
  low_memory = FALSE,
  cache = TRUE,
  storage_options = NULL,
  retries = 2,
  include_file_paths = NULL,
  allow_missing_columns = FALSE
) {
  check_dots_empty0(...)
  check_character(source, allow_na = FALSE)
  if (length(source) == 0) {
    abort("`source` must have length > 0.")
  }
  parallel <- arg_match0(
    parallel,
    values = c("auto", "columns", "row_groups", "prefiltered", "none")
  )
  check_list_of_polars_dtype(schema, allow_null = TRUE)
  check_list_of_polars_dtype(hive_schema, allow_null = TRUE)

  if (!is.null(hive_schema)) {
    hive_schema <- parse_into_list_of_datatypes(!!!hive_schema)
  }

  PlRLazyFrame$new_from_parquet(
    source,
    n_rows = n_rows,
    row_index_name = row_index_name,
    row_index_offset = row_index_offset,
    parallel = parallel,
    use_statistics = use_statistics,
    hive_partitioning = hive_partitioning,
    glob = glob,
    schema = schema,
    hive_schema = hive_schema,
    try_parse_hive_dates = try_parse_hive_dates,
    rechunk = rechunk,
    low_memory = low_memory,
    cache = cache,
    storage_options = storage_options,
    retries = retries,
    include_file_paths = include_file_paths,
    allow_missing_columns = allow_missing_columns
  ) |>
    wrap()
}


#' Read into a DataFrame from Parquet file
#'
#' @inherit pl__DataFrame return
#' @inheritParams pl__scan_parquet
#' @examplesIf requireNamespace("withr", quietly = TRUE)
#' # Write a Parquet file than we can then import as DataFrame
#' temp_file <- withr::local_tempfile(fileext = ".parquet")
#' as_polars_df(mtcars)$write_parquet(temp_file)
#' pl$read_parquet(temp_file)
#'
#' # Write a hive-style partitioned parquet dataset
#' temp_dir <- withr::local_tempdir()
#' as_polars_df(mtcars)$write_parquet(temp_dir, partition_by = c("cyl", "gear"))
#' list.files(temp_dir, recursive = TRUE)
#'
#' # If the path is a folder, Polars automatically tries to detect partitions
#' # and includes them in the output
#' pl$read_parquet(temp_dir)
pl__read_parquet <- function(
  source,
  ...,
  n_rows = NULL,
  row_index_name = NULL,
  row_index_offset = 0L,
  parallel = c("auto", "columns", "row_groups", "prefiltered", "none"),
  use_statistics = TRUE,
  hive_partitioning = NULL,
  glob = TRUE,
  schema = NULL,
  hive_schema = NULL,
  try_parse_hive_dates = TRUE,
  rechunk = FALSE,
  low_memory = FALSE,
  cache = TRUE,
  storage_options = NULL,
  retries = 2,
  include_file_paths = NULL,
  allow_missing_columns = FALSE
) {
  check_dots_empty0(...)
  .args <- as.list(environment())
  do.call(pl__scan_parquet, .args)$collect() |>
    wrap()
}
