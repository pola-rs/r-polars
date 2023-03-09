test_that("Test reading data from Apache Arrow IPC", {

  # Put data in Apache Arrow IPC format
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  arrow::write_ipc_file(iris, tmpf)

  # Collect data from Apache Arrow IPC
  iris_ipc = pl$scan_arrow_ipc(tmpf)$collect()$as_data_frame()
  testthat::expect_equal(
    iris_ipc,
    iris
  )

  # Test error handling
  testthat::expect_error(pl$scan_arrow_ipc(0))
  testthat::expect_error(pl$scan_arrow_ipc(tmpf, n_rows = "?"))
  testthat::expect_error(pl$scan_arrow_ipc(tmpf, cache = 0L))
  testthat::expect_error(pl$scan_arrow_ipc(tmpf, rechunk = list()))
  testthat::expect_error(pl$scan_arrow_ipc(tmpf, row_count_name = c("x", "y")))
  testthat::expect_error(pl$scan_arrow_ipc(tmpf, row_count_name = "name", row_count_offset = data.frame()))
  testthat::expect_error(pl$scan_arrow_ipc(tmpf, memmap = NULL))

})
