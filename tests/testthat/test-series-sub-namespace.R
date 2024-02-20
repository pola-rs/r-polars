test_that("string sub namespace", {
  expect_identical(
    pl$Series(c("A", "B", NA, "D"))$str$to_lowercase()$to_r(),
    c("a", "b", NA, "d")
  )
})

test_that("List sub namespace", {
  expect_identical(
    pl$Series(list(3:1, 1:2, NULL))$list$first()$to_r(),
    c(3L, 1L, NA)
  )
})

test_that("datetime sub namespace", {
  s = pl$date_range(
    as.Date("2024-02-18"), as.Date("2024-02-24"),
    interval = "1d"
  )$to_series()

  expect_identical(
    s$dt$day()$to_r(),
    18:24
  )
})

test_that("binary subnamespace", {
  s = pl$Series(c(r"(\x00\x00\x00)", r"(\xff\xff\x00)", r"(\x00\x00\xff)"))$
    to_lit()$
    cast(pl$Binary)$
    to_series()
  expect_identical(
    s$bin$contains(pl$lit(r"(\xff)")$cast(pl$Binary))$to_r(),
    c(FALSE, TRUE, TRUE)
  )
})

test_that("categorical sub namespace", {
  s = pl$Series(factor(c("foo", "bar", "foo", "foo", "ham")))
  expect_identical(
    s$cat$get_categories()$to_r(),
    c("foo", "bar", "ham")
  )
})

# TODO: this panicks
# test_that("array sub namespace", {
#   s = pl$Series(list(3:1, 1:2, c(NA_integer_, 4L)))$
#     to_lit()$
#     cast(pl$Array(width = 2))$
#     to_series()
# })
