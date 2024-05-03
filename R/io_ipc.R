#' Lazily read from an Arrow IPC (Feather v2) file or multiple files via glob patterns
#'
#' This allows the query optimizer to push down predicates and projections to the scan level,
#' thereby potentially reducing memory overhead.
#'
#' Hive-style partitioning is not supported yet.
#' @inherit pl_scan_csv return
#' @inheritParams pl_scan_parquet
#' @param memory_map A logical. If `TRUE`, try to memory map the file.
#' This can greatly improve performance on repeated queries as the OS may cache pages.
#' Only uncompressed Arrow IPC files can be memory mapped.
#' @rdname IO_scan_ipc
#' @examplesIf requireNamespace("arrow", quietly = TRUE) && arrow::arrow_with_dataset()
#' temp_dir = tempfile()
#' # Write a hive-style partitioned arrow file dataset
#' arrow::write_dataset(
#'   mtcars,
#'   temp_dir,
#'   partitioning = c("cyl", "gear"),
#'   format = "arrow",
#'   hive_style = TRUE
#' )
#' list.files(temp_dir, recursive = TRUE)
#'
#' # Read the dataset
#' # Sinse hive-style partitioning is not supported,
#' # the `cyl` and `gear` columns are not contained in the result
#' pl$scan_ipc(
#'   file.path(temp_dir, "**/*.arrow")
#' )$collect()
pl_scan_ipc = function(
    source,
    ...,
    n_rows = NULL,
    memory_map = TRUE,
    row_index_name = NULL,
    row_index_offset = 0L,
    rechunk = FALSE,
    cache = TRUE) {
  import_arrow_ipc(
    source,
    n_rows,
    cache,
    rechunk,
    row_index_name,
    row_index_offset,
    memory_map
  ) |>
    unwrap("in pl$scan_ipc():")
}


#' Read into a DataFrame from Arrow IPC (Feather v2) file
#'
#' @inherit pl_read_csv return
#' @inheritParams pl_scan_ipc
#' @param source A single character or a raw vector of Apache Arrow IPC file.
#' You can use globbing with `*` to scan/read multiple files in the same directory
#' (see examples).
#' @rdname IO_read_ipc
#' @examplesIf requireNamespace("arrow", quietly = TRUE) && arrow::arrow_with_dataset()
#' temp_dir = tempfile()
#' # Write a hive-style partitioned arrow file dataset
#' arrow::write_dataset(
#'   mtcars,
#'   temp_dir,
#'   partitioning = c("cyl", "gear"),
#'   format = "arrow",
#'   hive_style = TRUE
#' )
#' list.files(temp_dir, recursive = TRUE)
#'
#' # Read the dataset
#' # Sinse hive-style partitioning is not supported,
#' # the `cyl` and `gear` columns are not contained in the result
#' pl$read_ipc(
#'   file.path(temp_dir, "**/*.arrow")
#' )
#'
#' # Read a raw vector
#' arrow::arrow_table(
#'   foo = 1:5,
#'   bar = 6:10,
#'   ham = letters[1:5]
#' ) |>
#'   arrow::write_to_raw(format = "file") |>
#'   pl$read_ipc()
pl_read_ipc = function(
    source,
    ...,
    n_rows = NULL,
    memory_map = TRUE,
    row_index_name = NULL,
    row_index_offset = 0L,
    rechunk = FALSE,
    cache = TRUE) {
  uw = function(res) unwrap(res, "in pl$read_ipc():")

  if (isTRUE(is.raw(source))) {
    .pr$DataFrame$from_raw_ipc(
      source,
      n_rows,
      row_index_name,
      row_index_offset,
      memory_map
    ) |>
      uw()
  } else {
    .args = as.list(environment())
    result(do.call(pl$scan_ipc, .args)$collect()) |>
      uw()
  }
}


#' Write Arrow IPC data to a raw vector
#'
#' @inheritParams DataFrame_write_ipc
#' @return A raw vector
#' @seealso
#' - [`<DataFrame>$write_ipc()`][DataFrame_write_ipc]
#' @examples
#' df = pl$DataFrame(
#'   foo = 1:5,
#'   bar = 6:10,
#'   ham = letters[1:5]
#' )
#'
#' raw_ipc = df$to_raw_ipc()
#'
#' pl$read_ipc(raw_ipc)
#'
#' if (require("arrow", quietly = TRUE)) {
#'   arrow::read_ipc_file(raw_ipc, as_data_frame = FALSE)
#' }
DataFrame_to_raw_ipc = function(
    compression = c("uncompressed", "zstd", "lz4"),
    ...,
    future = FALSE) {
  .pr$DataFrame$to_raw_ipc(self, compression, future) |>
    unwrap("in $to_raw_ipc():")
}
