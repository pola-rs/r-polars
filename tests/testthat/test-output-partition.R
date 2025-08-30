test_that("pl$PartitionByKey() works", {
  my_lf <- as_polars_lf(mtcars)

  out_path <- withr::local_tempdir()
  my_lf$sink_csv(pl$PartitionByKey(out_path, by = c("am", "cyl")), mkdir = TRUE)
  expect_snapshot(list.files(out_path, recursive = TRUE))

  out_path <- withr::local_tempdir()
  my_lf$sink_ipc(pl$PartitionByKey(out_path, by = c("am", "cyl")), mkdir = TRUE)
  expect_snapshot(list.files(out_path, recursive = TRUE))

  out_path <- withr::local_tempdir()
  my_lf$sink_ndjson(
    pl$PartitionByKey(out_path, by = c("am", "cyl")),
    mkdir = TRUE
  )
  expect_snapshot(list.files(out_path, recursive = TRUE))

  out_path <- withr::local_tempdir()
  my_lf$sink_parquet(
    pl$PartitionByKey(out_path, by = c("am", "cyl")),
    mkdir = TRUE
  )
  expect_snapshot(list.files(out_path, recursive = TRUE))
})

test_that("pl$PartitionMaxSize() works", {
  my_lf <- as_polars_lf(mtcars)

  out_path <- withr::local_tempdir()
  my_lf$sink_csv(pl$PartitionMaxSize(out_path, max_size = 5), mkdir = TRUE)
  expect_snapshot(list.files(out_path, recursive = TRUE))

  out_path <- withr::local_tempdir()
  my_lf$sink_ipc(pl$PartitionMaxSize(out_path, max_size = 5), mkdir = TRUE)
  expect_snapshot(list.files(out_path, recursive = TRUE))

  out_path <- withr::local_tempdir()
  my_lf$sink_ndjson(
    pl$PartitionMaxSize(out_path, max_size = 5),
    mkdir = TRUE
  )
  expect_snapshot(list.files(out_path, recursive = TRUE))

  out_path <- withr::local_tempdir()
  my_lf$sink_parquet(
    pl$PartitionMaxSize(out_path, max_size = 5),
    mkdir = TRUE
  )
  expect_snapshot(list.files(out_path, recursive = TRUE))
})

test_that("pl$PartitionParted() works", {
  my_lf <- as_polars_lf(mtcars)

  # Wrong output if keys are not sorted first
  out_path <- withr::local_tempdir()
  my_lf$sink_csv(pl$PartitionParted(out_path, by = c("am", "cyl")), mkdir = TRUE)
  expect_equal(dim(pl$read_csv(out_path)), c(10, 11))

  # Correct output if keys are sorted first
  my_lf <- my_lf$sort("am", "cyl")
  out_path <- withr::local_tempdir()
  my_lf$sink_csv(pl$PartitionParted(out_path, by = c("am", "cyl")), mkdir = TRUE)
  expect_equal(pl$read_csv(out_path), my_lf$collect())

  # Other checks for file paths
  out_path <- withr::local_tempdir()
  my_lf$sink_ipc(pl$PartitionParted(out_path, by = c("am", "cyl")), mkdir = TRUE)
  expect_snapshot(list.files(out_path, recursive = TRUE))

  out_path <- withr::local_tempdir()
  my_lf$sink_ndjson(
    pl$PartitionParted(out_path, by = c("am", "cyl")),
    mkdir = TRUE
  )
  expect_snapshot(list.files(out_path, recursive = TRUE))

  out_path <- withr::local_tempdir()
  my_lf$sink_parquet(
    pl$PartitionParted(out_path, by = c("am", "cyl")),
    mkdir = TRUE
  )
  expect_snapshot(list.files(out_path, recursive = TRUE))
})
