
#' rpolars to nanoarrow and arrow
#' @description Conversion via native apache arrow array stream (fast), THIS REQUIRES ´nanoarrow´
#' @name nanoarrow
#' @param x a polars DataFrame
#' @param ... not used right now
#' @param schema must stay at default value NULL
#' @keywords nanoarrow_interface
#' @return a nanoarrow array stream
#' @usage as_nanoarrow_array_stream(x, ..., schema = NULL)
#' @details
#' The following functions enable conversion to `nanoarrow` and `arrow`.
#' Conversion kindly provided by "paleolimbot / Dewey Dunnington" Author of `nanoarrow`.
#' Currently these conversions are the fastest way to convert from polars to R.
#'
#' These conversion function are not exported/public are only accessible via `nanoarrow`
#' e.g. \cr\cr
#' `df = pl$DataFrame(iris)`\cr
#' `nanoarrow::nanoarrow_allocate_array_stream(df)`\cr\cr
#' or\cr\cr
#' `library(nanoarrow)`\cr
#' `nanoarrow_allocate_array_stream(df)`\cr
#'
#' @aliases array_stream arrow nanoarrow record_batch_reader arrow_table
#' read more at \link{https://github.com/apache/arrow-nanoarrow/r}
#'
#' @examples
#' library(nanoarrow)
#' library(rpolars)
#' df = pl$DataFrame(iris)
#' nanoarrow_array_stream = as_nanoarrow_array_stream(df)
#' rdf = as.data.frame(nanoarrow_array_stream)
as_nanoarrow_array_stream.DataFrame = function(x, ..., schema = NULL) {
  # Don't support the schema argument yet
  stopifnot(is.null(schema))
  stream = nanoarrow::nanoarrow_allocate_array_stream()
  .pr$DataFrame$export_stream(x, nanoarrow::nanoarrow_pointer_addr_chr(stream))
  stream
}

#' @rdname nanoarrow
#' @return a nanoarrow array schema
#' @usage infer_nanoarrow_schema(x, ...)
#' @examples
#' nanoarrow_array_schema = infer_nanoarrow_schema(df)
infer_nanoarrow_schema.DataFrame = function(x, ...) {
  as_nanoarrow_array_stream.DataFrame(x)$get_schema()
}

#' @rdname nanoarrow
#' @return an arrow record batch reader
#' @usage as_record_batch_reader(x, ..., schema = NULL)
#' @examples
#' arrow_record_batch_reader = as_record_batch_reader(df)
as_record_batch_reader.DataFrame = function(x, ..., schema = NULL) {
  arrow::as_record_batch_reader(as_nanoarrow_array_stream.DataFrame(x, schema = schema))
}

#' @rdname nanoarrow
#' @return an arrow table
#' @usage as_arrow_table(x, ..., schema = NULL)
#' @examples
#' arrow_table = as_arrow_table(df)
as_arrow_table.DataFrame = function(x, ...) {
  reader = as_record_batch_reader.DataFrame(x)
  reader$read_table()
}
