#' Create a nanoarrow_array_stream from a Polars object
#'
#' @inheritParams as_arrow_table.RPolarsDataFrame
#' @param x A polars object
#' @param schema must stay at default value NULL
#' @rdname S3_as_nanoarrow_array_stream
#' @examplesIf requireNamespace("nanoarrow", quietly = TRUE)
#' library(nanoarrow)
#'
#' pl_df = as_polars_df(mtcars)$head(5)
#' pl_s = as_polars_series(letters[1:5])
#'
#' as.data.frame(as_nanoarrow_array_stream(pl_df))
#' as.vector(as_nanoarrow_array_stream(pl_s))
# exported in zzz.R
as_nanoarrow_array_stream.RPolarsDataFrame = function(x, ..., schema = NULL, future = FALSE) {
  uw = \(res) unwrap("in as_nanoarrow_array_stream():")

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


# TODO: export the `$export_stream` method and combine the two functions
#' @rdname S3_as_nanoarrow_array_stream
# exported in zzz.R
as_nanoarrow_array_stream.RPolarsSeries = function(x, ..., schema = NULL, future = FALSE) {
  uw = \(res) unwrap("in as_nanoarrow_array_stream():")

  if (!is.null(schema)) {
    Err_plain("The `schema` argument is not supported yet") |>
      uw()
  }

  if (!is_scalar_bool(future)) {
    Err_plain("`future` argument must be `TRUE` or `FALSE`") |>
      uw()
  }

  stream = nanoarrow::nanoarrow_allocate_array_stream()
  .pr$Series$export_stream(x, nanoarrow::nanoarrow_pointer_addr_chr(stream), future)
  stream
}


#' Infer nanoarrow schema from a Polars object
#'
#' @inheritParams as_nanoarrow_array_stream.RPolarsDataFrame
#' @rdname S3_infer_nanoarrow_schema
#' @examplesIf requireNamespace("nanoarrow", quietly = TRUE)
#' library(nanoarrow)
#'
#' pl_df = as_polars_df(mtcars)$select("mpg", "cyl")
#' pl_s = as_polars_series(letters)
#'
#' infer_nanoarrow_schema(pl_df)
#' infer_nanoarrow_schema(pl_s)
# exported in zzz.R
infer_nanoarrow_schema.RPolarsDataFrame = function(x, ..., future = FALSE) {
  nanoarrow::as_nanoarrow_array_stream(x, future = future)$get_schema() |>
    result() |>
    unwrap("in infer_nanoarrow_schema():")
}


#' @rdname S3_infer_nanoarrow_schema
# exported in zzz.R
infer_nanoarrow_schema.RPolarsSeries = infer_nanoarrow_schema.RPolarsDataFrame
