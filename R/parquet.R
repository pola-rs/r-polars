#' new PolarsLazyFrame from parquet file
#' @keywords PolarsLazyFrame_new
#'
#' @param file string filepath
#' @param n_rows limit rows to scan
#' @param cache bool use cache
#' @param parallel String either Auto, None, Columns or RowGroups. The way to parralize the scan.
#' @param rechunk bool rechunk reorganize memory layout, potentially make future operations faster , however perform reallocation now.
#' @param row_count_name NULL or string, if a string add a rowcount column named by this string
#' @param row_count_offset integer, the rowcount column can be offst by this value
#' @param low_memory bool, try reduce memory footprint
#'
#' @return PolarsLazyFrame
#' @export
#'
#' @examples
#' # TODO write parquet example
scan_parquet = function(
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
    low_memory = FALSE # : bool = False,
    ) { #-> PolarsLazyFrame

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
    low_memory = low_memory
  )

  unwrap(result_lf)
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
