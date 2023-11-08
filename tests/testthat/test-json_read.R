test_that("read_ndjson: basic use", {
  skip_if_not_installed("jsonlite")
  ndjson_filename = tempfile()
  df = data.frame(a = letters[1:3], b = c(1, 2.5, 3))
  jsonlite::stream_out(df, file(ndjson_filename), verbose = FALSE)
  expect_identical(
    pl$read_ndjson(ndjson_filename)$to_data_frame(),
    df
  )
})

test_that("arg row_count_name works", {
  skip_if_not_installed("jsonlite")
  ndjson_filename = tempfile()
  df = data.frame(a = letters[1:3], b = c(1, 2.5, 3))
  jsonlite::stream_out(df, file(ndjson_filename), verbose = FALSE)
  out = pl$read_ndjson(ndjson_filename, row_count_name = "foo")$to_data_frame()
  expect_identical(
    out$foo,
    c(0, 1, 2)
  )
})

test_that("arg row_count_offset works", {
  skip_if_not_installed("jsonlite")
  ndjson_filename = tempfile()
  df = data.frame(a = letters[1:3], b = c(1, 2.5, 3))
  jsonlite::stream_out(df, file(ndjson_filename), verbose = FALSE)
  out = pl$read_ndjson(ndjson_filename, row_count_name = "foo",
                       row_count_offset = 3)$to_data_frame()
  expect_identical(
    out$foo,
    c(3, 4, 5)
  )
})

test_that("arg n_rows works", {
  skip_if_not_installed("jsonlite")
  ndjson_filename = tempfile()
  df = data.frame(a = letters[1:3], b = c(1, 2.5, 3))
  jsonlite::stream_out(df, file(ndjson_filename), verbose = FALSE)
  out = pl$read_ndjson(ndjson_filename, n_rows = 1)$to_data_frame()
  expect_identical(dim(out), 1:2)
})

test_that("multiple paths works", {
  skip_if_not_installed("jsonlite")
  ndjson_filename = tempfile()
  ndjson_filename2 = tempfile()
  df = data.frame(a = letters[1:3], b = c(1, 2.5, 3))
  jsonlite::stream_out(df, file(ndjson_filename), verbose = FALSE)
  jsonlite::stream_out(df, file(ndjson_filename2), verbose = FALSE)
  out = pl$read_ndjson(c(ndjson_filename, ndjson_filename2))$to_data_frame()
  expect_identical(out, rbind(df, df))
})

test_that("multiple paths fails if different schema", {
  skip_if_not_installed("jsonlite")
  ndjson_filename = tempfile()
  ndjson_filename2 = tempfile()
  df = data.frame(a = letters[1:3], b = c(1, 2.5, 3))
  jsonlite::stream_out(df, file(ndjson_filename), verbose = FALSE)
  jsonlite::stream_out(iris, file(ndjson_filename2), verbose = FALSE)
  expect_error(
    pl$read_ndjson(c(ndjson_filename, ndjson_filename2)),
    "lengths don't match"
  )
})

test_that("bad paths", {
   ctx = pl$read_ndjson(character()) |> get_err_ctx()
   expect_identical(
     c(ctx$BadArgument, ctx$PlainErrorMessage),
     c("path", "path cannot have zero length")
   )
  expect_error(
    pl$read_ndjson("not a valid path"),
    "failed to locate file"
  )
})
