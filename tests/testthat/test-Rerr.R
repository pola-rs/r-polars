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

test_that("set/replace/read rcall & rinfo", {
  err0 = .pr$RPolarsErr$new()$bad_robj(42)$mistyped("is a string")
  err1 = err0$rinfo("in $foo()")
  err2 = err1$rinfo("in $bar()")

  expect_identical(err0$get_rinfo(), NULL)
  expect_identical(err1$get_rinfo(), "in $foo()")
  expect_identical(err2$get_rinfo(), "in $bar()")

  expect_identical(err2$get_rcall(), NULL)
  err_a = unwrap_err(result(unwrap(Err(err2), "in $bob()")))
  expect_identical(err_a$get_rcall(), call_to_string(sys.call(1)))

  err_b = unwrap_err(result(unwrap(Err(err_a), "in $joe()")))
  expect_identical(err_b$get_rcall(), call_to_string(sys.call(1)))
})


test_that("err_on_named_args", {
  # ok on no named args
  expect_identical(err_on_named_args(1, "a") |> unwrap(), list(1, "a"))

  # err on named args
  ctx = err_on_named_args(a = 1, b = 2)$err$contexts()
  expect_identical(names(ctx), c("Hint", "PlainErrorMessage", "BadArgument"))
  expect_identical(ctx$BadArgument, "a, b")
})
