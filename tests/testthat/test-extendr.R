test_that("extendr rprintln! supports %", {
  expect_identical(
    capture.output(test_print_string("123%%321")),
    "123%%321"
  )
})
