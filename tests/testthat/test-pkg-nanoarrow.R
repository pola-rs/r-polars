test_that("as_nanoarrow_array_stream() works for DataFrame", {
  skip_if_not_installed("nanoarrow", minimum_version = "0.6.0")

  df = pl$DataFrame(a = 1L, b = "two")
  stream = nanoarrow::as_nanoarrow_array_stream(df)
  expect_s3_class(stream, "nanoarrow_array_stream")
  expect_identical(
    as.data.frame(stream),
    data.frame(a = 1L, b = "two")
  )

  expect_identical(
    nanoarrow::as_nanoarrow_array_stream(df, compat_level = TRUE) |>
      as.data.frame(),
    data.frame(a = 1L, b = "two")
  )
})


test_that("as_nanoarrow_array_stream() works for Series", {
  skip_if_not_installed("nanoarrow", minimum_version = "0.6.0")

  s = as_polars_series(letters[1:3])
  stream = nanoarrow::as_nanoarrow_array_stream(s)
  expect_s3_class(stream, "nanoarrow_array_stream")
  expect_identical(
    as.vector(stream),
    letters[1:3]
  )

  expect_identical(
    nanoarrow::as_nanoarrow_array_stream(s, compat_level = TRUE) |>
      as.vector(),
    letters[1:3]
  )
})


test_that("infer_nanoarrow_schema() works for DataFrame", {
  skip_if_not_installed("nanoarrow")

  df = pl$DataFrame(a = 1L, b = "two")
  stream_schema = nanoarrow::as_nanoarrow_array_stream(df)$get_schema()
  inferred_schema = nanoarrow::infer_nanoarrow_schema(df)
  expect_identical(format(stream_schema), format(inferred_schema))
})


test_that("infer_nanoarrow_schema() works for Series", {
  skip_if_not_installed("nanoarrow")

  s = as_polars_series(letters[1:3])
  stream_schema = nanoarrow::as_nanoarrow_array_stream(s)$get_schema()
  inferred_schema = nanoarrow::infer_nanoarrow_schema(s)
  expect_identical(format(stream_schema), format(inferred_schema))
})
