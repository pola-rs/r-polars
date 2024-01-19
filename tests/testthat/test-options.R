test_that("pl$options$ read-write", {
  pl$reset_options()

  # basic checks
  expect_identical(
    pl$options,
    as.list(polars_optenv)
  )
  expect_identical(
    pl$options$maintain_order,
    polars_optenv$maintain_order
  )

  old_options = pl$options

  # set_options() works
  pl$set_options(maintain_order = TRUE)
  expect_true(pl$options$maintain_order)

  # set_options() only modifies the value for arguments that were explicitly
  # called
  pl$set_options(do_not_repeat_call = TRUE)
  expect_true(pl$options$do_not_repeat_call)
  expect_true(pl$options$maintain_order)

  # set_options() only accepts booleans
  ctx = pl$set_options(maintain_order = 42) |> get_err_ctx()
  expect_identical(ctx$BadArgument, "maintain_order")
  expect_identical(ctx$PlainErrorMessage, "Input must be TRUE or FALSE.")

  ctx = pl$set_options(strictly_immutable = c(TRUE, TRUE)) |> get_err_ctx()
  expect_identical(ctx$BadArgument, "strictly_immutable")
  expect_identical(ctx$PlainErrorMessage, "Input must be TRUE or FALSE.")

  # reset_options() works
  pl$reset_options()
  expect_identical(pl$options, old_options)

  # all set_options args must be named
  expect_identical(
    pl$set_options(42) |> get_err_ctx("Plain"),
    "all args must be named"
  )
  expect_identical(
    pl$set_options(rpool_cap = 42, 42) |> get_err_ctx("Plain"),
    "all args must be named"
  )

  # incomplete/misspelled name not allowed
  expect_identical(
    pl$set_options(rpo = 42) |> get_err_ctx("Hint"),
    "arg-name does not match any defined args of `?set_options`"
  )
})


test_that("option 'int64_conversion ' works", {
  pl$reset_options()
  df = pl$DataFrame(a = c(1:3, NA), schema = list(a = pl$Int64))

  # default is to convert Int64 to float
  expect_identical(
    df$to_list(),
    list(a = c(1, 2, 3, NA))
  )

  # can convert to string
  pl$set_options(int64_conversion = "string")
  expect_identical(
    df$to_list(),
    list(a = c("1", "2", "3", NA))
  )

  # can convert to bit64, but *only* if bit64 is attached
  try(detach("package:bit64"), silent = TRUE)
  expect_error(
    pl$set_options(int64_conversion = "bit64"),
    "must be attached"
  )
  skip_if_not_installed("bit64")
  suppressPackageStartupMessages(library(bit64))
  pl$set_options(int64_conversion = "bit64")
  expect_identical(
    df$to_list(),
    list(a = as.integer64(c(1, 2, 3, NA)))
  )

  # can override the global option by passing a custom arg
  # option currently is "bit64"
  expect_identical(
    df$to_list(int64_conversion = "string"),
    list(a = c("1", "2", "3", NA))
  )

  # arg correctly passed from to_data_frame() to to_list()
  expect_identical(
    df$to_data_frame(int64_conversion = "string"),
    data.frame(a = c("1", "2", "3", NA))
  )
})
