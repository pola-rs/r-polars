test_that("categorical helper methods are deprecated", {
  local_lifecycle_warnings()
  series <- as_polars_series(c("a", "b", "a"))$cast(pl$Categorical())

  expect_snapshot(series$cat$is_local(), cnd_class = TRUE)
  expect_snapshot(series$cat$uses_lexical_ordering(), cnd_class = TRUE)

  expect_false(suppressWarnings(series$cat$is_local()))
  expect_true(suppressWarnings(series$cat$uses_lexical_ordering()))
})
