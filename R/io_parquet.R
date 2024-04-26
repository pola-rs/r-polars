#' Scan a parquet file
#'
#' @inherit pl_scan_csv return
#' @inheritParams pl_scan_csv
#' @param source Path to a file. You can use globbing with `*` to scan/read multiple
#' files in the same directory (see examples).
#' @param cache Cache the result after reading.
#' @param parallel This determines the direction of parallelism. `"auto"` will
#' try to determine the optimal direction. Can be `"auto"`, `"columns"`,
#' `"row_groups"`, or `"none"`.
#' @param rechunk In case of reading multiple files via a glob pattern, rechunk
#' the final DataFrame into contiguous memory chunks.
#' @param hive_partitioning Infer statistics and schema from hive partitioned URL
#' and use them to prune reads.
#' @param use_statistics Use statistics in the parquet file to determine if pages
#' can be skipped from reading.
#' @param storage_options Experimental. List of options necessary to scan
#' parquet files from different cloud storage providers (GCP, AWS, Azure).
#' See the 'Details' section.
#' @rdname IO_scan_parquet
#' @details
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
#' temp_dir = tempfile()
#' # Write a hive-style partitioned parquet dataset
#' arrow::write_dataset(
#'   mtcars,
#'   temp_dir,
#'   partitioning = c("cyl", "gear"),
#'   format = "parquet",
#'   hive_style = TRUE
#' )
#' list.files(temp_dir, recursive = TRUE)
#'
#' # Read the dataset
#' pl$scan_parquet(
#'   file.path(temp_dir, "**/*.parquet")
#' )$collect()
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
    hive_partitioning = TRUE,
    rechunk = FALSE,
    low_memory = FALSE,
    storage_options = NULL,
    use_statistics = TRUE,
    cache = TRUE) {
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
    storage_options = storage_options
  ) |>
    unwrap("in pl$scan_parquet():")
}

#' Read a parquet file
#' @rdname IO_read_parquet
#' @inherit pl_read_csv return
#' @inherit pl_scan_parquet params details
#' @examplesIf requireNamespace("arrow", quietly = TRUE) && arrow::arrow_with_dataset() && arrow::arrow_with_parquet()
#' temp_dir = tempfile()
#' # Write a hive-style partitioned parquet dataset
#' arrow::write_dataset(
#'   mtcars,
#'   temp_dir,
#'   partitioning = c("cyl", "gear"),
#'   format = "parquet",
#'   hive_style = TRUE
#' )
#' list.files(temp_dir, recursive = TRUE)
#'
#' # Read the dataset
#' pl$read_parquet(
#'   file.path(temp_dir, "**/*.parquet")
#' )
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
    hive_partitioning = TRUE,
    rechunk = TRUE,
    low_memory = FALSE,
    storage_options = NULL,
    use_statistics = TRUE,
    cache = TRUE) {
  .args = as.list(environment())
  result({
    do.call(pl$scan_parquet, .args)$collect()
  }) |>
    unwrap("in pl$read_parquet():")
}
