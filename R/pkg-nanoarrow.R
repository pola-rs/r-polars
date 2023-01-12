
as_nanoarrow_array_stream.DataFrame <- function(x, ..., schema = NULL) {
  # Don't support the schema argument yet
  stopifnot(is.null(schema))

  stream = nanoarrow::nanoarrow_allocate_array_stream()
  .pr$DataFrame$export_stream(x, nanoarrow::nanoarrow_pointer_addr_chr(stream))

  stream
}

infer_nanoarrow_schema.DataFrame <- function(x, ...) {
  as_nanoarrow_array_stream.DataFrame(x)$get_schema()
}

as_record_batch_reader.DataFrame <- function(x, ..., schema = NULL) {
  arrow::as_record_batch_reader(as_nanoarrow_array_stream.DataFrame(x, schema = schema))
}

as_arrow_table.DataFrame <- function(x, ...) {
  reader = as_record_batch_reader.DataFrame(x)
  reader$read_table()
}
