patrick::with_parameters_test_that(
  "polars_info() features are logical",
  {
    expect_type(feature, "logical")
    expect_length(feature, 1)
  },
  feature = polars_info()$features
)

test_that("print polars_info()", {
  with_mocked_bindings(
    {
      expect_snapshot(polars_info())
    },
    .self_version = "0.0.0",
    rust_polars_version = function() "0.0.0",
    thread_pool_size = function() 1L,
    feature_nightly_enabled = function() TRUE
  )
})
