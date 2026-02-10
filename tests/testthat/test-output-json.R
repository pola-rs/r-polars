test_that("write_json: path works", {
  skip_if_not_installed("jsonlite")
  dat <- as_polars_df(mtcars[1:5, 1:3])
  tmpf <- withr::local_tempfile()

  expect_null(dat$write_json(tmpf))
  expect_snapshot_file(tmpf, name = "write_json_output.txt")

  expect_equal(
    jsonlite::fromJSON(tmpf),
    as.data.frame(dat)
  )
})

test_that("write_ndjson: path works", {
  dat <- as_polars_df(mtcars[1:5, 1:3])
  tmpf <- withr::local_tempfile()
  expect_null(dat$write_ndjson(tmpf))
  expect_equal(pl$read_ndjson(tmpf), dat)
})

test_that("sink_ndjson: path works", {
  dat <- as_polars_lf(mtcars[1:5, 1:3])
  tmpf <- withr::local_tempfile()
  expect_null(dat$sink_ndjson(tmpf))
  expect_equal(pl$read_ndjson(tmpf), dat$collect())
})

test_that("lazy_sink_ndjson works", {
  temp_out <- withr::local_tempfile()
  lf <- as_polars_lf(mtcars)$lazy_sink_ndjson(temp_out)

  expect_snapshot(lf$explain() |> cat())
  expect_snapshot(lf$collect())
  expect_equal(pl$read_ndjson(temp_out), as_polars_df(mtcars))
})

test_that("sink_ndjson returns the input data", {
  dat <- as_polars_lf(mtcars[1:5, 1:3])
  tmpf <- withr::local_tempfile()
  expect_null(dat$sink_ndjson(tmpf))
  expect_snapshot_file(tmpf, name = "sink_ndjson_output.txt")
})

test_that("write_ndjson can export compressed data", {
  dat <- as_polars_df(mtcars[1:5, 1:3])

  tmpf <- withr::local_tempfile(fileext = ".ndjson.zst")
  dat$write_ndjson(tmpf, compression = "zstd")
  expect_equal(dat, pl$read_ndjson(tmpf))

  tmpf <- withr::local_tempfile(fileext = ".ndjson.gz")
  dat$write_ndjson(tmpf, compression = "gzip")
  expect_equal(dat, pl$read_ndjson(tmpf))
})

test_that("sink_ndjson can export compressed data", {
  dat <- as_polars_lf(mtcars[1:5, 1:3])

  tmpf <- withr::local_tempfile(fileext = ".ndjson.zst")
  dat$sink_ndjson(tmpf, compression = "zstd")
  expect_equal(dat$collect(), pl$read_ndjson(tmpf))

  tmpf <- withr::local_tempfile(fileext = ".ndjson.gz")
  dat$sink_ndjson(tmpf, compression = "gzip")
  expect_equal(dat$collect(), pl$read_ndjson(tmpf))
})

test_that("error if wrong compression extension", {
  dat <- as_polars_lf(mtcars[1:5, 1:3])
  tmpf <- withr::local_tempfile(fileext = ".foo")

  expect_error(
    dat$sink_ndjson(tmpf, compression = "zstd"),
    "does not conform to standard naming"
  )
  expect_error(
    dat$sink_ndjson(tmpf, compression = "gzip"),
    "does not conform to standard naming"
  )

  tmpf <- withr::local_tempfile(fileext = ".gz")
  expect_snapshot(
    dat$sink_ndjson(tmpf),
    error = TRUE
  )
})

test_that("arg check_extension works", {
  dat <- as_polars_lf(mtcars[1:5, 1:3])
  tmpf <- withr::local_tempfile(fileext = ".foo")

  dat$sink_ndjson(tmpf, compression = "zstd", check_extension = FALSE)
  expect_equal(dat$collect(), pl$read_ndjson(tmpf))

  dat$sink_ndjson(tmpf, compression = "gzip", check_extension = FALSE)
  expect_equal(dat$collect(), pl$read_ndjson(tmpf))
})
