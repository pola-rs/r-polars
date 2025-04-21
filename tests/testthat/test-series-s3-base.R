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

test_that("S3 methods work", {
  s <- pl$Series("", 1:2)
  expect_identical(max(s), as_polars_series(2L))
  expect_identical(min(s), as_polars_series(1L))
  expect_identical(sum(s), as_polars_series(3L))
  expect_identical(mean(s), as_polars_series(1.5))
  expect_identical(median(s), as_polars_series(1.5))
})
