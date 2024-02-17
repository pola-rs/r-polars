test_that("Series to lower case", {
  expect_identical(
    pl$Series(c("A", "B", NA, "D"))$str$to_lowercase()$to_r(),
    c("a", "b", NA, "d")
  )
})

test_that("Series to upper case", {
  expect_identical(
    pl$Series(c("a", "b", NA, "d"))$str$to_uppercase()$to_r(),
    c("A", "B", NA, "D")
  )
})
