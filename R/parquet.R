#' Scan a parquet file
#'
#' @param file Path to a file. You can use globbing with `*` to scan/read multiple
#' files in the same directory (see examples).
#' @param n_rows Maximum number of rows to read.
#' @param cache Cache the result after reading.
#' @param parallel This determines the direction of parallelism. `"auto"` will
#' try to determine the optimal direction. Can be `"auto"`, `"none"`, `"columns"`,
#' or `"rowgroups"`,
#' @param rechunk In case of reading multiple files via a glob pattern, rechunk
#' the final DataFrame into contiguous memory chunks.
#' @param row_count_name If not `NULL`, this will insert a row count column with
#' the given name into the DataFrame.
#' @param row_count_offset Offset to start the row_count column (only used if
#' the name is set).
#' @param low_memory Reduce memory usage (will yield a lower performance).
#' @param hive_partitioning Infer statistics and schema from hive partitioned URL
#' and use them to prune reads.
#' @param use_statistics Use statistics in the parquet file to determine if pages
#' can be skipped from reading.
#'
#' @return LazyFrame
#' @name scan_parquet
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
pl$scan_parquet = function(
    file,
    n_rows = NULL,
    cache = TRUE,
    parallel = c(
      "Auto", # default
      "None",
      "Columns",
      "RowGroups"
    ),
    rechunk = TRUE,
    row_count_name = NULL,
    row_count_offset = 0L,
    low_memory = FALSE,
    use_statistics = TRUE,
    hive_partitioning = TRUE
  ) {

  new_from_parquet(
    path = file,
    n_rows = n_rows,
    cache = cache,
    parallel = parallel,
    rechunk = rechunk,
    row_name = row_count_name,
    row_count = row_count_offset,
    #storage_options = storage_options, # not supported yet
    low_memory = low_memory,
    use_statistics = use_statistics,
    hive_partitioning = hive_partitioning
  ) |>
    unwrap("in pl$scan_parquet(): ")
}

#' Read a parquet file
#' @rdname IO_read_parquet
#' @inheritParams scan_parquet
#' @return DataFrame
read_parquet = function( # remapped to pl$read_parquet, a hack to support roxygen2 @inheritsParams
  file,
  n_rows = NULL,
  cache = TRUE,
  parallel = c(
    "Auto", # default
    "None",
    "Columns",
    "RowGroups"
  ),
  rechunk = TRUE,
  row_count_name = NULL,
  row_count_offset = 0L,
  low_memory = FALSE,
  use_statistics = TRUE,
  hive_partitioning = TRUE) {

  args = as.list(environment())
  result({
    do.call(pl$scan_parquet, args)$collect()
  }) |>
    unwrap("in pl$read_parquet(): ")
}
pl$read_parquet = read_parquet
