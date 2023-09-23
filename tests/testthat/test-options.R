test_that("pl$options$ read-write", {
  # same names and values are read
  expect_identical(
    lapply(pl$options, \(f) f()),
    as.list(polars_optenv)
  )

  # pl$get_polars_options() get all options as in innner state
  expect_identical(
    pl$get_polars_options(),
    as.list(polars_optenv)
  )

  # single read identical, to inner state
  expect_identical(
    pl$options$default_maintain_order(),
    polars_optenv$default_maintain_order
  )

  # store old options and flip one bool option to opposite
  # test if option was flipped
  old_options = pl$get_polars_options()
  pl$options$default_maintain_order(!old_options$default_maintain_order)
  expect_true(
    old_options$default_maintain_order !=
      pl$options$default_maintain_order()
  )

  # check if not identical, reset options, check if identical
  expect_false(identical(old_options, as.list(polars_optenv)))
  do.call(pl$set_polars_options, old_options)
  expect_identical(
    old_options,
    as.list(polars_optenv)
  )

  # test, try write wrong value/type is rejected with error
  expect_grepl_error(
    pl$options$default_maintain_order(42),
    c("default_maintain_order", "requirement named is_bool")
  )
})
