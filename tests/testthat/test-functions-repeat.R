test_that("pl$repeat_() works", {
  expect_equal(
    pl$select(pl$repeat_("z", n = 3)),
    pl$DataFrame(`repeat` = c("z", "z", "z"))
  )
  expect_equal(
    pl$select(pl$repeat_(1, n = 3, dtype = pl$Int8)),
    pl$DataFrame(`repeat` = c(1, 1, 1))$cast(pl$Int8)
  )
  # values can't be cast to dtype
  expect_equal(
    pl$select(pl$repeat_("a", n = 3, dtype = pl$Int8)),
    pl$DataFrame(`repeat` = c(NA, NA, NA))$cast(pl$Int8)
  )
  # wrong `n`
  expect_error(
    pl$select(pl$repeat_("z", n = -1)),
    "must be greater than or equal to 0"
  )
})
