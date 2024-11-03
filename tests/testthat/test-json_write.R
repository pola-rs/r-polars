dat = head(mtcars, n = 5)[, 1:3]
dat_pl = pl$DataFrame(dat)
temp_out = tempfile()

test_that("write_json: path works", {
  skip_if_not_installed("jsonlite")
  dat_pl$write_json(temp_out)
  expect_snapshot_file(temp_out)

  dat_pl$write_json(temp_out, row_oriented = TRUE)
  expect_identical(
    jsonlite::fromJSON(temp_out),
    dat,
    ignore_attr = TRUE # rownames are lost when writing / reading from json
  )
})

test_that("write_ndjson: path works", {
  dat_pl$write_ndjson(temp_out)
  expect_identical(
    pl$read_ndjson(temp_out)$to_data_frame(),
    dat,
    ignore_attr = TRUE # rownames are lost when writing / reading from json
  )
})

test_that("write_ndjson returns the input data", {
  dat = as_polars_df(mtcars)
  tmpf = tempfile(fileext = ".arrow")
  x = dat$write_ndjson(tmpf)
  expect_identical(x$to_list(), dat$to_list())
})
