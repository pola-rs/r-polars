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

test_that("arg_sort_by", {
  df <- pl$DataFrame(
    a = c(0, 1, 1, 0),
    b = c(3, 2, 3, 2),
    c = c(1, 2, 3, 4)
  )
  expect_equal(
    df$select(pl$arg_sort_by("a")),
    pl$DataFrame(a = c(0, 3, 1, 2))$cast(pl$UInt32)
  )
  expect_equal(
    df$select(pl$arg_sort_by("a", "b", descending = TRUE)),
    pl$DataFrame(a = c(2, 1, 0, 3))$cast(pl$UInt32)
  )
  expect_equal(
    df$select(pl$col("c")$gather(pl$arg_sort_by("a"))),
    pl$DataFrame(c = c(1, 4, 2, 3))
  )
  expect_error(
    df$select(pl$arg_sort_by()),
    "`...` must contain at least one element"
  )
  expect_error(
    df$select(pl$arg_sort_by(a = "a")),
    "must be passed by position"
  )
  expect_error(
    df$select(pl$arg_sort_by("a", "b", descending = c(TRUE, TRUE, TRUE))),
    "the length of `descending` (3) does not match",
    fixed = TRUE
  )
  expect_error(
    df$select(pl$arg_sort_by("a", "b", nulls_last = c(TRUE, TRUE, TRUE))),
    "the length of `nulls_last` (3) does not match",
    fixed = TRUE
  )
})
