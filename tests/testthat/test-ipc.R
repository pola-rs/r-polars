test_that("Test reading data from Apache Arrow IPC", {
  # This test requires library arrow
  skip_if_not_installed("arrow")

  # Put data in Apache Arrow IPC format
  tmpf <- tempfile()
  on.exit(unlink(tmpf))
  arrow::write_ipc_file(iris, tmpf)

  # Collect data from Apache Arrow IPC
  read_limit <- 27
  expect_equal(
    pl$scan_arrow_ipc(tmpf)$collect()$as_data_frame(),
    iris
  )
  expect_equal(
    pl$scan_arrow_ipc(tmpf, n_rows = read_limit)$collect()$as_data_frame(),
    droplevels(head(iris, read_limit))
  )
  expect_equal(
    as.integer(pl$scan_arrow_ipc(
      tmpf,
      n_rows = read_limit,
      row_count_name = "rc",
      row_count_offset = read_limit
    )$collect()$as_data_frame()$rc),
    read_limit:(2 * read_limit - 1)
  )

  # Test error handling
  expect_error(pl$scan_arrow_ipc(0))
  expect_error(pl$scan_arrow_ipc(tmpf, n_rows = "?"))
  expect_error(pl$scan_arrow_ipc(tmpf, cache = 0L))
  expect_error(pl$scan_arrow_ipc(tmpf, rechunk = list()))
  expect_error(pl$scan_arrow_ipc(tmpf, row_count_name = c("x", "y")))
  expect_error(pl$scan_arrow_ipc(tmpf, row_count_name = "name", row_count_offset = data.frame()))
  expect_error(pl$scan_arrow_ipc(tmpf, memmap = NULL))
})
