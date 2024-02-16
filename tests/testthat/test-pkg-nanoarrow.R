test_that("as_nanoarrow_array_stream() works for DataFrame", {
  skip_if_not_installed("nanoarrow")

  df = pl$DataFrame(a = 1L, b = "two")
  stream = nanoarrow::as_nanoarrow_array_stream(df)
  expect_s3_class(stream, "nanoarrow_array_stream")
  expect_identical(
    as.data.frame(stream),
    data.frame(a = 1L, b = "two")
  )
})

test_that("infer_nanoarrow_schema() works for DataFrame", {
  skip_if_not_installed("nanoarrow")

  df = pl$DataFrame(a = 1L, b = "two")
  stream_schema = nanoarrow::as_nanoarrow_array_stream(df)$get_schema()
  inferred_schema = nanoarrow::infer_nanoarrow_schema(df)
  expect_identical(format(stream_schema), format(inferred_schema))
})
