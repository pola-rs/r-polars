test_that("get_categories", {
  skip("Since categories are not stable because global categories are always used now.")
  # TODO: enable tests after local categorical generation is implemented

  dat <- pl$DataFrame(x = factor(c("z", "z", "k", "a", "b")))
  expect_equal(
    dat$select(pl$col("x")$cat$get_categories()),
    pl$DataFrame(x = c("z", "k", "a", "b"))
  )
})

test_that("cat$physical() works", {
  dtype <- pl$Enum(c("bar", "foo", "x"))
  df <- pl$DataFrame(x = c("foo", "bar", "foo", "x", NA))$cast(dtype)

  expect_equal(
    df$select(pl$col("x")$cat$physical()),
    pl$DataFrame(x = c(1, 0, 1, 2, NA))$cast(pl$UInt8)
  )

  # roundtrip works
  expect_equal(
    df$select(pl$col("x")$cat$physical()$cat$to(dtype)),
    df
  )

  expect_snapshot(
    pl$DataFrame(x = 1)$select(pl$col("x")$cat$physical()),
    error = TRUE
  )
})

test_that("cat$to() works", {
  dtype <- pl$Enum(c("bar", "foo", "x"))
  df <- pl$DataFrame(x = c(1, 0, 1, 2, NA))$cast(pl$UInt8)

  expect_equal(
    df$select(pl$col("x")$cat$to(dtype)),
    pl$DataFrame(x = c("foo", "bar", "foo", "x", NA))$cast(dtype)
  )

  # values that are not valid categories
  invalid <- pl$DataFrame(x = c(1, 0, 4))$cast(pl$UInt8)
  expect_snapshot(
    invalid$select(pl$col("x")$cat$to(dtype)),
    error = TRUE
  )
  expect_equal(
    invalid$select(pl$col("x")$cat$to(dtype, strict = FALSE)),
    pl$DataFrame(x = c("foo", "bar", NA))$cast(dtype)
  )

  # the input must have the physical type of the target dtype
  expect_snapshot(
    pl$DataFrame(x = c(1, 0))$cast(pl$UInt16)$select(pl$col("x")$cat$to(dtype)),
    error = TRUE
  )

  # the target dtype must be a Categorical or an Enum
  expect_snapshot(
    df$select(pl$col("x")$cat$to(pl$String)),
    error = TRUE
  )

  expect_snapshot(
    df$select(pl$col("x")$cat$to(dtype, FALSE)),
    error = TRUE
  )
})
