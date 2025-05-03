test_that("as.list() returns a named list of series", {
  expect_equal(
    pl$DataFrame(a = 1L, "foo") |>
      as.list(),
    list(a = pl$Series("a", 1L), pl$Series("", "foo"))
  )
})

test_that("head() works", {
  dat <- data.frame(x = 1:10, y = 11:20)
  dat_pl <- as_polars_df(dat)
  expect_identical(
    as.data.frame(head(dat_pl, 5)),
    head(dat, 5),
    ignore_attr = TRUE
  )
})

test_that("tail() works", {
  dat <- data.frame(x = 1:10, y = 11:20)
  dat_pl <- as_polars_df(dat)
  expect_identical(
    as.data.frame(tail(dat_pl, 5)),
    tail(dat, 5),
    ignore_attr = TRUE
  )
})

test_that("`[` operator works to subset columns only", {
  test <- pl$DataFrame(a = 1:3, b = 4:6, c = 7:9)

  ### Indices
  expect_identical(test[1], pl$DataFrame(a = 1:3))
  expect_warning(
    expect_identical(test[1, drop = TRUE], pl$DataFrame(a = 1:3)),
    "`drop` argument ignored for subsetting a DataFrame",
  )
  expect_identical(test[, 1, drop = TRUE], pl$Series("a", 1:3))
  expect_identical(test[1:2], pl$DataFrame(a = 1:3, b = 4:6))
  expect_identical(test[, 1:2, drop = TRUE], pl$DataFrame(a = 1:3, b = 4:6))
  expect_identical(test[, -2:-1], pl$DataFrame(c = 7:9))
  expect_snapshot(test[, 10:12], error = TRUE)
  expect_snapshot(test[, -2:1], error = TRUE)
  expect_snapshot(test[, 1:-2], error = TRUE)
  expect_snapshot(test[, 1.5], error = TRUE)

  ### Column names
  expect_identical(test["a"], pl$DataFrame(a = 1:3))
  expect_warning(
    expect_identical(test["a", drop = TRUE], pl$DataFrame(a = 1:3)),
    "`drop` argument ignored for subsetting a DataFrame",
  )
  expect_identical(test[, "a", drop = TRUE], pl$Series("a", 1:3))
  expect_identical(test[c("a", "b")], pl$DataFrame(a = 1:3, b = 4:6))
  expect_identical(test[, c("a", "b"), drop = TRUE], pl$DataFrame(a = 1:3, b = 4:6))
  expect_snapshot(test[c("foo", "a", "bar", "baz")], error = TRUE)
  expect_snapshot(test["*"], error = TRUE)

  ### Logical values
  expect_identical(test[TRUE], test)
  expect_identical(test[FALSE], pl$DataFrame())
  expect_identical(test[c(TRUE, TRUE, FALSE)], pl$DataFrame(a = 1:3, b = 4:6))
  expect_error(
    test[c(TRUE, FALSE)],
    "must be size 1 or 3, not 2"
  )
  expect_identical(test[, TRUE, drop = TRUE], test)
  expect_identical(
    test[, c(TRUE, FALSE, FALSE), drop = TRUE],
    pl$Series("a", 1:3)
  )

  ### Empty args
  expect_identical(test[], test)
  # fmt: skip
  # <https://github.com/posit-dev/air/issues/330>
  expect_identical(test[, ], test)

  expect_snapshot(test[mean], error = TRUE)
  expect_snapshot(test[list(1)], error = TRUE)
  expect_snapshot(test[NA], error = TRUE)
  expect_snapshot(test[c(1, NA, NA)], error = TRUE)
  expect_snapshot(test[c("a", NA)], error = TRUE)
})

