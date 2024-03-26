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
    source,
    ...,
    n_rows = NULL,
    cache = TRUE,
    rechunk = TRUE,
    row_index_name = NULL,
    row_index_offset = 0L,
    memmap = TRUE) {
  import_arrow_ipc(
    source,
    n_rows,
    cache,
    rechunk,
    row_index_name,
    row_index_offset,
    memmap
  ) |>
    unwrap("in pl$scan_ipc:")
}
