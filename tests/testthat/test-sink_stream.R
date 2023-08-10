lf = pl$LazyFrame(mtcars)$with_columns((pl$col("mpg") * 0.425)$alias("kpl"))
rdf = lf$collect()$to_data_frame()

test_that("Test sinking data to parquet file", {
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  expect_error(lf$sink_parquet(tmpf, compression = "rar"))
  lf$sink_parquet(tmpf)
  expect_equal(pl$scan_parquet(tmpf)$collect()$to_data_frame(), rdf)
})

test_that("Test sinking data to parquet file", {
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  lf$sink_ipc(tmpf)
  expect_error(lf$sink_ipc(tmpf, compression = "rar"))
  expect_identical(pl$scan_ipc(tmpf, memmap = FALSE)$collect()$to_data_frame(), rdf)


  # update with new data
  lf$slice(5, 5)$sink_ipc(tmpf)
  expect_equal(
    pl$scan_ipc(tmpf, memmap = FALSE)$collect()$to_data_frame(),
    lf$slice(5, 5)$collect()$to_data_frame()
  )
  lf$sink_ipc(tmpf)

  # from another process via rcall
  rdf_callr = callr::r(\(tmpf) {
    polars::pl$scan_ipc(tmpf, memmap = FALSE)$collect()$to_data_frame()
  }, args = list(tmpf = tmpf))
  expect_identical(rdf_callr, rdf)


  # from another process via rpool
  f_ipc_to_s = \(s) {
    polars::pl$scan_ipc(s$to_r(), memmap = FALSE)$
      select(polars::pl$struct(polars::pl$all()))$
      collect()$
      to_series()
  }
  pl$set_global_rpool_cap(4)
  rdf_in_bg = pl$LazyFrame()$
    select(pl$lit(tmpf)$map(f_ipc_to_s, in_background = TRUE))$
    collect()$
    unnest()
  expect_identical(rdf_in_bg$to_data_frame(), rdf)
})




# test_that("chunks persists - NOT", {
#
#   tmpf = tempfile()
#   on.exit(unlink(tmpf))
#   df = pl$DataFrame(a=1:1000)
#   df$lazy()$sink_parquet(tmpf,row_group_size = 4)
#
#   #always n cpu chunks it seems, not reproducible across machines
#   df2 = pl$scan_parquet(tmpf)$collect()
#
#   expect_identical(
#     df2$to_series()$chunk_lengths(),
#     rep(125,8)
#   )
# })
