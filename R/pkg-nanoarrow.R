#' Create a nanoarrow_array_stream from a Polars object
#'
#' @inheritParams as_arrow_table.RPolarsDataFrame
#' @inheritParams DataFrame_write_ipc
#' @param schema must stay at default value NULL
#' @rdname S3_as_nanoarrow_array_stream
#' @examples
#' library(nanoarrow)
#' pl_df = as_polars_df(mtcars)
#'
#' nanoarrow_array_stream = as_nanoarrow_array_stream(pl_df)
#' as.data.frame(nanoarrow_array_stream)
# exported in zzz.R
as_nanoarrow_array_stream.RPolarsDataFrame = function(x, ..., schema = NULL, future = FALSE) {
  uw = \(res) unwrap("in as_nanoarrow_array_stream(<RPolarsDataFrame>):")

  # Don't support the schema argument yet
  if (!is.null(schema)) {
    Err_plain("The `schema` argument is not supported yet") |>
      uw()
  }

  if (!is_scalar_bool(future)) {
    Err_plain("`future` argument must be `TRUE` or `FALSE`") |>
      uw()
  }

  stream = nanoarrow::nanoarrow_allocate_array_stream()
  .pr$DataFrame$export_stream(x, nanoarrow::nanoarrow_pointer_addr_chr(stream), future)
  stream
}


#' Infer nanoarrow schema from a Polars object
#'
#' @inheritParams as_nanoarrow_array_stream.RPolarsDataFrame
#' @rdname S3_infer_nanoarrow_schema
#' @examples
#' library(nanoarrow)
#' pl_df = as_polars_df(mtcars)
#'
#' infer_nanoarrow_schema(pl_df)
# exported in zzz.R
infer_nanoarrow_schema.RPolarsDataFrame = function(x, ..., future = FALSE) {
  as_nanoarrow_array_stream.RPolarsDataFrame(x, future = future)$get_schema() |>
    result() |>
    unwrap("in infer_nanoarrow_schema(<RPolarsDataFrame>):")
}
