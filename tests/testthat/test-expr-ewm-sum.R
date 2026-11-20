test_that("ewm_sum supports decay parameters and execution modes", {
  df <- pl$DataFrame(x = c(1, 2, 3, 4))
  expected <- pl$DataFrame(x = c(1, 2.5, 4.25, 6.125))

  expect_equal(df$select(pl$col("x")$ewm_sum(alpha = 0.5)), expected)
  expect_equal(df$select(pl$col("x")$ewm_sum(com = 1)), expected)
  expect_equal(df$select(pl$col("x")$ewm_sum(span = 3)), expected)
  expect_equal(df$select(pl$col("x")$ewm_sum(half_life = 1)), expected)
  expect_equal(df$lazy()$select(pl$col("x")$ewm_sum(alpha = 0.5))$collect(), expected)
  expect_equal(df$get_column("x")$ewm_sum(alpha = 0.5), expected$get_column("x"))
})

test_that("ewm_sum respects null weights and minimum sample counts", {
  df <- pl$DataFrame(x = c(1, NA, 2, 3))

  expect_equal(
    df$select(
      absolute = pl$col("x")$ewm_sum(alpha = 0.5),
      relative = pl$col("x")$ewm_sum(alpha = 0.5, ignore_nulls = TRUE),
      minimum = pl$col("x")$ewm_sum(alpha = 0.5, min_samples = 2),
      zero_minimum = pl$col("x")$ewm_sum(alpha = 0.5, min_samples = 0),
      no_decay = pl$col("x")$ewm_sum(alpha = 1)
    ),
    pl$DataFrame(
      absolute = c(1, NA, 2.25, 4.125),
      relative = c(1, NA, 2.5, 4.25),
      minimum = c(NA, NA, 2.25, 4.125),
      zero_minimum = c(1, NA, 2.25, 4.125),
      no_decay = c(1, NA, 2, 3)
    )
  )
})

test_that("ewm_sum handles empty and all-null input", {
  expect_equal(
    pl$Series("x", numeric())$ewm_sum(alpha = 0.5),
    pl$Series("x", numeric())
  )
  expect_equal(
    pl$Series("x", c(NA_real_, NA_real_))$ewm_sum(alpha = 0.5),
    pl$Series("x", c(NA_real_, NA_real_))
  )
})

test_that("ewm_sum validates its arguments", {
  x <- pl$col("x")

  expect_error(x$ewm_sum(), "must be supplied")
  expect_error(x$ewm_sum(alpha = 0.5, com = 1), "Can't specify multiple")
  expect_error(x$ewm_sum(alpha = 0))
  expect_error(x$ewm_sum(alpha = 1.5))
  expect_error(x$ewm_sum(com = -1))
  expect_error(x$ewm_sum(span = 0.5))
  expect_error(x$ewm_sum(half_life = -1))
  expect_error(x$ewm_sum(alpha = 0.5, min_samples = -1))
  expect_error(x$ewm_sum(alpha = 0.5, adjust = TRUE), "must be empty")
})
