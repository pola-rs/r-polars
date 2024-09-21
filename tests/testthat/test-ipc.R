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


patrick::with_parameters_test_that("input/output DataFrame as raw vector",
  {
    df = as_polars_df(mtcars)

    raw_vec = df$to_raw_ipc(
      compression = compression,
      compat_level = TRUE
    )

    expect_true(
      df$equals(pl$read_ipc(raw_vec))
    )
  },
  compression = c("uncompressed", "lz4", "zstd"),
  .test_name = compression
)


test_that("scanning from hive partition works", {
  skip_if_not_installed("arrow")
  skip_if_not_installed("withr")
  temp_dir = withr::local_tempdir()
  arrow::write_dataset(
    mtcars,
    temp_dir,
    partitioning = c("cyl", "gear"),
    format = "arrow",
    hive_style = TRUE
  )

  # Passing a directory automatically enables hive partitioning reading
  # i.e. "cyl" and "gear" are in the data and the data is sorted by the
  # partitioning columns
  expect_identical(
    pl$scan_ipc(temp_dir)$select("mpg", "gear")$collect() |> as.data.frame(),
    mtcars[order(mtcars$cyl, mtcars$gear), c("mpg", "gear")],
    ignore_attr = TRUE
  )

  # hive_partitioning controls whether partitioning columns are included
  expect_identical(
    pl$scan_ipc(temp_dir, hive_partitioning = FALSE)$collect() |> dim(),
    c(32L, 9L)
  )

  # can use hive_schema for more fine grained control on partitioning columns
  sch = pl$scan_ipc(temp_dir, hive_schema = list(cyl = pl$String, gear = pl$Int32))$
    collect()$schema
  expect_true(sch$gear$is_integer())
  expect_true(sch$cyl$is_string())
  expect_grepl_error(
    pl$scan_ipc(temp_dir, hive_schema = list(cyl = "a"))
  )

  # cannot get a subset of partitioning columns
  expect_grepl_error(
    pl$scan_ipc(temp_dir, hive_schema = list(cyl = pl$String))$collect(),
    r"(path contains column not present in the given Hive schema: "gear")"
  )
})

test_that("try_parse_hive_dates works", {
  skip_if_not_installed("arrow")
  skip_if_not_installed("withr")
  temp_dir = withr::local_tempdir()
  test = data.frame(dt = as.Date(c("2020-01-01", "2020-01-01", "2020-01-02")), y = 1:3)
  arrow::write_dataset(
    test,
    temp_dir,
    partitioning = "dt",
    format = "arrow",
    hive_style = TRUE
  )

  # default is to parse dates
  expect_identical(
    pl$scan_ipc(temp_dir)$select("dt")$collect()$to_list(),
    list(dt = as.Date(c("2020-01-01", "2020-01-01", "2020-01-02")))
  )

  expect_identical(
    pl$scan_ipc(temp_dir, try_parse_hive_dates = FALSE)$select("dt")$collect()$to_list(),
    list(dt = c("2020-01-01", "2020-01-01", "2020-01-02"))
  )
})

test_that("scan_ipc can include file path", {
  skip_if_not_installed("arrow")
  skip_if_not_installed("withr")
  temp_dir = withr::local_tempdir()
  arrow::write_dataset(
    mtcars,
    temp_dir,
    partitioning = c("cyl", "gear"),
    format = "arrow",
    hive_style = TRUE
  )

  # There are 8 partitions so 8 file paths
  expect_identical(
    pl$scan_ipc(temp_dir, include_file_paths = "file_paths")$collect()$unique("file_paths") |>
      dim(),
    c(8L, 12L)
  )
})
