test_that("Expr methods works for Series", {
  expect_equal(
    as_polars_series(0)$cos(),
    as_polars_series(1)
  )
})

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

test_that(".DollarNames(<series>)", {
  expect_snapshot(.DollarNames(as_polars_series(NULL)))
})
