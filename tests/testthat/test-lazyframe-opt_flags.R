test_that("QueryOptFlags", {
  expect_snapshot(pl$QueryOptFlags)
  expect_snapshot(eager_opt_flags())
  expect_snapshot(
    pl$QueryOptFlags(TRUE),
    error = TRUE,
    cnd_class = TRUE
  )

  opt_flags <- pl$QueryOptFlags()

  expect_snapshot(opt_flags)
  expect_snapshot(eager_opt_flags())
})
