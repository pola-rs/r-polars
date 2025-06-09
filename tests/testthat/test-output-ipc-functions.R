patrick::with_parameters_test_that(
  "Test sinking data to Arrow file",
  {
    lf <- as_polars_lf(iris)
    df <- as_polars_df(iris)
    tmpf <- withr::local_tempfile()
    expect_silent(lf$sink_ipc(tmpf, compression = compression))
    expect_equal(pl$read_ipc(tmpf), df)

    # update with new data
    lf$slice(5, 5)$sink_ipc(tmpf)
    expect_equal(
      pl$read_ipc(tmpf),
      df$slice(5, 5)
    )

    # return the input data
    x <- lf$sink_ipc(tmpf)
    expect_identical(x, lf)
  },
  compression = list("uncompressed", "zstd", "lz4", NULL)
)

test_that("sink_ipc: wrong compression", {
  lf <- as_polars_lf(iris)
  tmpf <- withr::local_tempfile()
  expect_error(
    lf$sink_ipc(tmpf, compression = "rar"),
    "must be one of"
  )
})

patrick::with_parameters_test_that(
  "Test writing data to Arrow file {rlang::quo_text(compression)} - {compat_level}",
  .cases = {
    skip_if_not_installed("arrow")

    expand.grid(
      compression = list("uncompressed", "zstd", "lz4", NULL),
      compat_level = list(0, 1, "oldest", "newest")
    ) |>
      tibble::as_tibble()
  },
  code = {
    df <- pl$DataFrame(
      int = 1:3,
      chr = letters[1:3],
      cat = factor(letters[1:3]),
    )
    tmpf <- withr::local_tempfile()
    expect_silent(df$write_ipc(tmpf, compression = compression, compat_level = compat_level))
    expect_snapshot(
      arrow::read_ipc_file(tmpf, as_data_frame = FALSE, mmap = FALSE)$schema
    )
    expect_equal(pl$read_ipc(tmpf), df)

    # update with new data
    df$slice(5, 5)$write_ipc(tmpf)
    expect_equal(
      pl$read_ipc(tmpf),
      df$slice(5, 5)
    )

    # return the input data
    x <- df$write_ipc(tmpf)
    expect_identical(x, df)
  }
)

test_that("write_ipc: wrong compression", {
  df <- as_polars_df(iris)
  tmpf <- withr::local_tempfile()
  expect_error(
    df$write_ipc(tmpf, compression = "rar"),
    "must be one of"
  )
})
