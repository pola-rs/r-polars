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
    # TODO: use expect_shape() after testthat 3.3 is released
    expected_dim <- c(32L, 11L)

    out_by_key <- withr::local_tempdir()
    fn(pl$PartitionByKey(out_by_key, by = c("am", "cyl")), mkdir = TRUE)
    expect_snapshot(list.files(out_by_key, recursive = TRUE))
    expect_identical(
      reader(out_by_key) |> dim(),
      expected_dim
    )

    out_max_size <- withr::local_tempdir()
    fn(pl$PartitionMaxSize(out_max_size, max_size = 5), mkdir = TRUE)
    expect_snapshot(list.files(out_max_size, recursive = TRUE))
    expect_identical(
      reader(out_max_size) |> dim(),
      expected_dim
    )

    out_parted <- withr::local_tempdir()
    fn(pl$PartitionParted(out_parted, by = c("am", "cyl")), mkdir = TRUE)
    expect_snapshot(list.files(out_parted, recursive = TRUE))
    # Wrong output if keys are not sorted first
    expect_identical(
      reader(out_parted) |> dim(),
      c(10L, 11L)
    )

    out_parted_sorted <- withr::local_tempdir()
    fn_sorted(pl$PartitionParted(out_parted_sorted, by = c("am", "cyl")), mkdir = TRUE)
    expect_identical(
      reader(out_parted_sorted) |> dim(),
      expected_dim
    )
  }
)
