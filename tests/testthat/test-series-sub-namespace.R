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

test_that("List sub namespace", {
  expect_identical(
    pl$Series(list(3:1, 1:2, NULL))$list$first()$to_r(),
    c(3L, 1L, NA)
  )
})
