test_that("$first() works for series list namespace", {
  # list$first() is a special case because it calls another method of the same namespace
  expect_equal(
    as_polars_series(list(1:3))$list$first(),
    as_polars_series(1L)
  )
})

test_that("series list$to_struct accepts explicit fields", {
  series <- as_polars_series(list(c(1, 2), c(1, 2, 3)))

  expect_no_warning(series$list$to_struct(c("a", "b")))
  expect_no_warning(series$list$to_struct(fields = c("a", "b")))
  expect_equal(
    as_polars_df(series$list$to_struct(c("a", "b"))),
    pl$DataFrame(a = c(1, 1), b = c(2, 2))
  )
})
