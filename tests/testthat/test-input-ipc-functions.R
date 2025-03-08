test_that("Test reading data from Apache Arrow file", {
  skip_if_not_installed("arrow")

  tmpf <- withr::local_tempfile()
  on.exit(unlink(tmpf))
  arrow::write_ipc_file(iris, tmpf, compression = "uncompressed")

  read_limit <- 27
  expect_equal(
    pl$scan_ipc(tmpf)$collect(),
    as_polars_df(iris)
  )
  expect_equal(
    pl$scan_ipc(tmpf, n_rows = read_limit)$collect(),
    as_polars_df(droplevels(head(iris, read_limit)))
  )
  expect_equal(
    pl$scan_ipc(
      tmpf,
      n_rows = read_limit,
      row_index_name = "rc",
      row_index_offset = read_limit
    )$collect()$select("rc"),
    pl$DataFrame(rc = 27:53)$cast(pl$UInt32)
  )

  # Test error handling
  expect_snapshot(pl$scan_ipc(character(0)), error = TRUE)
  expect_snapshot(pl$scan_ipc(0), error = TRUE)
  expect_snapshot(pl$scan_ipc(tmpf, n_rows = "?"), error = TRUE)
  expect_snapshot(pl$scan_ipc(tmpf, cache = 0L), error = TRUE)
  expect_snapshot(pl$scan_ipc(tmpf, rechunk = list()), error = TRUE)
  expect_snapshot(pl$scan_ipc(tmpf, storage_options = c("foo", "bar")), error = TRUE)
  expect_snapshot(
    pl$scan_ipc(tmpf, row_index_name = c("x", "y")),
    error = TRUE
  )
  expect_snapshot(
    pl$scan_ipc(tmpf, row_index_name = "name", row_index_offset = data.frame()),
    error = TRUE
  )

  expect_no_error(pl$scan_ipc("nonexistent.arrow"))
  expect_snapshot(
    pl$read_ipc("nonexistent.arrow"),
    error = TRUE
  )
})

# TODO-REWRITE: needs $to_raw_ipc()
# patrick::with_parameters_test_that("input/output DataFrame as raw vector",
#   {
#     df <- as_polars_df(mtcars)

#     raw_vec <- df$to_raw_ipc(
#       compression = compression,
#       compat_level = TRUE
#     )

#     expect_true(
#       df$equals(pl$read_ipc(raw_vec))
#     )
#   },
#   compression = c("uncompressed", "lz4", "zstd"),
#   .test_name = compression
# )

test_that("scanning from hive partition works", {
  skip_if_not_installed("arrow")
  temp_dir <- withr::local_tempdir()
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
    pl$scan_ipc(temp_dir)$select("mpg", "gear") |> as.data.frame(),
    mtcars[order(mtcars$cyl, mtcars$gear), c("mpg", "gear")],
    ignore_attr = TRUE
  )

  # hive_partitioning controls whether partitioning columns are included
  expect_identical(
    pl$scan_ipc(temp_dir, hive_partitioning = FALSE)$collect() |> dim(),
    c(32L, 9L)
  )

  # can use hive_schema for more fine grained control on partitioning columns
  sch <- pl$scan_ipc(
    temp_dir,
    hive_schema = list(cyl = pl$String, gear = pl$Int32)
  )$collect()$schema

  expect_true(sch$gear$is_integer())
  expect_s3_class(sch$cyl, "polars_dtype_string")

  expect_snapshot(
    pl$scan_ipc(temp_dir, hive_schema = list(cyl = "a")),
    error = TRUE
  )

  # cannot get a subset of partitioning columns
  expect_error(
    pl$scan_ipc(temp_dir, hive_schema = list(cyl = pl$String))$collect(),
    "field not found: path contains column not present in the given Hive schema"
  )
})

test_that("try_parse_hive_dates works", {
  skip_if_not_installed("arrow")
  temp_dir <- withr::local_tempdir()
  test <- data.frame(dt = as.Date(c("2020-01-01", "2020-01-01", "2020-01-02")), y = 1:3)
  arrow::write_dataset(
    test,
    temp_dir,
    partitioning = "dt",
    format = "arrow",
    hive_style = TRUE
  )

  # default is to parse dates
  expect_identical(
    pl$scan_ipc(temp_dir)$select("dt")$collect(),
    pl$DataFrame(dt = as.Date(c("2020-01-01", "2020-01-01", "2020-01-02")))
  )

  expect_identical(
    pl$scan_ipc(temp_dir, try_parse_hive_dates = FALSE)$select("dt")$collect(),
    pl$DataFrame(dt = c("2020-01-01", "2020-01-01", "2020-01-02"))
  )
})

test_that("scan_ipc can include file path", {
  skip_if_not_installed("arrow")
  temp_dir <- withr::local_tempdir()
  arrow::write_dataset(
    mtcars,
    temp_dir,
    partitioning = c("cyl", "gear"),
    format = "arrow",
    hive_style = TRUE
  )

  # There are 8 partitions so 8 file paths
  expect_identical(
    pl$scan_ipc(temp_dir, include_file_paths = "file_paths")$collect()$select("file_paths") |>
      as.data.frame() |>
      unique() |>
      nrow(),
    8L
  )
})

test_that("read_ipc_stream works", {
  skip_if_not_installed("nanoarrow")

  temp_file <- withr::local_tempfile()
  mtcars |>
    nanoarrow::write_nanoarrow(temp_file)

  expect_equal(
    pl$read_ipc_stream(temp_file),
    as_polars_df(mtcars)
  )
  expect_equal(
    pl$read_ipc_stream(temp_file, columns = c("cyl", "am")),
    as_polars_df(mtcars)$select("cyl", "am")
  )
  expect_equal(
    pl$read_ipc_stream(temp_file, n_rows = 5),
    as_polars_df(mtcars)$head(5)
  )
  expect_equal(
    pl$read_ipc_stream(temp_file, row_index_name = "foo", columns = "cyl"),
    as_polars_df(mtcars)$select(foo = pl$lit(0:31, pl$UInt32), "cyl")
  )
  expect_equal(
    pl$read_ipc_stream(temp_file, row_index_name = "foo", row_index_offset = 1, columns = "cyl"),
    as_polars_df(mtcars)$select(foo = pl$lit(1:32, pl$UInt32), "cyl")
  )
})
