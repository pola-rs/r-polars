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
  out <- pl$read_ndjson(ndjson_filename,
    row_index_name = "foo",
    row_index_offset = 3
  )
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
  expect_snapshot(pl$read_ndjson("foobar"), error = TRUE)
  expect_snapshot(pl$scan_ndjson("foo", batch_size = 0), error = TRUE)
})
