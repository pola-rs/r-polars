test_that("Test reading data from ipc", {
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  arrow::write_ipc_file(iris, tmpf)
  iris_ipc = scan_ipc(tmpf)$collect()$as_data_frame()
  testthat::expect_equal(
    iris_ipc,
    iris
  )
})
