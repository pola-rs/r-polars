#' Scan a parquet file
#' @keywords LazyFrame_new
#'
#' @param file string filepath
#' @param n_rows limit rows to scan
#' @param cache bool use cache
#' @param parallel String either Auto, None, Columns or RowGroups. The way to parallelized the scan.
#' @param rechunk bool rechunk reorganize memory layout, potentially make future operations faster , however perform reallocation now.
#' @param row_count_name NULL or string, if a string add a rowcount column named by this string
#' @param row_count_offset integer, the rowcount column can be offset by this value
#' @param low_memory bool, try reduce memory footprint
#' @param hive_partitioning Infer statistics and schema from hive partitioned URL
#' and use them to prune reads.
#'
#' @return LazyFrame
#' @name scan_parquet
#' @rdname IO_scan_parquet
#' @examples
#' # TODO write parquet example
pl$scan_parquet = function(
    file, # : str | Path,
    n_rows = NULL, # : int | None = None,
    cache = TRUE, # : bool = True,
    parallel = c(
      "Auto", # default
      "None",
      "Columns", # Parallelize over the row groups
      "RowGroups" # Parallelize over the columns
    ), # Automatically determine over which unit to parallelize, This will choose the most occurring unit.
    rechunk = TRUE, # : bool = True,
    row_count_name = NULL, # : str | None = None,
    row_count_offset = 0L, # : int = 0,
    # storage_options,#: dict[str, object] | None = None, #seems fsspec specific
    low_memory = FALSE, # : bool = False,
    hive_partitioning = TRUE) { #-> LazyFrame

  parallel = parallel[1L]
  if (!parallel %in% c("None", "Columns", "RowGroups", "Auto")) {
    stopf("unknown parallel strategy")
  }

  result_lf = new_from_parquet(
    path = file,
    n_rows = n_rows,
    cache = cache,
    parallel = parallel,
    rechunk = rechunk,
    row_name = row_count_name,
    row_count = row_count_offset,
    low_memory = low_memory,
    hive_partitioning = hive_partitioning
  )

  unwrap(result_lf)
}


#' Read a parquet file
#' @rdname IO_read_parquet
#' @param file string filepath
#' @param n_rows limit rows to scan
#' @param cache bool use cache
#' @param parallel String either Auto, None, Columns or RowGroups. The way to parallelized the scan.
#' @param rechunk bool rechunk reorganize memory layout, potentially make future operations faster , however perform reallocation now.
#' @param row_count_name NULL or string, if a string add a rowcount column named by this string
#' @param row_count_offset integer, the rowcount column can be offset by this value
#' @param low_memory bool, try reduce memory footprint
#' @return DataFrame
#' @name read_parquet
pl$read_parquet = function(
    file,
    n_rows = NULL,
    cache = TRUE,
    parallel = c("Auto", "None", "Columns", "RowGroups"),
    rechunk = TRUE,
    row_count_name = NULL,
    row_count_offset = 0L,
    low_memory = FALSE) {
  mc = match.call()
  mc[[1]] = quote(pl$scan_parquet)
  eval.parent(mc)$collect()
}


#
# def _prepare_row_count_args(
#   row_count_name: str | None = None,
#   row_count_offset: int = 0,
# ) -> tuple[str, int] | None:
#   if row_count_name is not None:
#   return (row_count_name, row_count_offset)
# else:
#   return None
