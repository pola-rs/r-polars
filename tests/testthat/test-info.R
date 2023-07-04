patrick::with_parameters_test_that("polars_info() features are logical",
  {
    expect_type(feature, "logical")
    expect_length(feature, 1)
  },
  feature = pl$polars_info()$features
)


## TODO DISABLE TEST FOR NOW AS IT WILL FAIL FOR EVERY VERSION INCREMENT

# test_that("print polars_info()", {
#
#
#   info <- polars_info()
#   # Ensure all features are FALSE for snapshot test
#   for (feature in names(info$features)) {
#     info$features[[feature]] <- FALSE
#   }
#
#   expect_snapshot(info)
# })
