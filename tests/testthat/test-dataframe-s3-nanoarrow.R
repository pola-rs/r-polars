test_that("roundtrip via nanoarrow array stream", {
  skip_if_not_installed("nanoarrow")

  df <- pl$DataFrame(
    x = 1:3,
    y = letters[1:3],
  )

  from_nanoarrow <- nanoarrow::as_nanoarrow_array_stream(df) |>
    as_polars_df()
  from_schema_specified <- nanoarrow::as_nanoarrow_array_stream(
    df,
    schema = nanoarrow::na_struct(list(x = nanoarrow::na_int32(), y = nanoarrow::na_string_view()))
  ) |>
    as_polars_df()

  expect_equal(from_nanoarrow, df)
  expect_equal(from_schema_specified, df)
})
