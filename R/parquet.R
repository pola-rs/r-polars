#' Scan a parquet file
#' @keywords LazyFrame_new
#'
#' @param file string filepath
#' @param n_rows limit rows to scan
#' @param cache Boolean use cache
#' @param parallel String either Auto, None, Columns or RowGroups. The way to parallelized the scan.
#' @param rechunk Boolean rechunk reorganize memory layout, potentially make future operations faster , however perform reallocation now.
#' @param row_count_name NULL or string, if a string add a rowcount column named by this string
#' @param row_count_offset integer, the rowcount column can be offset by this value
#' @param low_memory Boolean, try reduce memory footprint
#' @param hive_partitioning Infer statistics and schema from hive partitioned URL
#' and use them to prune reads.
#' @param use_statistics Boolean, if TRUE use statistics in the parquet to determine if pages can be
#'  skipped from reading.
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
  ) { #-> LazyFrame

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
