test_that("as_polars_expr for character", {
  expect_equal(
    as_polars_expr(c("foo", "bar")),
    pl$col("foo", "bar")
  )
  expect_equal(
    as_polars_expr(c("foo", "bar"), str_as_lit = TRUE),
    pl$lit(c("foo", "bar"))
  )
})
