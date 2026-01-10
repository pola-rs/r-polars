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
