test_that("default options", {
  polars_options_reset()
  default_options = polars_options()
  # This value is set automatically, so we should update for the snapshot
  default_options[["limit_max_threads"]] = TRUE
  expect_snapshot(default_options)
})

test_that("options are validated", {
  polars_options_reset()
  options("polars.strictly_immutable" = 42, "polars.debug_polars" = "a")
  expect_snapshot_error(polars_options())
  polars_options_reset()
})

# TODO: remove before 0.14.0
test_that("$set_options() and $reset_options() work", {
  expect_warning(pl$set_options(strictly_immutable = FALSE), "deprecated")
  expect_warning(pl$reset_options(), "deprecated")
  expect_true(getOption("polars.strictly_immutable"))
})

test_that("polars_options() read-write", {
  polars_options_reset()

  old_options = polars_options()

  # options() works
  options(polars.maintain_order = TRUE)
  expect_true(polars_options()$maintain_order)

  # 'maintain_order' only accepts booleans (but error only shown later when
  # polars_options() is called, either directly or in internal functions)
  options(polars.maintain_order = 42)
  expect_error(
    polars_options(),
    "input must be TRUE or FALSE."
  )

  options(polars.maintain_order = FALSE, polars.strictly_immutable = c(TRUE, TRUE))
  expect_error(
    polars_options(),
    "input must be TRUE or FALSE."
  )
  polars_options_reset()
})


test_that("option 'int64_conversion ' works", {
  polars_options_reset()
  df = pl$DataFrame(a = c(1:3, NA), schema = list(a = pl$Int64))

  # default is to convert Int64 to float
  expect_identical(
    df$to_list(),
    list(a = c(1, 2, 3, NA))
  )

  # check value of int64_conversion
  options(polars.int64_conversion = "foobar")
  expect_error(
    polars_options(),
    "input must be one of"
  )

  # can convert to string
  options(polars.int64_conversion = "string")
  expect_identical(
    df$to_list(),
    list(a = c("1", "2", "3", NA))
  )

  # can convert to bit64, but *only* if bit64 is attached
  try(detach("package:bit64"), silent = TRUE)
  options(polars.int64_conversion = "bit64")
  expect_error(
    polars_options(),
    "must be attached"
  )
  skip_if_not_installed("bit64")
  suppressPackageStartupMessages(library(bit64))
  options(polars.int64_conversion = "bit64")
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
  polars_options_reset()
})

test_that("options work fine with withr", {
  skip_if_not_installed("withr")
  df = pl$DataFrame(a = c(1:3, NA), schema = list(a = pl$Int64))

  withr::with_options(
    list(polars.int64_conversion = "string"),
    expect_identical(
      df$to_list(),
      list(a = c("1", "2", "3", NA))
    )
  )
  expect_identical(polars_options()$int64_conversion, "double")
})
