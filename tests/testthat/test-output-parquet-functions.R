test_that("sink_parquet(): basic usage", {
  lf <- as_polars_lf(mtcars)
  df <- as_polars_df(mtcars)

  tmpf <- withr::local_tempfile()
  expect_error(
    lf$sink_parquet(tmpf, compression = "rar"),
    "must be one of"
  )
  lf$sink_parquet(tmpf)
  expect_equal(pl$scan_parquet(tmpf)$collect(), df)

  # return the input data
  x <- lf$sink_parquet(tmpf)
  expect_equal(x$collect(), df)
})

test_that("sink_parquet: argument 'statistics'", {
  lf <- as_polars_lf(mtcars)

  tmpf <- withr::local_tempfile()
  expect_silent(lf$sink_parquet(tmpf, statistics = TRUE))
  expect_silent(lf$sink_parquet(tmpf, statistics = FALSE))
  expect_silent(lf$sink_parquet(tmpf, statistics = "full"))

  expect_error(
    lf$sink_parquet(tmpf, statistics = "foo"),
    "must be TRUE, FALSE, 'full', or"
  )
  # TODO: uncomment when https://github.com/pola-rs/polars/issues/17306 is fixed
  # expect_silent(lf$sink_parquet(
  #   tmpf,
  #   statistics = list(
  #     min = TRUE,
  #     max = FALSE,
  #     distinct_count = TRUE,
  #     null_count = FALSE
  #   )
  # ))
  expect_error(
    lf$sink_parquet(tmpf, statistics = list(foo = TRUE, foo2 = FALSE)),
    "must be TRUE, FALSE, 'full', or"
  )
  expect_error(
    lf$sink_parquet(tmpf, statistics = c(max = TRUE, min = FALSE)),
    "must be TRUE, FALSE, 'full', or"
  )
})

test_that("write_parquet works", {
  tmpf <- withr::local_tempfile()
  on.exit(unlink(tmpf))
  df_exp <- as_polars_df(mtcars)
  df_exp$write_parquet(tmpf)

  expect_equal(
    pl$read_parquet(tmpf),
    mtcars,
    ignore_attr = TRUE
  )
})

test_that("throw error if invalid compression is passed", {
  tmpf <- withr::local_tempfile()
  on.exit(unlink(tmpf))
  df_exp <- as_polars_df(mtcars)
  expect_error(
    df_exp$write_parquet(tmpf, compression = "invalid"),
    "must be one of"
  )
})

test_that("write_parquet returns the input data", {
  dat <- as_polars_df(mtcars)
  tmpf <- withr::local_tempfile()
  x <- dat$write_parquet(tmpf)
  expect_equal(x, dat)
})

test_that("write_parquet: argument 'statistics'", {
  dat <- as_polars_df(mtcars)
  tmpf <- withr::local_tempfile()
  on.exit(unlink(tmpf))

  expect_silent(dat$write_parquet(tmpf, statistics = TRUE))
  expect_silent(dat$write_parquet(tmpf, statistics = FALSE))
  expect_silent(dat$write_parquet(tmpf, statistics = "full"))
  expect_error(
    dat$write_parquet(tmpf, statistics = list(null_count = FALSE)),
    "must be TRUE, FALSE, 'full'"
  )
  expect_error(
    dat$write_parquet(tmpf, statistics = list(foo = TRUE, foo2 = FALSE)),
    "must be TRUE, FALSE, 'full'"
  )
  expect_error(
    dat$write_parquet(tmpf, statistics = "foo"),
    "must be TRUE, FALSE, 'full'"
  )
  expect_error(
    dat$write_parquet(tmpf, statistics = c(max = TRUE, min = FALSE)),
    "must be TRUE, FALSE, 'full'"
  )
})

test_that("write_parquet can create a hive partition", {
  temp_dir <- withr::local_tempdir()
  dat <- as_polars_df(mtcars)
  on.exit(unlink(temp_dir))

  # basic
  dat$write_parquet(temp_dir, partition_by = c("gear", "cyl"))
  expect_equal(
    list.files(temp_dir, recursive = TRUE),
    c(
      "gear=3.0/cyl=4.0/00000000.parquet",
      "gear=3.0/cyl=6.0/00000000.parquet",
      "gear=3.0/cyl=8.0/00000000.parquet",
      "gear=4.0/cyl=4.0/00000000.parquet",
      "gear=4.0/cyl=6.0/00000000.parquet",
      "gear=5.0/cyl=4.0/00000000.parquet",
      "gear=5.0/cyl=6.0/00000000.parquet",
      "gear=5.0/cyl=8.0/00000000.parquet"
    )
  )

  # works fine with integers
  temp_dir <- withr::local_tempdir()
  dat2 <- dat$with_columns(pl$col("gear")$cast(pl$Int32), pl$col("cyl")$cast(pl$Int32))
  dat2$write_parquet(temp_dir, partition_by = c("gear", "cyl"))
  expect_equal(
    list.files(temp_dir, recursive = TRUE),
    c(
      "gear=3/cyl=4/00000000.parquet",
      "gear=3/cyl=6/00000000.parquet",
      "gear=3/cyl=8/00000000.parquet",
      "gear=4/cyl=4/00000000.parquet",
      "gear=4/cyl=6/00000000.parquet",
      "gear=5/cyl=4/00000000.parquet",
      "gear=5/cyl=6/00000000.parquet",
      "gear=5/cyl=8/00000000.parquet"
    )
  )

  # check inputs
  expect_error(
    dat$write_parquet(temp_dir, partition_by = "foo"),
    r"("foo" not found)"
  )
  expect_error(
    dat$write_parquet(temp_dir, partition_by = ""),
    r"("" not found)"
  )
  expect_error(dat$write_parquet(temp_dir, partition_by = 1))
})

test_that("polars and arrow create the same hive partition", {
  skip_if_not_installed("arrow")

  # arrow
  temp_dir_arrow <- withr::local_tempdir()
  dat <- mtcars
  on.exit(unlink(temp_dir_arrow))
  arrow::write_dataset(
    dat,
    temp_dir_arrow,
    partitioning = c("cyl", "gear"),
    format = "parquet",
    hive_style = TRUE
  )

  # polars
  temp_dir_polars <- withr::local_tempdir()
  dat2 <- as_polars_df(mtcars)$with_columns(
    pl$col("gear")$cast(pl$Int32),
    pl$col("cyl")$cast(pl$Int32)
  )
  on.exit(unlink(temp_dir_polars))
  dat2$write_parquet(temp_dir_polars, partition_by = c("cyl", "gear"))

  # check dirnames because filenames are different between the two
  expect_equal(
    dirname(list.files(temp_dir_arrow, recursive = TRUE)),
    dirname(list.files(temp_dir_polars, recursive = TRUE))
  )
})
