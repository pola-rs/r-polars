# exported in zzz.R
#' @rdname s3-as_nanoarrow_array_stream
as_nanoarrow_array_stream.polars_data_frame <- function(x, ..., schema = NULL) {
  as_polars_series(x) |>
    as_nanoarrow_array_stream.polars_series(..., schema = schema)
}
