test_that("roundtrip via arrow table", {
  skip_if_not_installed("arrow")

  df <- pl$DataFrame(
    x = 1:3,
    y = letters[1:3],
  )

  from_arrow <- arrow::as_arrow_table(df) |>
    as_polars_df()

  expect_equal(from_arrow, df)
})

test_that("polars_compat_level works", {
  skip_if_not_installed("arrow")

  expect_snapshot(
    pl$DataFrame(x = letters[1:3]) |>
      arrow::as_arrow_table(polars_compat_level = "oldest")
  )
  expect_snapshot(
    pl$DataFrame(x = letters[1:3]) |>
      arrow::as_arrow_table(polars_compat_level = "newest")
  )
  expect_snapshot(
    pl$DataFrame(x = letters[1:3]) |>
      arrow::as_arrow_table(polars_compat_level = TRUE),
    error = TRUE
  )
})
