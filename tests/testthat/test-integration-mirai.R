test_that("mirai serialization works", {
  skip_if_not_installed("mirai", minimum_version = "2.3.0")
  # Daemons should be set by the setup.R file
  skip_if_not(mirai::daemons_set())

  series <- as_polars_series(1)$cast(pl$Int128)
  df <- pl$DataFrame(foo = series)
  lf <- df$lazy()

  # Test for Series
  expect_equal(
    list(series) |>
      mirai::mirai_map(\(x) x * 2L) |>
      _[][[1]],
    series * 2L
  )

  # Test for DataFrame and LazyFrame
  expect_equal(
    list(lf) |>
      mirai::mirai_map(\(x) x$collect()) |>
      _[][[1]],
    df
  )
})
