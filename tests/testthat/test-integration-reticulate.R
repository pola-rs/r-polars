patrick::with_parameters_test_that(
  "Series/DataFrame roundtrip via py-polars",
  .cases = {
    tibble::tribble(
      ~.test_name, ~x,
      "int32", as_polars_series(1:3),
      "int128", as_polars_series(1:3)$cast(pl$Int128),
      "string (with name)", as_polars_series(letters[1:3], "foo"),
      # TODO: test categorical and enum, after the bug is fixed
    )
  },
  code = {
    skip_if_no_py_polars()
    skip_if_no_nanoarrow_py_integration()

    from_py_series <- reticulate::r_to_py(x) |>
      as_polars_series()
    df <- pl$DataFrame(foo = x)
    from_py_df <- df |>
      reticulate::r_to_py() |>
      as_polars_df()

    expect_equal(from_py_series, x)
    expect_equal(from_py_df, df)
  }
)

test_that("LazyFrame roundtrip via py-polars", {
  skip_if_no_py_polars(version = PY_VERSION)
  skip_on_dev_version()

  lf <- as_polars_lf(mtcars)$filter(pl$col("mpg") >= 20)$select("cyl")$sort(cs$all())

  expect_equal(
    reticulate::r_to_py(lf) |>
      as_polars_lf() |>
      as_polars_df(),
    lf$collect()
  )
})
