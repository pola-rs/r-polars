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
pl_read_ipc = function(
    source,
    ...,
    n_rows = NULL,
    memory_map = TRUE,
    row_index_name = NULL,
    row_index_offset = 0L,
    rechunk = FALSE,
    cache = TRUE) {
  .args = as.list(environment())
  result({
    do.call(pl$scan_ipc, .args)$collect()
  }) |>
    unwrap("in pl$read_ipc():")
}
