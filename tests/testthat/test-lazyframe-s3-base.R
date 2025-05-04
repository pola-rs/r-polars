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

test_that("`[`'s drop argument is not supported for LazyFrame", {
  pl_lf <- pl$LazyFrame(a = 1:3, b = 4:6, c = 7:9)
  warning_regex <- "`drop = TRUE` is not supported for LazyFrame"

  expect_warning(pl_lf[, "a", drop = TRUE], regexp = warning_regex)
  expect_warning(pl_lf["a", drop = TRUE], regexp = warning_regex)
  expect_warning(pl_lf[drop = TRUE], regexp = warning_regex)

  # drop should be named
  expect_equal(
    pl_lf[, "a", TRUE]$collect(),
    pl_lf$select("a")$collect()
  )
})
