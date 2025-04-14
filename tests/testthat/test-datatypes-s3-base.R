test_that("format() works", {
  expect_identical(format(pl$Int8), "Int8")
  expect_identical(format(pl$Int8, abbreviated = TRUE), "i8")
})
