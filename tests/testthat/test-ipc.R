test_that("Test reading data from Apache Arrow IPC", {
  # This test requires library arrow
  skip_if_not_installed("arrow")

  # Put data in Apache Arrow IPC format
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  arrow::write_ipc_file(iris, tmpf, compression = "uncompressed")

  # Collect data from Apache Arrow IPC
  read_limit = 27
  expect_equal(
    pl$scan_ipc(tmpf)$collect()$to_data_frame(),
    iris
  )
  expect_equal(
    pl$scan_ipc(tmpf, n_rows = read_limit)$collect()$to_data_frame(),
    droplevels(head(iris, read_limit))
  )
  expect_equal(
    as.integer(pl$scan_ipc(
      tmpf,
      n_rows = read_limit,
      row_index_name = "rc",
      row_index_offset = read_limit
    )$collect()$to_data_frame()$rc),
    read_limit:(2 * read_limit - 1)
  )

  # Test error handling
  expect_grepl_error(pl$scan_ipc(0))
  expect_grepl_error(pl$scan_ipc(tmpf, n_rows = "?"))
  expect_grepl_error(pl$scan_ipc(tmpf, cache = 0L))
  expect_grepl_error(pl$scan_ipc(tmpf, rechunk = list()))
  expect_grepl_error(pl$scan_ipc(tmpf, row_index_name = c("x", "y")))
  expect_grepl_error(pl$scan_ipc(tmpf, row_index_name = "name", row_index_offset = data.frame()))
  expect_grepl_error(pl$scan_ipc(tmpf, memory_map = NULL))
})


patrick::with_parameters_test_that("write and read Apache Arrow file",
  {
    tmpf = tempfile(fileext = ".arrow")
    on.exit(unlink(tmpf))

    df = pl$DataFrame(
      int = 1:4,
      chr = letters[1:4],
      fct = factor(letters[1:4])
    )
    df$write_ipc(tmpf, compression = compression)

    expect_identical(
      as.data.frame(df),
      as.data.frame(pl$read_ipc(tmpf, memory_map = FALSE))
    )

    expect_warning(
      df$write_ipc(tmpf, compression = compression, future = TRUE),
      "considered unstable"
    )

    expect_true(
      df$equals(pl$read_ipc(tmpf, memory_map = FALSE))
    )
  },
  compression = list(NULL, "uncompressed", "lz4", "zstd"),
  .test_name = compression
)

test_that("write_ipc returns the input data", {
  dat = pl$DataFrame(mtcars)
  tmpf = tempfile(fileext = ".arrow")
  x = dat$write_ipc(tmpf)
  expect_identical(x$to_list(), dat$to_list())
})
