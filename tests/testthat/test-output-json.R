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

test_that("sink_ndjson returns the input data", {
  dat <- as_polars_lf(mtcars[1:5, 1:3])
  tmpf <- withr::local_tempfile()
  expect_null(dat$sink_ndjson(tmpf))
  expect_snapshot_file(tmpf, name = "sink_ndjson_output.txt")
})
