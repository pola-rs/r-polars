test_that("can add any context to err", {

  err_types = c(
    "bad_arg", "bad_robj", "bad_val", "hint",
    "mistyped", "misvalued", "plain", "when"
  )
  rpolarserr = .pr$RPolarsErr$new()
  for (i in err_types) rpolarserr = rpolarserr[[i]](i)

  expect_identical(
    names(rpolarserr$contexts()),
    c(
      "When", "PlainErrorMessage", "ValueOutOfScope", "TypeMismatch",
      "Hint", "BadValue", "BadValue", "BadArgument"
    )
  )

})
