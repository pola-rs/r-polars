test_that("roundtrip via nanoarrow array stream", {
  skip_if_not_installed("nanoarrow")

  lf <- pl$LazyFrame(
    x = 1:3,
    y = pl$concat(as_polars_series("a"), as_polars_series(c("b", "c"))), # ensure n chunks > 1
  )

  from_nanoarrow <- nanoarrow::as_nanoarrow_array_stream(lf, maintain_order = TRUE) |>
    as_polars_df()

  expect_warning({
    from_schema_specified <- nanoarrow::as_nanoarrow_array_stream(
      lf,
      maintain_order = TRUE,
      schema = nanoarrow::na_struct(list(
        x = nanoarrow::na_int32(),
        y = nanoarrow::na_string_view()
      ))
    ) |>
      as_polars_df()
  })

  expect_equal(from_nanoarrow, lf$collect())
  expect_equal(from_schema_specified, lf$collect())
})

test_that("polars_compat_level works", {
  skip_if_not_installed("nanoarrow")

  expect_identical(
    pl$LazyFrame(x = letters[1:3]) |>
      nanoarrow::as_nanoarrow_array_stream(polars_compat_level = 0) |>
      nanoarrow::infer_nanoarrow_schema() |>
      format(),
    "<nanoarrow_schema struct<x: large_string>>"
  )
  expect_snapshot(
    pl$LazyFrame(x = letters[1:3]) |>
      nanoarrow::as_nanoarrow_array_stream(polars_compat_level = TRUE),
    error = TRUE
  )
})

test_that("test lazy scan", {
  skip_if_not_installed("nanoarrow")

  tmpf <- withr::local_tempfile(fileext = ".csv")

  # write a csv file with one row
  writeLines("a\n1", tmpf)

  # create array stream
  stream <- pl$scan_csv(tmpf) |>
    nanoarrow::as_nanoarrow_array_stream()

  # write more rows after creating the stream
  writeLines("a\n1\n2", tmpf)

  # collect the array stream, collecting the rows this time should have two rows
  df <- as_polars_df(stream)
  expect_shape(df, dim = c(2L, 1L))

  # create array stream again
  stream <- pl$scan_csv(tmpf) |>
    nanoarrow::as_nanoarrow_array_stream()

  # overwrite the file having another schema
  writeLines("a\nfoo", tmpf)

  expect_snapshot(as_polars_df(stream), error = TRUE)
})
