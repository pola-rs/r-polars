test_that("test CompatLevel", {
  expect_snapshot(pl$CompatLevel$oldest)
  expect_snapshot(pl$CompatLevel$newest)
})
