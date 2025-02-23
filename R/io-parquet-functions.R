#' Lazily read from a local or cloud-hosted parquet file (or files)
#'
#' @inherit pl__scan_ipc description
#'
#' @inherit pl__LazyFrame return
#' @inheritParams rlang::args_dots_empty
#' @param source Path(s) to a file or directory. When needing to authenticate
#' for scanning cloud locations, see the `storage_options` parameter.
#' @param n_rows Stop reading from parquet file after reading `n_rows`.
#' @param row_index_name If not `NULL`, this will insert a row index column with
#' the given name into the DataFrame.
#' @param row_index_offset Offset to start the row index column (only used if
#' the name is set).
#' @param parallel This determines the direction and strategy of parallelism.
#' `"auto"` will try to determine the optimal direction. The `"prefiltered"`
#' strategy first evaluates the pushed-down predicates in parallel and
#' determines a mask of which rows to read. Then, it parallelizes over both the
#' columns and the row groups while filtering out rows that do not need to be
#' read. This can provide significant speedups for large files (i.e. many
#' row-groups) with a predicate that filters clustered rows or filters heavily.
#' In other cases, prefiltered may slow down the scan compared other strategies.
#'
#' The prefiltered settings falls back to auto if no predicate is given.
#' @param use_statistics Use statistics in the parquet to determine if pages
#' can be skipped from reading.
#' @param hive_partitioning Infer statistics and schema from Hive partitioned
#' sources and use them to prune reads.
#' @param glob Expand path given via globbing rules.
#' @param schema Specify the datatypes of the columns. The datatypes must match
#' the datatypes in the file(s). If there are extra columns that are not in the
#' file(s), consider also enabling `allow_missing_columns`.
#' @param hive_schema The column names and data types of the columns by which
#' the data is partitioned. If `NULL` (default), the schema of the hive
#' partitions is inferred.
#' @param try_parse_hive_dates Whether to try parsing hive values as date /
#' datetime types.
#' @param rechunk In case of reading multiple files via a glob pattern rechunk
#' the final DataFrame into contiguous memory chunks.
#' @param low_memory Reduce memory pressure at the expense of performance
#' @param cache Cache the result after reading.
#' @param storage_options Named vector containing options that indicate how to
#' connect to a cloud provider. The cloud providers currently supported are
#' AWS, GCP, and Azure.
#' See supported keys here:
#' * [aws](https://docs.rs/object_store/latest/object_store/aws/enum.AmazonS3ConfigKey.html)
#' * [gcp](https://docs.rs/object_store/latest/object_store/gcp/enum.GoogleConfigKey.html)
#' * [azure](https://docs.rs/object_store/latest/object_store/azure/enum.AzureConfigKey.html)
#' * Hugging Face (`hf://`): Accepts an API key under the token parameter
#'   `c(token = YOUR_TOKEN)` or by setting the `HF_TOKEN` environment
#'   variable.
#'
#' If `storage_options` is not provided, Polars will try to infer the
#' information from environment variables.
#' @param retries Number of retries if accessing a cloud instance fails.
#' @param include_file_paths Character value indicating the column name that
#' will include the path of the source file(s).
#' @param allow_missing_columns When reading a list of parquet files, if a
#' column existing in the first file cannot be found in subsequent files, the
#' default behavior is to raise an error. However, if `allow_missing_columns`
#' is set to `TRUE`, a full-NULL column is returned instead of erroring for the
#' files that do not contain the column.
# TODO-REWRITE: uncomment when write_parquet() is implemented
# @examplesIf requireNamespace("withr", quietly = TRUE)
# # Write a Parquet file than we can then import as DataFrame
# temp_file <- withr::local_tempfile(fileext = ".parquet")
# as_polars_df(mtcars)$write_parquet(temp_file)
# pl$scan_parquet(temp_file)$collect()
# # Write a hive-style partitioned parquet dataset
# temp_dir <- withr::local_tempdir()
# as_polars_df(mtcars)$write_parquet(temp_dir, partition_by = c("cyl", "gear"))
# list.files(temp_dir, recursive = TRUE)
# # If the path is a folder, Polars automatically tries to detect partitions
# # and includes them in the output
# pl$scan_parquet(temp_dir)$collect()
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
# TODO-REWRITE: uncomment when write_parquet() is implemented
# @examplesIf requireNamespace("withr", quietly = TRUE)
# # Write a Parquet file than we can then import as DataFrame
# temp_file <- withr::local_tempfile(fileext = ".parquet")
# as_polars_df(mtcars)$write_parquet(temp_file)
# pl$read_parquet(temp_file)
# # Write a hive-style partitioned parquet dataset
# temp_dir <- withr::local_tempdir()
# as_polars_df(mtcars)$write_parquet(temp_dir, partition_by = c("cyl", "gear"))
# list.files(temp_dir, recursive = TRUE)
# # If the path is a folder, Polars automatically tries to detect partitions
# # and includes them in the output
# pl$read_parquet(temp_dir)
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
