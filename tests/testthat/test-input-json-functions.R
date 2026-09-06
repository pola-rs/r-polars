test_that("read_ndjson: basic use", {
  skip_if_not_installed("jsonlite")
  ndjson_filename <- withr::local_tempfile()
  df <- data.frame(a = letters[1:3], b = c(1, 2.5, 3))
  jsonlite::stream_out(df, file(ndjson_filename), verbose = FALSE)
  expect_equal(
    pl$read_ndjson(ndjson_filename),
    as_polars_df(df)
  )
})

test_that("arg row_index_name works", {
  skip_if_not_installed("jsonlite")
  ndjson_filename <- withr::local_tempfile()
  df <- data.frame(a = letters[1:3], b = c(1, 2.5, 3))
  jsonlite::stream_out(df, file(ndjson_filename), verbose = FALSE)
  out <- pl$read_ndjson(ndjson_filename, row_index_name = "foo")
  expect_equal(
    out,
    pl$DataFrame(foo = 0:2, !!!df)$cast(foo = pl$UInt32)
  )
})

test_that("arg row_index_offset works", {
  skip_if_not_installed("jsonlite")
  ndjson_filename <- withr::local_tempfile()
  df <- data.frame(a = letters[1:3], b = c(1, 2.5, 3))
  jsonlite::stream_out(df, file(ndjson_filename), verbose = FALSE)
  out <- pl$read_ndjson(ndjson_filename, row_index_name = "foo", row_index_offset = 3)
  expect_equal(
    out,
    pl$DataFrame(foo = 3:5, !!!df)$cast(foo = pl$UInt32)
  )
})

test_that("arg n_rows works", {
  skip_if_not_installed("jsonlite")
  ndjson_filename <- withr::local_tempfile()
  df <- data.frame(a = letters[1:3], b = c(1, 2.5, 3))
  jsonlite::stream_out(df, file(ndjson_filename), verbose = FALSE)
  out <- pl$read_ndjson(ndjson_filename, n_rows = 1)
  expect_equal(dim(out), 1:2)
})

test_that("arg schema_overrides works", {
  skip_if_not_installed("jsonlite")
  ndjson_filename <- withr::local_tempfile()
  df <- data.frame(a = letters[1:3], b = c(1, 2.5, 3))
  jsonlite::stream_out(df, file(ndjson_filename), verbose = FALSE)
  out <- pl$read_ndjson(
    ndjson_filename,
    schema_overrides = list(a = pl$Categorical(), b = pl$Float32)
  )
  expect_equal(
    out,
    pl$DataFrame(a = factor(c("a", "b", "c")), b = c(1, 2.5, 3))$cast(b = pl$Float32)
  )
})

test_that("multiple paths works", {
  skip_if_not_installed("jsonlite")
  ndjson_filename <- withr::local_tempfile()
  ndjson_filename2 <- withr::local_tempfile()
  df <- data.frame(a = letters[1:3], b = c(1, 2.5, 3))
  jsonlite::stream_out(df, file(ndjson_filename), verbose = FALSE)
  jsonlite::stream_out(df, file(ndjson_filename2), verbose = FALSE)
  out <- pl$read_ndjson(c(ndjson_filename, ndjson_filename2))
  expect_equal(out, as_polars_df(rbind(df, df)))
})

# TODO: either uncomment or remove when https://github.com/pola-rs/polars/issues/18306
# is resolved
# test_that("multiple paths fails if different schema", {
#   skip_if_not_installed("jsonlite")
#   ndjson_filename = withr::local_tempfile()
#   ndjson_filename2 = withr::local_tempfile()
#   df = data.frame(a = letters[1:3], b = c(1, 2.5, 3))
#   jsonlite::stream_out(df, file(ndjson_filename), verbose = FALSE)
#   jsonlite::stream_out(iris, file(ndjson_filename2), verbose = FALSE)
#   expect_grepl_error(
#     pl$read_ndjson(c(ndjson_filename, ndjson_filename2)),
#     "lengths don't match"
#   )
# })

test_that("scan_ndjson/read_ndjson error", {
  expect_snapshot(pl$read_ndjson(character()), error = TRUE)
  # Error messages below are platform-dependent
  expect_error(pl$read_ndjson("foobar"), "os error 2")
  # `batch_size = 0` fails when converting to `NonZeroUsize`; the message
  # (from Rust's stdlib) differs across platforms / Rust versions.
  expect_error(pl$scan_ndjson("foo", batch_size = 0))
})

test_that("read/scan: arg 'file_cache_ttl' is deprecated", {
  tmpf <- withr::local_tempfile()
  writeLines('{"a": 1}', tmpf)

  expect_warning(
    pl$scan_ndjson(tmpf, file_cache_ttl = 10),
    "file cache is no longer supported",
    class = "polars_deprecation_warning"
  )
  expect_warning(
    pl$read_ndjson(tmpf, file_cache_ttl = 10),
    "file cache is no longer supported",
    class = "polars_deprecation_warning"
  )
  expect_no_condition(pl$scan_ndjson(tmpf))
  expect_no_condition(pl$read_ndjson(tmpf))

  captured <- NULL
  original <- get("PlRLazyFrame", asNamespace("polars"))$new_from_ndjson
  mock <- new.env(parent = emptyenv())
  mock$new_from_ndjson <- function(...) {
    captured <<- list(...)
    original(...)
  }
  testthat::local_mocked_bindings(PlRLazyFrame = mock, .package = "polars")

  expect_warning(
    pl$scan_ndjson(
      tmpf,
      file_cache_ttl = 10,
      storage_options = c(
        endpoint_url = "https://example.com",
        file_cache_ttl = "60"
      )
    ),
    "file cache is no longer supported",
    class = "polars_deprecation_warning"
  )
  expect_identical(
    captured$storage_options,
    c(endpoint_url = "https://example.com", file_cache_ttl = "60")
  )
})

test_that("read/scan: arg rechunk is deprecated", {
  tmpf <- withr::local_tempfile(fileext = ".ndjson")
  pl$DataFrame(a = 1:3)$write_ndjson(tmpf)

  expect_deprecated(pl$read_ndjson(tmpf, rechunk = TRUE))
  expect_deprecated(pl$scan_ndjson(tmpf, rechunk = TRUE))

  expect_no_condition(pl$read_ndjson(tmpf))

  local_lifecycle_silence()
  expect_equal(
    pl$read_ndjson(tmpf, rechunk = TRUE),
    pl$DataFrame(a = 1:3, .schema_overrides = list(a = pl$Int64))
  )
})
