#' Import data in Apache Arrow IPC format
#'
#' @details Create new LazyFrame from Apache Arrow IPC file or stream
#' @keywords LazyFrame_new
#'
#' @inheritParams pl_scan_csv
#' @param memory_map A logical. If `TRUE`, try to memory map the file.
#' This can greatly improve performance on repeated queries as the OS may cache pages.
#' Only uncompressed Arrow IPC files can be memory mapped.
#'
#' @return LazyFrame
#' @rdname IO_scan_ipc
pl_scan_ipc = function(
    source,
    ...,
    n_rows = NULL,
    cache = TRUE,
    rechunk = FALSE,
    row_index_name = NULL,
    row_index_offset = 0L,
    memory_map = TRUE) {
  import_arrow_ipc(
    source,
    n_rows,
    cache,
    rechunk,
    row_index_name,
    row_index_offset,
    memory_map
  ) |>
    unwrap("in pl$scan_ipc:")
}
