test_that("without library(polars)", {
  # calling sort("mpg") triggers rust to call pl$lit() which will be available even though
  # polars is not added to serach with search() library(polars)
  skip_if_not_installed("callr")
  # positive test:
  # Will work because robj_to! now calls polars::pl$lit and polars::pl$col
  expect_identical(
    callr::r(\() {
      polars::pl$DataFrame(mtcars)$sort("mpg")$to_list()
    }),
    polars::pl$DataFrame(mtcars)$sort("mpg")$to_list()
  )

  # Negative control:
  # This will fail because test_wrong_call_pl_lit just uses pl$col and pl$lit
  expect_false(
    callr::r(\() polars:::test_wrong_call_pl_lit(42) |> polars:::is_ok())
  )

  # Positive-Negative control
  # This works because library(polars) puts polars in search()
  expect_true(polars:::test_wrong_call_pl_lit(42) |> polars:::is_ok())
})




test_that("scan read parquet from other process", {
  skip_if_not_installed("callr")

  tmpf = tempfile()
  on.exit(unlink(tmpf))
  lf_exp = polars::pl$LazyFrame(mtcars)
  lf_exp$sink_parquet(tmpf, compression = "snappy")
  df_exp = lf_exp$collect()$to_data_frame()

  # simple scan
  expect_identical(
    callr::r(\(tmpf) polars::pl$scan_parquet(tmpf)$collect()$to_data_frame(), args = list(tmpf = tmpf)),
    df_exp
  )

  # simple read
  expect_identical(
    callr::r(\(tmpf) polars::pl$read_parquet(tmpf)$to_data_frame(), args = list(tmpf = tmpf)),
    df_exp
  )
})
