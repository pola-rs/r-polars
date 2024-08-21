#' Scan a parquet file
#'
#' @inherit pl_scan_csv return
#' @inheritParams pl_scan_csv
#' @inheritParams pl_scan_ipc
#' @param source Path to a file. You can use globbing with `*` to scan/read multiple
#' files in the same directory (see examples).
#' @param cache Cache the result after reading.
#' @param parallel This determines the direction of parallelism. `"auto"` will
#' try to determine the optimal direction. Can be `"auto"`, `"columns"`,
#' `"row_groups"`, `"prefiltered"`, or `"none"`. See 'Details'.
#' @param rechunk In case of reading multiple files via a glob pattern, rechunk
#' the final DataFrame into contiguous memory chunks.
#' @param glob Expand path given via globbing rules.
#' @param use_statistics Use statistics in the parquet file to determine if pages
#' can be skipped from reading.
#' @param storage_options Experimental. List of options necessary to scan
#' parquet files from different cloud storage providers (GCP, AWS, Azure).
#' See the 'Details' section.
#'
#' @rdname IO_scan_parquet
#' @details
#' ## On parallel strategies
#'
#' The prefiltered strategy first evaluates the pushed-down predicates in
#' parallel and determines a mask of which rows to read. Then, it parallelizes
#' over both the columns and the row groups while filtering out rows that do not
#' need to be read. This can provide significant speedups for large files (i.e.
#' many row-groups) with a predicate that filters clustered rows or filters
#' heavily. In other cases, prefiltered may slow down the scan compared other
#' strategies.
#'
#' The prefiltered settings falls back to auto if no predicate is given.
#'
#'
#' ## Connecting to cloud providers
#'
#' Polars supports scanning parquet files from different cloud providers.
#' The cloud providers currently supported are AWS, GCP, and Azure.
#' The supported keys to pass to the `storage_options` argument can be found
#' here:
#'
#' - [aws](https://docs.rs/object_store/latest/object_store/aws/enum.AmazonS3ConfigKey.html)
#' - [gcp](https://docs.rs/object_store/latest/object_store/gcp/enum.GoogleConfigKey.html)
#' - [azure](https://docs.rs/object_store/latest/object_store/azure/enum.AzureConfigKey.html)
#'
#' ### Implementation details
#'
#' - Currently it is impossible to scan public parquet files from GCP without
#'   a valid service account. Be sure to always include a service account in the
#'   `storage_options` argument.
#'
#' @examplesIf requireNamespace("arrow", quietly = TRUE) && arrow::arrow_with_dataset() && arrow::arrow_with_parquet()
#' # Write a Parquet file than we can then import as DataFrame
#' temp_file = tempfile(fileext = ".parquet")
#' pl$DataFrame(mtcars)$write_parquet(temp_file)
#'
#' pl$scan_parquet(temp_file)$collect()
#' invisible(file.remove(temp_file))
#'
#' # Write a hive-style partitioned parquet dataset
#' temp_dir = tempdir()
#' arrow::write_dataset(
#'   mtcars,
#'   temp_dir,
#'   partitioning = c("cyl", "gear"),
#'   format = "parquet",
#'   hive_style = TRUE
#' )
#' list.files(temp_dir, recursive = TRUE)
#'
#' # If the path is a folder, Polars automatically tries to detect partitions
#' # and includes them in the output
#' pl$scan_parquet(temp_dir)$collect()
#'
#' # We can also impose a schema to the partition
#' pl$scan_parquet(temp_dir, hive_schema = list(cyl = pl$String, gear = pl$Int32))$collect()
pl_scan_parquet = function(
    source,
    ...,
    n_rows = NULL,
    row_index_name = NULL,
    row_index_offset = 0L,
    parallel = c(
      "auto",
      "columns",
      "row_groups",
      "none"
    ),
    hive_partitioning = NULL,
    hive_schema = NULL,
    try_parse_hive_dates = TRUE,
    glob = TRUE,
    rechunk = FALSE,
    low_memory = FALSE,
    storage_options = NULL,
    use_statistics = TRUE,
    cache = TRUE,
    include_file_paths = NULL) {
  new_from_parquet(
    path = source,
    n_rows = n_rows,
    cache = cache,
    parallel = parallel,
    rechunk = rechunk,
    row_name = row_index_name,
    row_index = row_index_offset,
    low_memory = low_memory,
    use_statistics = use_statistics,
    hive_partitioning = hive_partitioning,
    hive_schema = hive_schema,
    try_parse_hive_dates = try_parse_hive_dates,
    storage_options = storage_options,
    glob = glob,
    include_file_paths = include_file_paths
  ) |>
    unwrap("in pl$scan_parquet():")
}

#' Read a parquet file
#' @rdname IO_read_parquet
#' @inherit pl_read_csv return
#' @inherit pl_scan_parquet params details
#' @examplesIf requireNamespace("arrow", quietly = TRUE) && arrow::arrow_with_dataset() && arrow::arrow_with_parquet()
#' # Write a Parquet file than we can then import as DataFrame
#' temp_file = tempfile(fileext = ".parquet")
#' pl$DataFrame(mtcars)$write_parquet(temp_file)
#'
#' pl$read_parquet(temp_file)
#' invisible(file.remove(temp_file))
#'
#' # Write a hive-style partitioned Parquet dataset
#' temp_dir = tempdir()
#' arrow::write_dataset(
#'   mtcars,
#'   temp_dir,
#'   partitioning = c("cyl", "gear"),
#'   format = "parquet",
#'   hive_style = TRUE
#' )
#' list.files(temp_dir, recursive = TRUE)
#'
#' # If the path is a folder, Polars automatically tries to detect partitions
#' # and includes them in the output
#' pl$read_parquet(temp_dir)
#'
#' # We can also impose a schema to the partition
#' pl$read_parquet(temp_dir, hive_schema = list(cyl = pl$String, gear = pl$Int32))
pl_read_parquet = function(
    source,
    ...,
    n_rows = NULL,
    row_index_name = NULL,
    row_index_offset = 0L,
    parallel = c(
      "auto",
      "columns",
      "row_groups",
      "none"
    ),
    hive_partitioning = NULL,
    hive_schema = NULL,
    try_parse_hive_dates = TRUE,
    glob = TRUE,
    rechunk = TRUE,
    low_memory = FALSE,
    storage_options = NULL,
    use_statistics = TRUE,
    cache = TRUE,
    include_file_paths = NULL) {
  .args = as.list(environment())
  result({
    do.call(pl$scan_parquet, .args)$collect()
  }) |>
    unwrap("in pl$read_parquet():")
}
