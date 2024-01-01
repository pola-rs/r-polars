test_that("unpack_list", {
  # unpacks a single list
  expect_identical(
    unpack_list(list(1, 2, 3)),
    unpack_list(1, 2, 3)
  )

  # ... not if more args
  expect_failure(expect_equal(
    unpack_list(list(1, 2, 3), "a"),
    unpack_list(1, 2, 3, "a")
  ))

  # skip_classes
  expect_identical(
    unpack_list(data.frame(a = 1, b = 2), skip_classes = "data.frame"),
    list(data.frame(a = 1, b = 2))
  )
  expect_failure(expect_equal(
    unpack_list(data.frame(a = 1, b = 2), skip_classes = NULL),
    list(data.frame(a = 1, b = 2))
  ))

  # trailing commas not allowed
  err = unpack_list(1, .context = "this test", .call = call("foobar"), ) |>
    result() |>
    unwrap_err()
  expect_identical(
    err$contexts()[[1]],
    "trailing argument commas are not (yet) supported with polars"
  )
  expect_identical(err$get_rcall(), "foobar()")
  expect_identical(err$get_rinfo(), "this test")
})



test_that("unpack_bool_expr_result", {
  # unpacks a single list, return ok-result, get same polars expression
  a = unpack_bool_expr_result(pl$col("a") == 1, pl$col("b") > 2)
  b = unpack_bool_expr_result(list(pl$col("a") == 1, pl$col("b") > 2))
  expect_true(a$ok$meta$eq(b$ok))

  # ... not if more args
  expect_failure(expect_equal(
    unpack_list(list(1, 2, 3), "a"),
    unpack_list(1, 2, 3, "a")
  ))

  # trailing commas not allowed
  ctx = unpack_list(1, ) |> get_err_ctx()
  expect_identical(
    ctx[[1]],
    "trailing argument commas are not (yet) supported with polars"
  )
})
