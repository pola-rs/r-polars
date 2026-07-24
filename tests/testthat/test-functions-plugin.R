test_that("pl$register_plugin_function() builds a plugin expression", {
  expr <- pl$register_plugin_function(
    plugin_path = "/nonexistent/libplugin.so",
    function_name = "noop",
    args = pl$col("a")
  )
  expect_s3_class(expr, "polars_expr")
})

test_that("pl$register_plugin_function() expressions survive serialization", {
  # Requires the `ffi_plugin` feature; serialization does not open the library.
  expr <- pl$register_plugin_function(
    plugin_path = "/nonexistent/libplugin.so",
    function_name = "noop",
    args = pl$col("a"),
    kwargs_raw = as.raw(c(1, 2, 3))
  )
  blob <- expr$meta$serialize(format = "binary")
  expect_no_error(roundtrip <- pl$deserialize_expr(blob))
  expect_s3_class(roundtrip, "polars_expr")
  expect_identical(roundtrip$meta$serialize(format = "binary"), blob)
})

test_that("pl$register_plugin_function() accepts multiple args and flags", {
  expr <- pl$register_plugin_function(
    plugin_path = "/x.so",
    function_name = "combine",
    args = list(pl$col("a"), pl$col("a") + 1),
    is_elementwise = TRUE,
    returns_scalar = FALSE
  )
  expect_s3_class(expr, "polars_expr")
  expect_no_error(
    pl$deserialize_expr(expr$meta$serialize(format = "binary"))
  )
})

test_that("pl$register_plugin_function() validates its arguments", {
  expect_error(
    pl$register_plugin_function(1, "f", pl$col("a")),
    "must be a single string"
  )
  expect_error(
    pl$register_plugin_function("lib.so", NULL, pl$col("a")),
    "must be a single string"
  )
  expect_error(
    pl$register_plugin_function("lib.so", "f", pl$col("a"), is_elementwise = 1),
    "must be `TRUE` or `FALSE`"
  )
  expect_error(
    pl$register_plugin_function("lib.so", "f", pl$col("a"), kwargs_raw = "oops"),
    "must be a raw vector or `NULL`"
  )
})
