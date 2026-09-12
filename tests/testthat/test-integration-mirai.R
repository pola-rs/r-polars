test_that("mirai serialization works", {
  skip_if_not_installed("mirai", minimum_version = "2.3.0")
  # Daemons should be set by the setup.R file
  skip_if_not(mirai::daemons_set())

  # FIXME: On GitHub Actions CI with Windows, this test hangs
  skip_on_os("windows")

  sql_lf <- pl$SQLContext(data = pl$DataFrame(a = 1:3))$execute("SELECT * FROM data")
  serialized_sql_lf <- sql_lf$serialize()

  # The daemon has not constructed an SQLContext, so deserialization must use
  # the resolver registered when the polars library was loaded.
  expect_equal(
    list(serialized_sql_lf) |>
      mirai::mirai_map(\(x) polars::pl$deserialize_lf(x)$collect()) |>
      _[][[1]],
    pl$DataFrame(a = 1:3)
  )

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

test_that("Warn if daemons already exist when registering mirai serialization configs", {
  skip_if_not_installed("mirai", minimum_version = "2.3.0")
  # Daemons should be set by the setup.R file
  skip_if_not(mirai::daemons_set())

  # FIXME: On GitHub Actions CI with Windows, this test hangs
  skip_on_os("windows")

  expect_snapshot(register_mirai_serial(), cnd_class = TRUE)
})
