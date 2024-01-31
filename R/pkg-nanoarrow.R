#' Create a nanoarrow_array_stream from a Polars object
#'
#' @param schema must stay at default value NULL
#' @rdname S3_as_nanoarrow_array_stream
#' @examples
#' library(nanoarrow)
#' pl_df = as_polars_df(mtcars)
#'
#' nanoarrow_array_stream = as_nanoarrow_array_stream(pl_df)
#' as.data.frame(nanoarrow_array_stream)
# exported in zzz.R
as_nanoarrow_array_stream.RPolarsDataFrame = function(x, ..., schema = NULL) {
  # Don't support the schema argument yet
  stopifnot(is.null(schema))
  stream = nanoarrow::nanoarrow_allocate_array_stream()
  .pr$DataFrame$export_stream(x, nanoarrow::nanoarrow_pointer_addr_chr(stream))
  stream
}


#' Infer nanoarrow schema from a Polars object
#'
#' @rdname S3_infer_nanoarrow_schema
# exported in zzz.R
infer_nanoarrow_schema.RPolarsDataFrame = function(x, ...) {
  # TODO: we may not use `as_nanoarrow_array_stream` here
  as_nanoarrow_array_stream.RPolarsDataFrame(x)$get_schema()
}
