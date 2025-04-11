test_that("as.list() returns a named list of series", {
  expect_equal(
    pl$DataFrame(a = 1L, "foo") |>
      as.list(),
    list(a = pl$Series("a", 1L), pl$Series("", "foo"))
  )
})
