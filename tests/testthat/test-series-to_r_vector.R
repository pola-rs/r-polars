patrick::with_parameters_test_that(
  "uint8 conversion",
  .cases = {
    # fmt: skip
    tibble::tribble(
      ~.test_name, ~as_func,
      "raw", as.raw,
      "integer", as.integer,
    )
  },
  code = {
    double_vec <- c(NA, 0, 16, 255)
    series_uint8 <- as_polars_series(double_vec)$cast(pl$UInt8)

    out <- series_uint8$to_r_vector(uint8 = .test_name)

    # `as.raw(NA)` returns `as.raw(0)` and warns, so we should suppress the warning
    expected <- suppressWarnings(as_func(double_vec))
    expect_identical(out, expected)
  }
)

patrick::with_parameters_test_that(
  "int64 conversion",
  .cases = {
    skip_if_not_installed("bit64")

    # fmt: skip
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
    "must be a string"
  )
  expect_error(
    as_polars_series(1)$to_r_vector(int64 = "foo"),
    r"(`int64` must be one of "double", "character", "integer", or "integer64", not "foo")"
  )
  with_mocked_bindings(
    {
      expect_snapshot(
        as_polars_series(1)$to_r_vector(int64 = "integer64"),
        error = TRUE
      )
    },
    is_bit64_installed = function() FALSE
  )
})

patrick::with_parameters_test_that(
  "date conversion",
  .cases = {
    skip_if_not_installed("data.table")

    # fmt: skip
    tibble::tribble(
      ~.test_name, ~as_func,
      "Date", as.Date,
      "IDate", data.table::as.IDate,
    )
  },
  code = {
    int_vec <- c(NA, 100L, 20000L)
    series_date <- as_polars_series(int_vec)$cast(pl$Date)

    out <- series_date$to_r_vector(date = .test_name)
    # Always export as integer
    expect_type(out, "integer")

    expected <- as_func(int_vec)
    expect_identical(out, expected)
  }
)

test_that("date argument error", {
  expect_error(
    as_polars_series(1)$to_r_vector(date = TRUE),
    "must be a string"
  )
  expect_error(
    as_polars_series(1)$to_r_vector(date = "foo"),
    r"(`date` must be one of "Date" or "IDate", not "foo")"
  )
})

patrick::with_parameters_test_that(
  "time conversion",
  .cases = {
    skip_if_not_installed("data.table")
    skip_if_not_installed("hms")

    # fmt: skip
    tibble::tribble(
      ~.test_name, ~as_func,
      "hms", hms::as_hms,
      "ITime", data.table::as.ITime,
    )
  },
  code = {
    double_vec <- c(NA, 0, 86399)
    series_time <- as_polars_series(hms::as_hms(double_vec))$cast(pl$Time)

    out <- series_time$to_r_vector(time = .test_name)

    expected <- as_func(double_vec)
    expect_identical(out, expected)
  }
)

test_that("time argument error", {
  expect_error(
    as_polars_series(1)$to_r_vector(time = TRUE),
    "must be a string"
  )
  expect_error(
    as_polars_series(1)$to_r_vector(time = "foo"),
    r"(`time` must be one of "hms" or "ITime", not "foo")"
  )
  with_mocked_bindings(
    {
      expect_snapshot(
        as_polars_series(1)$to_r_vector(time = "ITime"),
        error = TRUE
      )
    },
    is_datatable_installed = function() FALSE
  )
})

patrick::with_parameters_test_that(
  "struct conversion",
  .cases = {
    # fmt: skip
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
    list_out <- as_polars_series(df_in)$to_r_vector(struct = .test_name, ensure_vector = TRUE)

    expect_false(is.vector(df_out))
    expect_true(is.vector(list_out))

    expect_s3_class(df_out, classes, exact = TRUE)
    expect_vector(list_out, ptype = list())

    expect_s3_class(df_out$b[[1]], classes, exact = TRUE)
    expect_s3_class(list_out$b[[2]], classes, exact = TRUE)

    expect_snapshot(df_out)
    expect_snapshot(list_out)
  }
)

test_that("struct argument warning and error", {
  expect_error(
    as_polars_series(1)$to_r_vector(struct = TRUE),
    "`struct` must be a string or character vector"
  )
  expect_error(
    as_polars_series(1)$to_r_vector(struct = "foo"),
    r"(`struct` must be one of "dataframe" or "tibble", not "foo")"
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

patrick::with_parameters_test_that(
  "decimal conversion",
  .cases = {
    # fmt: skip
    tibble::tribble(
      ~.test_name, ~type, ~expected_out,
      "double", "double", c(NA, 1, 0.1),
      "character", "character", c(NA, "1.000", "0.100"),
    )
  },
  code = {
    series_decimal <- as_polars_series(c(NA, 1, 0.1))$cast(pl$Decimal(5, 3))

    out <- series_decimal$to_r_vector(decimal = type)
    expect_identical(out, expected_out)
  }
)

test_that("decimal argument error", {
  expect_error(
    as_polars_series(1)$to_r_vector(decimal = TRUE),
    "`decimal` must be a string or character vector"
  )
  expect_error(
    as_polars_series(1)$to_r_vector(decimal = "foo"),
    r"(`decimal` must be one of "double" or "character", not "foo")"
  )
})

patrick::with_parameters_test_that(
  "datetime conversion to clock classes",
  .cases = {
    skip_if_not_installed("clock")

    # fmt: skip
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

patrick::with_parameters_test_that(
  "duration conversion to clock class",
  .cases = {
    skip_if_not_installed("clock")

    # fmt: skip
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
