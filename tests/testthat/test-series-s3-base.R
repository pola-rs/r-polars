test_that("Expr methods works for Series", {
  expect_equal(
    as_polars_series(0)$cos(),
    as_polars_series(1)
  )
})
