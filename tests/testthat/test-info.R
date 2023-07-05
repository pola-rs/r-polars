patrick::with_parameters_test_that("polars_info() features are logical",
  {
    expect_type(feature, "logical")
    expect_length(feature, 1)
  },
  feature = pl$polars_info()$features
)

test_that("print pl$polars_info()", {
  info <- pl$polars_info()
  # Ensure all features are FALSE for snapshot test
  for (feature in names(info$features)) {
    info$features[[feature]] <- FALSE
  }

  expect_snapshot(info)
})
