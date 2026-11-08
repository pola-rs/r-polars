patrick::with_parameters_test_that(
  "partition functions work",
  .cases = {
    lf <- as_polars_lf(mtcars)
    sink_ipc <- function(...) lf$sink_ipc(..., compression = "zstd")
    sink_ipc_sorted <- function(...) {
      lf$sort("am", "cyl")$sink_ipc(..., compression = "zstd")
    }

    tibble::tribble(
      ~.test_name, ~fn, ~reader, ~fn_sorted,
      "sink_csv", lf$sink_csv, pl$read_csv, lf$sort("am", "cyl")$sink_csv,
      "sink_ipc", sink_ipc, pl$read_ipc, sink_ipc_sorted,
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
      compression = "zstd",
      mkdir = TRUE
    ),
    error = TRUE
  )
})

test_that("PartitionBy with only approximate_bytes_per_file works", {
  out_dir <- withr::local_tempdir()
  as_polars_lf(mtcars)$sink_parquet(
    pl$PartitionBy(out_dir, approximate_bytes_per_file = 1e9),
    mkdir = TRUE
  )

  expect_length(list.files(out_dir, recursive = TRUE), 1L)
  expect_shape(pl$read_parquet(out_dir), dim = c(32L, 11L))
})

test_that("PartitionBy with include_key = FALSE drops the key columns from the files", {
  out_dir <- withr::local_tempdir()
  as_polars_lf(mtcars)$sink_parquet(
    pl$PartitionBy(out_dir, key = "cyl", include_key = FALSE),
    mkdir = TRUE
  )

  file <- list.files(out_dir, pattern = "\\.parquet$", recursive = TRUE, full.names = TRUE)[[1]]
  expect_false("cyl" %in% pl$read_parquet(file, hive_partitioning = FALSE)$columns)
})

test_that("only PartitionBy objects of the polars package are accepted as the sink target", {
  # S7 classes defined outside of the polars package.
  # Specify `package` explicitly because the default is the package of the calling environment,
  # which is polars when the tests run.
  unnamed_pkg_class <- new_class(
    "PartitionBy",
    package = NULL,
    properties = list(base_path = class_character)
  )
  other_pkg_class <- new_class(
    "PartitionBy",
    package = "otherpkg",
    properties = list(base_path = class_character)
  )
  other_name_class <- new_class(
    "OtherScheme",
    package = "otherpkg",
    properties = list(base_path = class_character)
  )

  lf <- as_polars_lf(mtcars)
  out_dir <- withr::local_tempdir()

  # The public methods reject these objects before passing them to Rust.
  expect_snapshot(
    lf$sink_parquet(unnamed_pkg_class(out_dir)),
    error = TRUE
  )
  expect_snapshot(
    lf$sink_parquet(other_pkg_class(out_dir)),
    error = TRUE
  )
  expect_snapshot(
    lf$sink_parquet(other_name_class(out_dir)),
    error = TRUE
  )

  # The conversion on the Rust side must reject them as well.
  sink_ndjson_unchecked <- function(target) {
    lf$`_ldf`$sink_ndjson(
      target = target,
      compression = "uncompressed",
      compression_level = NULL,
      check_extension = TRUE,
      maintain_order = TRUE,
      sync_on_close = "none",
      mkdir = FALSE,
      storage_options = NULL
    )
  }

  expect_snapshot(sink_ndjson_unchecked(unnamed_pkg_class(out_dir)), error = TRUE)
  expect_snapshot(sink_ndjson_unchecked(other_pkg_class(out_dir)), error = TRUE)
  expect_snapshot(sink_ndjson_unchecked(other_name_class(out_dir)), error = TRUE)
  expect_snapshot(sink_ndjson_unchecked(pl$QueryOptFlags()), error = TRUE)

  # Nothing is written
  expect_length(list.files(out_dir), 0L)
})
