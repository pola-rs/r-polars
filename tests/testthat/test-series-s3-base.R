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

test_that("as.vector() suggests $to_r_vector() for datatypes that need attributes", {
  expect_silent(as.vector(pl$Series("a", 1:2)))

  # By default, int64 is converted to double, so as.vector() doesn't destroy
  # any attribute.
  expect_silent(as.vector(pl$Series("a", 1:2)$cast(pl$Int64)))

  withr::with_options(
    list(polars.to_r_vector.int64 = "integer64"),
    expect_snapshot(as.vector(pl$Series("a", 1:2)$cast(pl$Int64)))
  )
  expect_snapshot(as.vector(pl$Series("a", as.Date("2020-01-01"))))
  expect_snapshot(as.vector(pl$Series("a", as.POSIXct("2020-01-01", tz = "UTC"))))

  s_struct <- as_polars_series(data.frame(x = as.Date("2020-01-01")))
  expect_snapshot(as.vector(s_struct))

  s_list <- pl$Series("a", list(as.Date("2020-01-01")))
  expect_silent(as.vector(s_list))

  skip_if_not_installed("hms")
  expect_snapshot(as.vector(pl$Series("a", hms::hms(1, 2, 3))))
})
