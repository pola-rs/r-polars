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

test_that("`[` operator works to subset columns only", {
  test <- pl$LazyFrame(a = 1:3, b = 4:6, c = 7:9)

  ### Indices
  expect_identical(test[1]$collect(), pl$LazyFrame(a = 1:3)$collect())
  expect_identical(test[1:2]$collect(), pl$LazyFrame(a = 1:3, b = 4:6)$collect())
  expect_identical(test[, 1:2]$collect(), pl$LazyFrame(a = 1:3, b = 4:6)$collect())
  expect_identical(test[, -2:-1]$collect(), pl$LazyFrame(c = 7:9)$collect())
  expect_snapshot(test[1, drop = TRUE]$collect())
  expect_snapshot(test[, 1, drop = TRUE]$collect())
  expect_snapshot(test[, 10:12], error = TRUE)
  expect_snapshot(test[, -2:1], error = TRUE)
  expect_snapshot(test[, 1:-2], error = TRUE)
  expect_snapshot(test[, 1.5], error = TRUE)

  ### Column names
  expect_identical(test["a"]$collect(), pl$LazyFrame(a = 1:3)$collect())
  expect_identical(test[c("a", "b")]$collect(), pl$LazyFrame(a = 1:3, b = 4:6)$collect())
  expect_snapshot(test["a", drop = TRUE]$collect())
  expect_snapshot(test[, "a", drop = TRUE]$collect())
  expect_snapshot(test[c("a", "foo")], error = TRUE)

  ### Logical values
  expect_identical(test[TRUE]$collect(), test$collect())
  expect_identical(test[c(TRUE, TRUE, FALSE)]$collect(), pl$LazyFrame(a = 1:3, b = 4:6)$collect())
  expect_error(
    test[c(TRUE, FALSE)],
    "must be size 1 or 3, not 2"
  )

  ### Empty args
  expect_identical(test[]$collect(), test$collect())
  # fmt: skip
  # <https://github.com/posit-dev/air/issues/330>
  expect_identical(test[, ]$collect(), test$collect())

  expect_snapshot(test[mean], error = TRUE)
  expect_snapshot(test[list(1)], error = TRUE)
  expect_snapshot(test[NA], error = TRUE)
  expect_snapshot(test[c(1, NA, NA)], error = TRUE)
  expect_snapshot(test[c("a", NA)], error = TRUE)
})

test_that("`[` operator cannot subset rows", {
  test <- pl$LazyFrame(a = 1:3, b = 4:6, c = 7:9)
  expect_snapshot(test[1:2, ], error = TRUE)
  expect_snapshot(test[1:2, "a"], error = TRUE)
  expect_snapshot(test[c(FALSE, FALSE), ], error = TRUE)

  # Special cases
  expect_identical(test[TRUE, ]$collect(), test$collect())
  expect_identical(test[FALSE, ]$collect(), test$clear()$collect())
  expect_identical(test[NULL, ]$collect(), test$clear()$collect())
})
