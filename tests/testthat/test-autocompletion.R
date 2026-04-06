test_that("verbose arg works", {
  expect_message(
    polars_code_completion_activate(),
    "Polars code completion" 
  )
  expect_silent(polars_code_completion_activate(verbose = FALSE))
})