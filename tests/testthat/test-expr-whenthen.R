test_that("polars_then and polars_chained_then supports expr methods", {
  # polars_then
  expect_equal(
    pl$select(pl$when(TRUE)$then(1L)$add(1L)),
    pl$DataFrame(literal = 2L)
  )
  # polars_chained_then
  expect_equal(
    pl$select(pl$when(FALSE)$then(0L)$when(TRUE)$then(1L)$add(1L)),
    pl$DataFrame(literal = 2L)
  )
})

test_that("otherwise is optional inside pl$select", {
  # polars_then
  expect_equal(
    pl$select(pl$when(FALSE)$then(1L)),
    pl$DataFrame(literal = NA_integer_)
  )
  # polars_chained_then
  expect_equal(
    pl$select(pl$when(FALSE)$then(0L)$when(FALSE)$then(1L)),
    pl$DataFrame(literal = NA_integer_)
  )
})
