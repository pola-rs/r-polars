patrick::with_parameters_test_that("polars_info() features are logical",
  {
    expect_type(feature, "logical")
    expect_length(feature, 1)
  },
  feature = polars_info()$features
)

test_that("print polars_info()", {
  info <- polars_info()
  # Ensure all features are FALSE for snapshot test
  for (feature in names(info$features)) {
    info$features[[feature]] <- FALSE
  }

  expect_snapshot(info)
})
