patrick::with_parameters_test_that(
  "partition functions work",
  .cases = {
    lf <- as_polars_lf(mtcars)

    tibble::tribble(
      ~.test_name, ~fn, ~reader, ~fn_sorted,
      "sink_csv", lf$sink_csv, pl$read_csv, lf$sort("am", "cyl")$sink_csv,
      "sink_ipc", lf$sink_ipc, pl$read_ipc, lf$sort("am", "cyl")$sink_ipc,
      "sink_ndjson", lf$sink_ndjson, pl$read_ndjson, lf$sort("am", "cyl")$sink_ndjson,
      "sink_parquet", lf$sink_parquet, pl$read_parquet, lf$sort("am", "cyl")$sink_parquet,
    )
  },
  code = {
    expected_dim <- c(32L, 11L)

    out_by_key <- withr::local_tempdir()
    fn(pl$PartitionBy(out_by_key, key = c("am", "cyl")), mkdir = TRUE)
    expect_snapshot(list.files(out_by_key, recursive = TRUE))
    expect_shape(
      reader(out_by_key),
      dim = expected_dim
    )

    out_max_size <- withr::local_tempdir()
    fn(pl$PartitionBy(out_max_size, max_rows_per_file = 5), mkdir = TRUE)
    expect_snapshot(list.files(out_max_size, recursive = TRUE))
    expect_shape(
      reader(out_max_size),
      dim = expected_dim
    )

    out_parted <- withr::local_tempdir()
    fn(pl$PartitionBy(out_parted, key = c("am", "cyl")), mkdir = TRUE)
    expect_snapshot(list.files(out_parted, recursive = TRUE))
    expect_shape(
      reader(out_parted),
      dim = expected_dim
    )
  }
)

test_that("approximate_bytes_per_file does not support 2^64 - 1 for now", {
  out_max_size_max <- withr::local_tempdir()
  expect_snapshot(
    as_polars_lf(mtcars)$sink_ipc(
      pl$PartitionBy(out_max_size_max, max_rows_per_file = 2^64 - 1),
      mkdir = TRUE
    ),
    error = TRUE
  )
})

patrick::with_parameters_test_that(
  "deprecated partition functions work",
  .cases = {
    lf <- as_polars_lf(mtcars)

    # Only tests sink_ipc for simplicity
    tibble::tribble(
      ~.test_name, ~fn, ~reader, ~fn_sorted,
      "sink_ipc", lf$sink_ipc, pl$read_ipc, lf$sort("am", "cyl")$sink_ipc,
    )
  },
  code = {
    expected_dim <- c(32L, 11L)

    out_by_key <- withr::local_tempdir()
    expect_snapshot({
      partition_by_key <- pl$PartitionByKey(out_by_key, by = c("am", "cyl"))
    })
    fn(partition_by_key, mkdir = TRUE)
    expect_snapshot(list.files(out_by_key, recursive = TRUE))
    expect_shape(
      reader(out_by_key),
      dim = expected_dim
    )

    out_max_size <- withr::local_tempdir()
    expect_snapshot({
      partition_max_size <- pl$PartitionMaxSize(out_max_size, max_size = 5)
    })
    fn(partition_max_size, mkdir = TRUE)
    expect_snapshot(list.files(out_max_size, recursive = TRUE))
    expect_shape(
      reader(out_max_size),
      dim = expected_dim
    )

    out_parted <- withr::local_tempdir()

    expect_snapshot({
      partition_parted <- pl$PartitionParted(out_parted, by = c("am", "cyl"))
    })
    fn(partition_parted, mkdir = TRUE)
    expect_snapshot(list.files(out_parted, recursive = TRUE))
    expect_shape(
      reader(out_parted),
      dim = expected_dim
    )
  }
)
