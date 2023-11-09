tmpf = tempfile()
on.exit(unlink(tmpf))
lf_exp = pl$LazyFrame(mtcars)
lf_exp$sink_parquet(tmpf, compression = "snappy")
df_exp = lf_exp$collect()$to_data_frame()

test_that("scan read parquet", {
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

  # with row count
  expect_identical(
    pl$read_parquet(tmpf, row_count_name = "rc", row_count_offset = 5)$to_data_frame(),
    data.frame(rc = as.numeric(5:36), df_exp)
  )

  # check all parallel strategies work
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
