test_that("plain scan read parquet", {
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  lf_exp = pl$LazyFrame(mtcars)
  lf_exp$sink_parquet(tmpf, compression = "snappy")
  df_exp = lf_exp$collect()$to_data_frame()

  # simple scan
  expect_identical(
    pl$scan_parquet(tmpf)$collect()$to_data_frame(),
    df_exp
  )

  # simple read
  expect_identical(
    pl$read_parquet(tmpf)$to_data_frame(),
    df_exp
  )
})


test_that("scan read parquet - test arg row_index", {
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  lf_exp = pl$LazyFrame(mtcars)
  lf_exp$sink_parquet(tmpf, compression = "snappy")
  df_exp = lf_exp$collect()$to_data_frame()

  expect_identical(
    pl$scan_parquet(tmpf, row_index_name = "rc", row_index_offset = 5)$collect()$to_data_frame(),
    data.frame(rc = as.numeric(5:36), df_exp)
  )

  expect_identical(
    pl$read_parquet(tmpf, row_index_name = "rc", row_index_offset = 5)$to_data_frame(),
    data.frame(rc = as.numeric(5:36), df_exp)
  )
})


test_that("scan read parquet - parallel strategies", {
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  lf_exp = pl$LazyFrame(mtcars)
  lf_exp$sink_parquet(tmpf, compression = "snappy")
  df_exp = lf_exp$collect()$to_data_frame()

  # check all parallel strategies produce same result
  for (choice in c("auto", "columns", "none", "row_groups")) {
    expect_identical(
      pl$read_parquet(tmpf, parallel = choice)$to_data_frame(),
      df_exp
    )
  }

  # bad parallel args
  expect_grepl_error(
    pl$read_parquet(tmpf, parallel = "34"),
    "must be one of 'auto', 'columns', 'row_groups', 'none'"
  )
  expect_grepl_error(
    pl$read_parquet(tmpf, parallel = 42),
    "input is not a character vector"
  )
})


test_that("write_parquet works", {
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  df_exp = pl$DataFrame(mtcars)
  df_exp$write_parquet(tmpf)

  expect_identical(
    pl$read_parquet(tmpf)$to_data_frame(),
    mtcars,
    ignore_attr = TRUE
  )
})

test_that("throw error if invalid compression is passed", {
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  df_exp = pl$DataFrame(mtcars)
  expect_grepl_error(
    df_exp$write_parquet(tmpf, compression = "invalid"),
    "Failed to set parquet compression method"
  )
})

test_that("write_parquet returns the input data", {
  dat = pl$DataFrame(mtcars)
  tmpf = tempfile()
  x = dat$write_parquet(tmpf)
  expect_identical(x$to_list(), dat$to_list())
})

test_that("write_parquet: argument 'statistics'", {
  dat = pl$DataFrame(mtcars)
  tmpf = tempfile()
  on.exit(unlink(tmpf))

  expect_silent(dat$write_parquet(tmpf, statistics = TRUE))
  expect_silent(dat$write_parquet(tmpf, statistics = FALSE))
  expect_silent(dat$write_parquet(tmpf, statistics = "full"))
  expect_grepl_error(
    dat$write_parquet(tmpf, statistics = list(null_count = FALSE)),
    "File out of specification: null count of a page is required"
  )
  expect_grepl_error(
    dat$write_parquet(tmpf, statistics = list(foo = TRUE, foo2 = FALSE)),
    "In `statistics`, `foo`, `foo2` are not valid keys"
  )
  expect_grepl_error(
    dat$write_parquet(tmpf, statistics = "foo"),
    "`statistics` must be TRUE/FALSE, 'full', or a named list."
  )
  expect_grepl_error(
    dat$write_parquet(tmpf, statistics = c(max = TRUE, min = FALSE)),
    "`statistics` must be of length 1."
  )
})
