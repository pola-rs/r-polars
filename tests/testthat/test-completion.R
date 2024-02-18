test_that("code completion: method names are found", {
  polars_activate_code_completion(mode = "native", verbose = FALSE)
  utils:::.assignToken("pl$col()$a")
  utils:::.completeToken()
  expect_true("pl$col()$abs()" %in% utils:::.retrieveCompletions())
  polars_deactivate_code_completion()
})

test_that("code completion: check mode name", {
  expect_error(
    polars_activate_code_completion(mode = "foobar"),
    "should be one of"
  )
})
