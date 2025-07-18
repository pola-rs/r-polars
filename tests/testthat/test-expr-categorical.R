test_that("get_categories", {
  dat <- pl$DataFrame(x = factor(c("z", "z", "k", "a", "b")))
  expect_equal(
    dat$select(pl$col("x")$cat$get_categories()),
    pl$DataFrame(x = c("z", "k", "a", "b"))
  )
})
