# Mostly tested in dataframe-s3-arrow

test_that("Only struct type is allowed", {
  skip_if_not_installed("arrow")

  expect_snapshot(
    as_polars_series(1:3) |>
      arrow::as_record_batch_reader(),
    error = TRUE
  )
})
