test_that("get_categories", {
  skip("Sinse categories are not stable because global categories are always used now.")
  # TODO: enable tests after local categorical generation is implemented

  dat <- pl$DataFrame(x = factor(c("z", "z", "k", "a", "b")))
  expect_equal(
    dat$select(pl$col("x")$cat$get_categories()),
    pl$DataFrame(x = c("z", "k", "a", "b"))
  )
})
