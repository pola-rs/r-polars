test_that("as_polars_lf.default throws an error", {
  expect_snapshot(as_polars_lf(1), error = TRUE)
  expect_snapshot(as_polars_lf(1i), error = TRUE)
})
