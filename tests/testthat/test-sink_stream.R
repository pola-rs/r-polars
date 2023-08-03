  lf = pl$LazyFrame(mtcars)$with_columns((pl$col("mpg") * 0.425)$alias("kpl"))
  rdf = lf$collect()$to_data_frame()
test_that("Test sinking data to parquet file", {
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  expect_error(pl$sink_parquet(tmpf, compression = "rar"))
  lf$sink_parquet(tmpf)
  expect_equal(pl$scan_parquet(tmpf)$collect()$to_data_frame(), rdf)
})

test_that("Test sinking data to parquet file", {
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  lf$sink_ipc(tmpf)
  expect_error(pl$sink_ipc(tmpf, compression = "rar"))
  expect_equal(pl$scan_ipc(tmpf, memmap = FALSE)$collect()$to_data_frame(), rdf)


  #update with new data
  lf$slice(5,5)$sink_ipc(tmpf)
  expect_equal(
    pl$scan_ipc(tmpf, memmap = FALSE)$collect()$to_data_frame(),
    lf$slice(5,5)$collect()$to_data_frame()
  )
  lf$sink_ipc(tmpf)

  #from another process
  rdf_callr = callr::r(\(tmpf) {
    library(polars)
    pl$scan_ipc(tmpf, memmap = FALSE)$collect()$to_data_frame()
  }, args = list(tmpf=tmpf))
  expect_equal(rdf_callr, rdf)


  #TODO after polars in_background  is merged something like this should be possible
  # f_ipc_to_s = \(s) {
  #   pl$scan_ipc(s$to_r(), memmap = FALSE)$
  #     select(pl$struct(pl$all()))$
  #     collect()$
  #     to_series()
  # }
  # rdf_in_bg = pl$LazyFrame()$
  #   select(pl$lit(tmpf)$map(f_ipc_to_s,in_background=TRUE))$
  #   collect()$
  #   unnest()
  # expect_equal(rdf_in_bg, rdf)

})
