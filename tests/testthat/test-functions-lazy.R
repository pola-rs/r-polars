test_that("pl$coalesce()", {
  df <- pl$DataFrame(
    a = c(1, NA, NA, NA),
    b = c(1, 2, NA, NA),
    c = c(5, NA, 3, NA)
  )

  expect_equal(
    df$select(pl$coalesce("a", "b", "c", 10)),
    pl$DataFrame(a = c(1, 2, 3, 10))
  )
  expect_equal(
    df$select(pl$coalesce(pl$col("a", "b", "c"), 10)),
    pl$DataFrame(a = c(1, 2, 3, 10))
  )
  expect_error(
    pl$coalesce(foo = "bar"),
    "must be passed by position, not name"
  )
})

test_that("arg_where", {
  df <- pl$DataFrame(a = 1:5)
  expect_equal(
    df$select(pl$arg_where(pl$col("a") %% 2 == 0)),
    pl$DataFrame(a = c(1, 3))$cast(pl$UInt32)
  )
})
