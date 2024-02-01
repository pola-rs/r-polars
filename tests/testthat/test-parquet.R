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


test_that("scan read parquet - test arg rowcount", {
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  lf_exp = pl$LazyFrame(mtcars)
  lf_exp$sink_parquet(tmpf, compression = "snappy")
  df_exp = lf_exp$collect()$to_data_frame()

  expect_identical(
    pl$scan_parquet(tmpf, row_count_name = "rc", row_count_offset = 5)$collect()$to_data_frame(),
    data.frame(rc = as.numeric(5:36), df_exp)
  )

  expect_identical(
    pl$read_parquet(tmpf, row_count_name = "rc", row_count_offset = 5)$to_data_frame(),
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
  for (choice in c("auto", "COLUMNS", "None", "rowGroups")) {
    expect_identical(
      pl$read_parquet(tmpf, parallel = choice)$to_data_frame(),
      df_exp
    )
  }

  # bad parallel args
  ctx = pl$read_parquet(tmpf, parallel = "34") |> get_err_ctx()
  expect_true(startsWith(ctx$BadValue, "ParallelStrategy choice"))
  expect_identical(ctx$BadArgument, "parallel")
  ctx = pl$read_parquet(tmpf, parallel = 42) |> get_err_ctx()
  expect_identical(ctx$NotAChoice, "input is not a character vector")
})


test_that("write_paquet works", {
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
