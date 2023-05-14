test_that("run polars in background mode", {
  lazy_df = pl$DataFrame(iris[1:3, ])$lazy()$select(pl$all()$first())
  handle = lazy_df$collect_background()
  expect_true(inherits(handle, "PolarsBackgroundHandle"))
  expect_false(handle$is_exhausted())
  act_df = handle$join()
  expect_identical(
    act_df$to_list(),
    lazy_df$collect()$to_list()
  )
  expect_true(handle$is_exhausted())
  expect_grepl_error(handle$join(), "Handle was already exhausted")
})
