test_that("deprecate_warn() carries polars_warning class hierarchy", {
  local_lifecycle_warnings()
  cnd <- tryCatch(
    deprecate_warn("foo() is deprecated"),
    polars_deprecation_warning = function(cnd) cnd
  )
  expect_s3_class(cnd, "lifecycle_warning_deprecated")
  expect_s3_class(cnd, "polars_deprecation_warning")
  expect_s3_class(cnd, "polars_warning")
})
