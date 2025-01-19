test_that("$first() works for series list namespace", {
  # list$first() is a special case because it calls another method of the same namespace
  expect_equal(
    as_polars_series(list(1:3))$list$first(),
    as_polars_series(1L)
  )
})
