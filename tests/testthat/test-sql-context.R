test_that("pl$SQLContext() works", {
  expect_equal(
    pl$SQLContext(mtcars = mtcars, foo = data.frame(x = 1))$tables(),
    c("foo", "mtcars")
  )
  expect_error(
    pl$SQLContext(mtcars, foo = data.frame(x = 1)),
    "All frames in `...` must be named"
  )
  # TODO: add message pattern when this is fixed
  # https://github.com/eitsupi/neo-r-polars/issues/206
  expect_error(pl$SQLContext(a = complex(1)))
})
