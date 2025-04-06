test_that("<series>$struct$unnest() works", {
  expect_equal(
    as_polars_series(mtcars)$struct$unnest(),
    as_polars_df(mtcars)
  )

  expect_snapshot(
    as_polars_series(1)$struct$unnest(),
    error = TRUE
  )
})
