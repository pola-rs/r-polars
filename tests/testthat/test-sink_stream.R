  lf = pl$LazyFrame(mtcars)$with_columns((pl$col("mpg") * 0.425)$alias("kpl"))
  rdf = lf$collect()$to_data_frame()
test_that("Test sinking data to parquet file", {
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  lf$sink_parquet(tmpf)
  expect_equal(pl$scan_parquet(tmpf)$collect()$to_data_frame(), rdf)
  expect_error(pl$sink_parquet(tmpf, compression = "rar"))
})

test_that("Test sinking data to parquet file", {
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  lf$sink_ipc(tmpf)
  expect_equal(pl$scan_arrow_ipc(tmpf, memmap = FALSE)$collect()$to_data_frame(), rdf)
  expect_error(pl$sink_ipc(tmpf, compression = "rar"))
})
