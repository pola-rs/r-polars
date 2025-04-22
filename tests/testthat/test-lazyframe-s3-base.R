test_that("as.list() returns a named list of series", {
  expect_equal(
    pl$LazyFrame(a = 1L, "foo") |>
      as.list(),
    list(a = pl$Series("a", 1L), pl$Series("", "foo"))
  )
})

test_that("head() works", {
  dat <- data.frame(x = 1:10, y = 11:20)
  dat_pl <- as_polars_lf(dat)
  expect_identical(
    as.data.frame(head(dat_pl, 5)),
    head(dat, 5),
    ignore_attr = TRUE
  )
})

test_that("tail() works", {
  dat <- data.frame(x = 1:10, y = 11:20)
  dat_pl <- as_polars_lf(dat)
  expect_identical(
    as.data.frame(tail(dat_pl, 5)),
    tail(dat, 5),
    ignore_attr = TRUE
  )
})
