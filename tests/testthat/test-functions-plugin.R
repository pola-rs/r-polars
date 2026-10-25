# A path that passes `.resolve_plugin_path` (exists) but is never opened, since
# expression construction and serialization do not load the library.
local_plugin_lib <- function() {
  path <- tempfile(fileext = ".so")
  file.create(path)
  path
}

test_that("pl$register_plugin_function() builds a plugin expression", {
  expr <- pl$register_plugin_function(
    plugin_path = local_plugin_lib(),
    function_name = "noop",
    args = pl$col("a")
  )
  expect_s3_class(expr, "polars_expr")
  expect_match(expr$meta$serialize(format = "json"), '"is_deterministic":\\s*true')
})

test_that("pl$register_plugin_function() executes a plugin with pickle kwargs", {
  plugin_path <- Sys.getenv("R_POLARS_TEST_PLUGIN_PATH")
  if (!nzchar(plugin_path)) {
    if (identical(Sys.getenv("R_POLARS_TEST_PLUGIN_REQUIRED"), "true")) {
      stop("R_POLARS_TEST_PLUGIN_PATH must be set for the plugin integration test.", call. = FALSE)
    }
    skip("Set R_POLARS_TEST_PLUGIN_PATH to the compiled plugin fixture.")
  }

  input <- pl$DataFrame(x = c(1L, NA_integer_, 3L))
  for (enabled in c(TRUE, FALSE)) {
    expr <- pl$register_plugin_function(
      plugin_path = plugin_path,
      function_name = "add_offset",
      args = pl$col("x")$cast(pl$Int64),
      kwargs = list(offset = 5L, enabled = enabled),
      is_elementwise = TRUE
    )
    expected <- pl$DataFrame(
      x = if (enabled) c(6L, NA_integer_, 8L) else c(1L, NA_integer_, 3L)
    )$cast(pl$Int64)
    expect_query_equal(.input$select(expr), input, expected)
  }
})

test_that("pl$register_plugin_function() expressions survive serialization", {
  # Requires the `ffi_plugin` feature; serialization does not open the library.
  for (is_deterministic in c(TRUE, FALSE)) {
    expr <- pl$register_plugin_function(
      plugin_path = local_plugin_lib(),
      function_name = "noop",
      args = pl$col("a"),
      kwargs = list(scale = 2L, wrap = TRUE, label = "adjusted"),
      is_deterministic = is_deterministic
    )
    expect_match(
      expr$meta$serialize(format = "json"),
      paste0('"is_deterministic":\\s*', tolower(as.character(is_deterministic)))
    )
    blob <- expr$meta$serialize(format = "binary")
    expect_no_error(roundtrip <- pl$deserialize_expr(blob))
    expect_s3_class(roundtrip, "polars_expr")
    expect_identical(roundtrip$meta$serialize(format = "binary"), blob)
  }
})

test_that("pl$register_plugin_function() accepts kwargs_raw as an escape hatch", {
  expr <- pl$register_plugin_function(
    plugin_path = local_plugin_lib(),
    function_name = "custom",
    args = pl$col("a"),
    kwargs_raw = as.raw(c(1, 2, 3))
  )
  expect_no_error(pl$deserialize_expr(expr$meta$serialize(format = "binary")))
})

test_that("pl$register_plugin_function() accepts nested lists and raw values", {
  expr <- pl$register_plugin_function(
    plugin_path = local_plugin_lib(),
    function_name = "f",
    args = list(pl$col("a"), pl$col("a") + 1),
    kwargs = list(
      nested = list(x = 1L, y = "z"),
      seq = list(1L, 2L, 3L),
      blob = as.raw(c(0, 255)),
      flag = FALSE
    ),
    is_elementwise = TRUE
  )
  expect_no_error(pl$deserialize_expr(expr$meta$serialize(format = "binary")))
})

test_that("plugin_path resolves a directory to its single library", {
  dir <- tempfile()
  dir.create(dir)
  file.create(file.path(dir, "plugin.so"))
  expect_s3_class(
    pl$register_plugin_function(dir, "f", pl$col("a")),
    "polars_expr"
  )

  empty <- tempfile()
  dir.create(empty)
  expect_error(
    pl$register_plugin_function(empty, "f", pl$col("a")),
    "No dynamic library"
  )

  file.create(file.path(dir, "plugin2.so"))
  expect_error(
    pl$register_plugin_function(dir, "f", pl$col("a")),
    "Multiple dynamic"
  )

  expect_error(
    pl$register_plugin_function("/no/such/path", "f", pl$col("a")),
    "No plugin file or directory"
  )
})

test_that("pl$register_plugin_function() validates its arguments", {
  lib <- local_plugin_lib()
  expect_error(
    pl$register_plugin_function(1, "f", pl$col("a")),
    "must be a single string"
  )
  expect_error(
    pl$register_plugin_function(lib, "f", pl$col("a"), is_elementwise = 1),
    "must be `TRUE` or `FALSE`"
  )
  expect_error(
    pl$register_plugin_function(lib, "f", pl$col("a"), is_deterministic = 1),
    "must be `TRUE` or `FALSE`"
  )
})

test_that("kwargs and kwargs_raw are mutually exclusive", {
  expect_error(
    pl$register_plugin_function(
      local_plugin_lib(),
      "f",
      pl$col("a"),
      kwargs = list(a = 1L),
      kwargs_raw = as.raw(1)
    ),
    "not both"
  )
})

test_that("kwargs rejects unsupported values", {
  reg <- function(kwargs) {
    pl$register_plugin_function("lib.so", "f", pl$col("a"), kwargs = kwargs)
  }
  expect_error(reg(integer()), "must be a named list")
  expect_error(reg(data.frame(a = 1)), "must be a named list")
  expect_error(reg(list(1L)), "fully named")
  expect_error(reg(list(a = 1L, "x")), "fully named")
  expect_error(reg(rlang::set_names(list(1L, 2L), c("a", "a"))), "unique names")
  expect_error(reg(list(a = NA_integer_)), "`NA`")
  expect_error(reg(list(a = c(1L, 2L))), "scalar")
  expect_error(reg(list(a = Inf)), "finite")
  expect_error(reg(list(a = factor("x"))), "unsupported class")
  expect_error(reg(list(a = as.Date("2020-01-01"))), "unsupported class")
  expect_error(reg(list(a = mean)), "unsupported type")
  expect_error(reg(list(a = list(1L, b = 2L))), "partially named")
})
