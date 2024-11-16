test_that("Extract works for series struct namespace", {
  s <- as_polars_series(mtcars)

  expect_equal(
    s$struct["am"],
    as_polars_series(mtcars$am, name = "am")
  )
  expect_equal(
    s$struct[1],
    as_polars_series(mtcars$cyl, name = "cyl")
  )
  expect_error(s$struct[NA_character_])
})
