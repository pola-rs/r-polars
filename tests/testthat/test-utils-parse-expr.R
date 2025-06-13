test_that("clear error message when passing lists with some Polars expr to dynamic dots", {
  dat <- pl$DataFrame(a = 1:2, b = 3:4)
  exprs <- list("a", pl$col("b") + 1)
  expect_snapshot(
    dat$select(exprs),
    error = TRUE
  )
  expect_snapshot(
    dat$select(exprs, exprs, exprs, exprs),
    error = TRUE
  )

  vals <- list(1:2, 3:4)
  expect_equal(
    dat$with_columns(vals),
    pl$DataFrame(a = 1:2, b = 3:4, literal = vals)
  )
  expect_equal(
    dat$with_columns(x = vals),
    pl$DataFrame(a = 1:2, b = 3:4, x = vals)
  )
})
