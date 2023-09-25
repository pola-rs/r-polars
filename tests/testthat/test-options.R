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
  expect_error(
    pl$set_options(maintain_order = 42),
    "Incorrect input"
  )

  expect_error(
    pl$set_options(strictly_immutable = c(TRUE, TRUE)),
    "Incorrect input"
  )

  # reset_options() works
  pl$reset_options()
  expect_identical(pl$options, old_options)
})
