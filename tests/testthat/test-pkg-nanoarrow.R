
test_that("as_nanoarrow_array_stream() works for DataFrame", {
  skip_if_not_installed("nanoarrow")

  df = pl$DataFrame(a = 1L, b = "two")
  stream <- nanoarrow::as_nanoarrow_array_stream(df)
  expect_s3_class(stream, "nanoarrow_array_stream")
  expect_identical(
    as.data.frame(stream),
    data.frame(a = 1L, b = "two")
  )
})

test_that("infer_nanoarrow_schema() works for DataFrame", {
  skip_if_not_installed("nanoarrow")

  df = pl$DataFrame(a = 1L, b = "two")
  stream_schema <- nanoarrow::as_nanoarrow_array_stream(df)$get_schema()
  inferred_schema <- nanoarrow::infer_nanoarrow_schema(df)
  expect_identical(format(stream_schema), format(inferred_schema))
})

test_that("as_record_batch_reader() works for DataFrame", {
  skip_if_not_installed("nanoarrow")
  skip_if_not_installed("arrow")

  df = pl$DataFrame(a = 1L, b = "two")
  reader <- arrow::as_record_batch_reader(df)
  expect_s3_class(reader, "RecordBatchReader")

  expect_identical(
    # two as.data.frame()s because arrow sometimes returns a tibble here
    as.data.frame(as.data.frame(reader)),
    data.frame(a = 1L, b = "two")
  )
})

test_that("as_arrow_table() works for DataFrame", {
  skip_if_not_installed("nanoarrow")
  skip_if_not_installed("arrow")

  df = pl$DataFrame(a = 1L, b = "two")
  table <- arrow::as_arrow_table(df)
  expect_s3_class(table, "Table")

  expect_identical(
    # two as.data.frame()s because arrow sometimes returns a tibble here
    as.data.frame(as.data.frame(table)),
    data.frame(a = 1L, b = "two")
  )
})