test_that("`[` operator works to subset rows only", {
  test <- pl$DataFrame(a = 1:3, b = 4:6, c = 7:9)

  ### Indices
  expect_identical(
    test[1, ],
    pl$DataFrame(a = 1L, b = 4L, c = 7L)
  )
  expect_identical(
    test[1:2, ],
    pl$DataFrame(a = 1:2, b = 4:5, c = 7:8)
  )
  expect_identical(
    test[c(1, 10), ],
    pl$DataFrame(a = c(1L, NA_integer_), b = c(4L, NA_integer_), c = c(7L, NA_integer_))
  )
  expect_identical(
    test[c(2, 1, 1), ],
    pl$DataFrame(a = c(2L, 1L, 1L), b = c(5L, 4L, 4L), c = c(8L, 7L, 7L))
  )
  expect_identical(
    test[c(2, 10000, 1), ],
    pl$DataFrame(a = c(2L, NA_integer_, 1L), b = c(5L, NA_integer_, 4L), c = c(8L, NA_integer_, 7L))
  )
  expect_identical(
    test[c(2, NA), ],
    pl$DataFrame(a = c(2L, NA_integer_), b = c(5L, NA_integer_), c = c(8L, NA_integer_))
  )
  expect_identical(
    test[-2:-1, ],
    pl$DataFrame(a = 3L, b = 6L, c = 9L)
  )
  expect_identical(
    test[NA_integer_, ],
    pl$DataFrame(a = NA_integer_, b = NA_integer_, c = NA_integer_)
  )
  expect_snapshot(test[c(-1, NA), ], error = TRUE)
  expect_snapshot(test[-2:1, ], error = TRUE)
  expect_snapshot(test[1:-2, ], error = TRUE)
  expect_snapshot(test[1.5, ], error = TRUE)

  ### Character
  expect_identical(
    test["1", ],
    pl$DataFrame(a = 1L, b = 4L, c = 7L)
  )
  expect_identical(
    test[c("1", "2"), ],
    pl$DataFrame(a = 1:2, b = 4:5, c = 7:8)
  )
  expect_identical(
    test["foo", ],
    pl$DataFrame(a = NA_integer_, b = NA_integer_, c = NA_integer_)
  )

  ### Logical
  expect_identical(test[TRUE, ], test)
  expect_identical(test[FALSE, ], test$clear())
  expect_identical(
    test[c(TRUE, TRUE, FALSE), ],
    pl$DataFrame(a = 1:2, b = 4:5, c = 7:8)
  )
  expect_identical(
    test[NA, ],
    pl$DataFrame(a = rep(NA_integer_, 3), b = rep(NA_integer_, 3), c = rep(NA_integer_, 3))
  )
  expect_identical(
    test[c(FALSE, NA, TRUE), ],
    pl$DataFrame(a = c(NA_integer_, 3L), b = c(NA_integer_, 6L), c = c(NA_integer_, 9L))
  )
  expect_snapshot(test[c(TRUE, FALSE), ], error = TRUE)
  expect_snapshot(test[c(NA, FALSE), ], error = TRUE)

  expect_snapshot(test[mean, ], error = TRUE)
  expect_snapshot(test[list(1), ], error = TRUE)

  # TODO: test behavior of x[i, , drop = TRUE] when it is clarified
  # https://github.com/tidyverse/tibble/issues/1570
})

test_that("`[` operator works to subset both rows and columns", {
  test <- pl$DataFrame(a = 1:3, b = 4:6, c = 7:9)
  expect_identical(test[1:2, "a"], pl$DataFrame(a = 1:2))
  expect_identical(test[TRUE, "a"], pl$DataFrame(a = 1:3))
  expect_identical(test[NULL, "a"], test$select("a")$clear())
  # TODO: polars drops the row if columns are dropped
  expect_identical(test[1, NULL], pl$DataFrame())
})

test_that("`[`'s drop argument works correctly", {
  test <- pl$DataFrame(a = 1:3, b = 4:6, c = 7:9)

  expect_equal(
    test[1, , drop = TRUE],
    pl$DataFrame(a = 1L, b = 4L, c = 7L)
  )
  # TODO: polars drops the row if columns are dropped
  expect_equal(
    test[1, character(), drop = TRUE],
    as_polars_df(NULL)
  )

  # drop should be named
  expect_equal(
    test[, "a", TRUE],
    pl$DataFrame(a = 1:3)
  )
})
