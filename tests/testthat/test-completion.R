test_that("code completion: method names are found", {
  pl$code_completion(activate = TRUE, mode = "native", verbose = FALSE)
  utils:::.assignToken("pl$col()$a")
  utils:::.completeToken()
  expect_true("pl$col()$abs()" %in% utils:::.retrieveCompletions())
  pl$code_completion(activate = FALSE)
})
