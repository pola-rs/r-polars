test_that("verbose arg works", {
  expect_message(
    polars_code_completion_activate(),
    "Polars code completion"
  )
  expect_silent(polars_code_completion_activate(verbose = FALSE))
  polars_code_completion_deactivate()
})

test_that("deactivating when it was not activated is silent", {
  # Once to deactivate in case the session was somehow polluted, second time
  # to ensure we can deactivate again.
  expect_silent({
    polars_code_completion_deactivate()
    polars_code_completion_deactivate()
  })
})
