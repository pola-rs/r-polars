test_that("write_json: path works", {
  skip_if_not_installed("jsonlite")
  dat <- as_polars_df(mtcars[1:5, 1:3])
  tmpf <- withr::local_tempfile()

  dat$write_json(tmpf)
  expect_snapshot_file(tmpf, name = "write_json_output", transform = \(x) c(x, ""))

  expect_equal(
    jsonlite::fromJSON(tmpf),
    as.data.frame(dat)
  )
})

test_that("write_json returns the input data", {
  dat <- as_polars_df(mtcars[1:5, 1:3])
  tmpf <- withr::local_tempfile()
  x <- dat$write_json(tmpf)
  expect_equal(dat, x)
})

test_that("write_ndjson: path works", {
  dat <- as_polars_df(mtcars[1:5, 1:3])
  tmpf <- withr::local_tempfile()
  dat$write_ndjson(tmpf)
  expect_equal(pl$read_ndjson(tmpf), dat)
})

test_that("write_ndjson returns the input data", {
  dat <- as_polars_df(mtcars[1:5, 1:3])
  tmpf <- withr::local_tempfile()
  x <- dat$write_ndjson(tmpf)
  expect_snapshot_file(tmpf, name = "write_ndjson_output", transform = \(x) c(x, ""))

  expect_equal(dat, x)
})
