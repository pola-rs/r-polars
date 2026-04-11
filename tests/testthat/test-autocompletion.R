test_that("verbose arg works", {
  expect_message(
    polars_code_completion_activate(),
    "Polars code completion"
  )
  expect_silent(polars_code_completion_activate(verbose = FALSE))

  if (inside_rstudio()) {
    expect_message(
      polars_code_completion_deactivate(),
      "Polars code completion"
    )
  } else {
    polars_code_completion_deactivate()
  }
})

test_that("deactivating when it was not activated is silent", {
  # Once to deactivate in case the session was somehow polluted, second time
  # to ensure it doesn't show a message if not autocompletion wasn't activated.
  expect_silent({
    polars_code_completion_deactivate(verbose = FALSE)
    polars_code_completion_deactivate()
  })
})
