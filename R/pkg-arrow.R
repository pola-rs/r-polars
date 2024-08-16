#' Create a arrow Table from a Polars object
#'
#' @inheritParams DataFrame_write_ipc
#' @param x [A Polars DataFrame][DataFrame_class]
#' @param ... Ignored
#' @rdname S3_as_arrow_table
#' @examplesIf requireNamespace("arrow", quietly = TRUE)
#' library(arrow)
#'
#' pl_df = as_polars_df(mtcars)
#' as_arrow_table(pl_df)
# exported in zzz.R
as_arrow_table.RPolarsDataFrame = function(x, ..., compat_level = FALSE) {
  reader = result(as_record_batch_reader.RPolarsDataFrame(x, compat_level = compat_level)) |>
    unwrap("in as_arrow_table(<RPolarsDataFrame>):")
  reader$read_table()
}


#' Create a arrow RecordBatchReader from a Polars object
#'
#' @inheritParams as_arrow_table.RPolarsDataFrame
#' @rdname S3_as_record_batch_reader
#' @examplesIf requireNamespace("arrow", quietly = TRUE)
#' library(arrow)
#'
#' pl_df = as_polars_df(mtcars)
#' as_record_batch_reader(pl_df)
# exported in zzz.R
as_record_batch_reader.RPolarsDataFrame = function(x, ..., compat_level = FALSE) {
  # https://github.com/apache/arrow/issues/39793
  allocate_arrow_array_stream = utils::getFromNamespace("allocate_arrow_array_stream", "arrow")
  external_pointer_addr_character = utils::getFromNamespace("external_pointer_addr_character", "arrow")

  stream = allocate_arrow_array_stream()
  .pr$DataFrame$export_stream(x, external_pointer_addr_character(stream), compat_level)
  arrow::RecordBatchReader$import_from_c(stream)
}
