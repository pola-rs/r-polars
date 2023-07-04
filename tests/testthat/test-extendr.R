test_that("extendr rprintln! supports %", {
  expect_identical(
    capture.output(test_print_string("123%%321")), ## would return 123%321 if not escaped right
    "123%%321"
  )
})
