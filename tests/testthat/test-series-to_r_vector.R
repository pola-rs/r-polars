patrick::with_parameters_test_that(
  "int64 conversion",
  .cases = {
    skip_if_not_installed("bit64")

    tibble::tribble(
      ~.test_name, ~type, ~as_func,
      "double", "double", as.double,
      "character", "character", as.character,
      "integer", "integer", as.integer,
      "integer64", "integer64", bit64::as.integer64,
    )
  },
  code = {
    chr_vec <- c(NA, "0", "4294967295")

    series_int64 <- as_polars_series(chr_vec)$cast(pl$Int64)
    series_uint32 <- as_polars_series(chr_vec)$cast(pl$UInt32)
    series_uint64 <- as_polars_series(chr_vec)$cast(pl$UInt64)

    out_int64 <- series_int64$to_r_vector(int64 = type)
    out_uint32 <- series_uint32$to_r_vector(int64 = type)
    out_uint64 <- series_uint64$to_r_vector(int64 = type)

    if (type != "integer64") {
      expect_type(out_int64, type)
      expect_type(out_uint32, type)
      expect_type(out_uint64, type)
    }

    expected <- suppressWarnings(as_func(chr_vec))
    expect_identical(out_int64, expected)
    expect_identical(out_uint32, expected)
    expect_identical(out_uint64, expected)
  }
)

# Because of https://github.com/truecluster/bit64/issues/17,
# we cannot include this test to the above parameterized test.
test_that("UInt64 may overflow when int64='integer64'", {
  skip_if_not_installed("bit64")

  expect_identical(
    as_polars_series("18446744073709551615")$cast(pl$UInt64)$to_r_vector(int64 = "integer64"),
    bit64::as.integer64(NA)
  )
})

test_that("int64 argument error", {
  expect_error(
    as_polars_series(1)$to_r_vector(int64 = TRUE),
    "must be character"
  )
  expect_error(
    as_polars_series(1)$to_r_vector(int64 = "foo"),
    r"(must be one of \('character', 'double', 'integer', 'integer64'\))"
  )
  with_mocked_bindings(
    {
      expect_error(
        as_polars_series(1)$to_r_vector(int64 = "integer64"),
        "If the `int64` argument is set to 'integer64', the `bit64` package must be installed"
      )
    },
    is_bit64_installed = function() FALSE
  )
})

patrick::with_parameters_test_that(
  "struct conversion",
  .cases = {
    tibble::tribble(
      ~.test_name, ~classes,
      "dataframe", "data.frame",
      "tibble", c("tbl_df", "tbl", "data.frame"),
    )
  },
  code = {
    df_in <- data.frame(
      a = 1:2,
      b = I(list(data.frame(c = letters[1:2]), data.frame(c = letters[3:4])))
    )
    df_out <- as_polars_series(df_in)$to_r_vector(struct = .test_name)

    expect_s3_class(df_out, classes)
    expect_s3_class(df_out$b[[1]], classes)
    expect_snapshot(df_out)
  }
)

test_that("struct argument warning and error", {
  # TODO: the argument name should be updated after https://github.com/yutannihilation/savvy/issues/289
  expect_error(
    as_polars_series(1)$to_r_vector(struct = TRUE),
    r"(Argument `struct\_` must be character)"
  )
  expect_error(
    as_polars_series(1)$to_r_vector(struct = "foo"),
    r"(must be one of \('dataframe', 'tibble'\))"
  )
  with_mocked_bindings(
    {
      skip_if_not_installed("tibble")

      expect_warning(
        as_polars_series(1)$to_r_vector(struct = "tibble"),
        "the `tibble` package is recommended to be installed"
      )
    },
    is_tibble_installed = function() FALSE
  )
})

patrick::with_parameters_test_that("datetime conversion to clock classes",
  .cases = {
    skip_if_not_installed("clock")

    tibble::tribble(
      ~.test_name, ~time_unit, ~precision,
      "ms", "ms", "millisecond",
      "us", "us", "microsecond",
      "ns", "ns", "nanosecond",
    )
  },
  code = {
    chr_vec <- c(
      NA,
      "1900-01-01T12:34:56.123456789",
      "2012-01-01T12:34:56.123456789",
      "2212-01-01T12:34:56.123456789"
    )

    series_naive_time <- as_polars_series(chr_vec)$cast(pl$Datetime(time_unit))
    series_zoned_time <- series_naive_time$dt$replace_time_zone("America/New_York")
    naive_time_vec <- clock::naive_time_parse(chr_vec, precision = precision)
    zoned_time_vec <- clock::as_zoned_time(naive_time_vec, "America/New_York")

    expect_identical(series_naive_time$to_r_vector(as_clock_class = TRUE), naive_time_vec)
    expect_identical(series_zoned_time$to_r_vector(as_clock_class = TRUE), zoned_time_vec)
  }
)

patrick::with_parameters_test_that("duration conversion to clock class",
  .cases = {
    skip_if_not_installed("clock")

    tibble::tribble(
      ~.test_name, ~time_unit, ~construct_function,
      "ms", "ms", clock::duration_milliseconds,
      "us", "us", clock::duration_microseconds,
      "ns", "ns", clock::duration_nanoseconds,
    )
  },
  code = {
    int_vec <- c(NA, -10:10)
    series_duration <- as_polars_series(int_vec)$cast(pl$Duration(time_unit))
    duration_vec <- construct_function(int_vec)

    expect_identical(series_duration$to_r_vector(as_clock_class = TRUE), duration_vec)
  }
)
