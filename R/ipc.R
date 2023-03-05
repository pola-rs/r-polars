#' Scan Apache Arrow IPC
#'
#' Create new LazyFrame from Apache Arrow IPC file or stream
#' @keywords LazyFrame_new
#'
#' @param path string, path
#' @param n_rows integer, limit rows to scan
#' @param cache bool, use cache
#' @param rechunk bool, rechunk reorganize memory layout, potentially make future operations faster, however perform reallocation now.
#' @param row_count_name NULL or string, if a string add a rowcount column named by this string
#' @param row_count_offset integer, the rowcount column can be offst by this value
#' @param memmap bool, mapped memory
#'
#' @return LazyFrame
#' @export
#'
scan_ipc = function(
    path, #: str | Path,
    n_rows = NULL, #: int | None = None,
    cache = TRUE, #: bool = True,
    rechunk = TRUE, #: bool = True,
    row_count_name = NULL, #: str | None = None,
    row_count_offset = 0L, #: int = 0,
    memmap = TRUE #: bool = False,
) {#-> LazyFrame


  result_lf = new_from_ipc(
    path,
    n_rows,
    cache,
    rechunk,
    row_count_name,
    row_count_offset,
    memmap
  )

  unwrap(result_lf)

}
