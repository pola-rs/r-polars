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
#' @rdname IO_scan_parquet
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
    cloud_options = NULL,
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
    cloud_options = cloud_options
  ) |>
    unwrap("in pl$scan_parquet():")
}

#' Read a parquet file
#' @rdname IO_read_parquet
#' @inherit pl_read_csv return
#' @inheritParams pl_scan_parquet
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
    use_statistics = TRUE,
    cache = TRUE) {
  .args = as.list(environment())
  result({
    do.call(pl$scan_parquet, .args)$collect()
  }) |>
    unwrap("in pl$read_parquet():")
}
