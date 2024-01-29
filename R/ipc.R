#' Import data in Apache Arrow IPC format
#'
#' @details Create new LazyFrame from Apache Arrow IPC file or stream
#' @keywords LazyFrame_new
#'
#' @inheritParams pl_scan_csv
#' @param memmap bool, mapped memory
#'
#' @return LazyFrame
#' @rdname IO_scan_ipc
pl_scan_ipc = function(
    path,
    n_rows = NULL,
    cache = TRUE,
    rechunk = TRUE,
    row_count_name = NULL,
    row_count_offset = 0L,
    memmap = TRUE) {
  result_lf = import_arrow_ipc(
    path,
    n_rows,
    cache,
    rechunk,
    row_count_name,
    row_count_offset,
    memmap
  )
  unwrap(result_lf, "in pl$scan_ipc:")
}
