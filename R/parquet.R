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
#'
#' @return LazyFrame
#' @name scan_parquet
#' @rdname IO_scan_parquet
#' @examples
#' #write example file
#' my_parquet = tempfile(fileext = ".parquet")
#' pl$LazyFrame(mtcars)$sink_parquet(my_parquet)
#'
#' # scan and get (project) only one column "cyl" but filter (apply predicate) on "hp".
#' lf = pl$scan_parquet(my_parquet)$
#'   filter(pl$col("hp") > 250)$
#'   select(pl$col("cyl") * 2)
#'
#' # LayFrame with a logical plan (query)
#' print(lf)
#'
#' # see optimized plan
#' lf$describe_optimized_plan()
#'
#' # Execute and get result DataFrame
#' lf$collect()
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
    low_memory = FALSE # : bool = False,
    ) { #-> LazyFrame

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
#' @examples
#' # read parquet directly to DataFrame
#' pl$LazyFrame(mtcars)$sink_parquet(my_parquet)
#' df = pl$read_parquet(my_parquet)
#'
#' print(df)
pl$read_parquet = function(
    file,
    n_rows = NULL,
    cache = TRUE,
    parallel = c("Auto", "None", "Columns", "RowGroups"),
    rechunk = TRUE,
    row_count_name = NULL,
    row_count_offset = 0L,
    low_memory = FALSE) {

  #construct a derived call
  mc = match.call()
  mc[[1]] = quote(pl$scan_parquet)

  # eval call, and add to error context
  mod_err_ctx = \(res) result(res) |> unwrap("in pl$read_parquet():")
  lf = eval.parent(mc) |> mod_err_ctx()
  lf$collect() |> mod_err_ctx()

  # alternative style #1
  # lf = pl$scan_parquet(...) |> mod_err_ctx()
  # lf$collect() |> mod_err_ctx()

  # alternative style #2
  # pl$scan_parquet(...) |>
  #  result() |>
  #  and_then(\(lf) lf$collect()) |>
  #  unwrap("in pl$read_parquet():")

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
