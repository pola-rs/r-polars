test_that("x argument can't be missing",{
  expect_error(as_polars_series(), r"(The `x` argument of `as_polars_series\(\)` can't be missing)")
})

patrick::with_parameters_test_that(
  "as_polars_series works for classes",
  .cases = {
    skip_if_not_installed("hms")
    skip_if_not_installed("blob")
    skip_if_not_installed("bit64")
    skip_if_not_installed("vctrs")
    skip_if_not_installed("data.table")

    withr::with_timezone(
      "UTC",
      tibble::tribble(
        ~.test_name, ~x, ~expected_name, ~expected_dtype,
        "polars_series", as_polars_series(1L, "foo"), "foo", pl$Int32,
        "polars_data_frame", pl$DataFrame(a = 1L, y = TRUE), "", pl$Struct(a = pl$Int32, y = pl$Boolean),
        "double", c(1.0, NA), "", pl$Float64,
        "integer", c(1L, NA), "", pl$Int32,
        "character", c("foo", NA), "", pl$String,
        "logical", c(TRUE, FALSE, NA), "", pl$Boolean,
        "raw", charToRaw("foo"), "", pl$Binary,
        "array", array(1:24, c(2, 3, 4)), "", pl$Array(pl$Int32, c(3, 2)),
        "factor", factor("foo"), "", pl$Categorical(),
        "Date", as.Date(c("2021-01-01", NA)), "", pl$Date,
        "Date (integer)", as.Date(c(18628L, NA)), "", pl$Date,
        "POSIXct (UTC)", as.POSIXct(c("2021-01-01 00:00:00", NA), "UTC"), "", pl$Datetime("ms", "UTC"),
        "POSIXct (UTC, integer)", as.POSIXct(c(1609459200L, NA), "UTC"), "", pl$Datetime("ms", "UTC"),
        "POSIXct (system time)", as.POSIXct(c("2021-01-01 00:00:00", NA)), "", pl$Datetime("ms"),
        "POSIXct (system time / NULL)", as.POSIXct(c(1609459200, NA), tz = NULL), "", pl$Datetime("ms"),
        "POSIXct (system time, integer)", as.POSIXct(c(1609459200L, NA)), "", pl$Datetime("ms"),
        "difftime", as.difftime(c(1, NA), units = "weeks"), "", pl$Duration("ms"),
        "hms", hms::as_hms(c("00:00:00", "01:00:00", NA)), "", pl$Time,
        "blob", blob::as_blob(c("foo", "bar", NA)), "", pl$Binary,
        "NULL", NULL, "", pl$Null,
        "list", list("foo", 1L, NULL, NA, vctrs::unspecified(), as_polars_series(NULL), list(NULL)), "", pl$List(pl$String),
        "list (casting failed)", list(list("bar"), "foo"), "", pl$List(pl$String),
        "AsIs", I(1L), "", pl$Int32,
        "data.frame", data.frame(x = 1L, y = TRUE), "", pl$Struct(x = pl$Int32, y = pl$Boolean),
        "integer64", bit64::as.integer64(c(NA, "-9223372036854775807", "9223372036854775807")), "", pl$Int64,
        "ITime", data.table::as.ITime(c(NA, 3600, 86400, -1)), "", pl$Time,
        "vctrs_unspecified", vctrs::unspecified(3L), "", pl$Null,
      )
    )
  },
  code = {
    withr::with_timezone(
      "UTC",
      {
        pl_series <- as_polars_series(x, argument_should_be_ignored = "foo")
        expect_s3_class(pl_series, "polars_series")
        expect_snapshot(print(pl_series))

        expect_equal(pl_series$name, expected_name)
        expect_equal(pl_series$dtype, expected_dtype)

        expect_equal(as_polars_series(x, name = "bar")$name, "bar")
      }
    )
  }
)

test_that("as_polars_series.default throws an error", {
  x <- 1
  class(x) <- "foo"
  expect_error(as_polars_series(x), "Unsupported class")
})

test_that("as_polars_series.polars_expr throws an error", {
  expect_error(
    as_polars_series(pl$lit(1)),
    r"(You can evaluating the expression with `pl\$select\(\))"
  )
})

test_that("Before 0-oclock or after 24-oclock hms must be rejected", {
  skip_if_not_installed("hms")

  hms_24 <- hms::as_hms(c(NA, "24:00:00", "04:00:00"))
  hms_minus_1 <- hms::as_hms(c(NA, -3600, 0))
  expect_error(as_polars_series(hms_24), "not supported")
  expect_error(as_polars_series(hms_minus_1), "not supported")
})

test_that("as_polars_series(<list>, strict = TRUE)", {
  skip_if_not_installed("vctrs")

  expect_error(
    as_polars_series(list(1, 1L), strict = TRUE),
    "expected: `f64`, got: `i32` at index: 2"
  )
  expect_error(
    as_polars_series(list(NULL, 1, 1L), strict = TRUE),
    "expected: `f64`, got: `i32` at index: 3"
  )
  expect_error(
    as_polars_series(list(vctrs::unspecified(), 1, 1L), strict = TRUE),
    "expected: `null`, got: `f64` at index: 2"
  )
  expect_error(
    as_polars_series(list(as_polars_series(NULL), 1, 1L), strict = TRUE),
    "expected: `null`, got: `f64` at index: 2"
  )
  # strict arugment should be passed to inside functions
  expect_error(
    as_polars_series(list(NULL, list(TRUE), list(list(), TRUE)), strict = TRUE),
    r"(expected: `list\[null\]`, got: `bool` at index: 2)"
  )
  expect_error(
    as_polars_series(data.frame(a = I(list(1, 1L))), strict = TRUE),
    "expected: `f64`, got: `i32` at index: 2"
  )

  expect_equal(
    as_polars_series(list(1, 2, NULL), strict = TRUE),
    as_polars_series(list(1, 2, NULL))
  )
  expect_equal(
    as_polars_series(list(NULL, 1), strict = TRUE),
    as_polars_series(list(NULL, 1))
  )
})

# TODO: more tests for system time

test_that("as_polars_series works for vctrs_rcrd", {
  skip_if_not_installed("vctrs")
  skip_if_not_installed("tibble")

  # Sample vctrs_rcrd class
  # From https://github.com/r-lib/vctrs/blob/8d98911aa64e36dbc249cbc8802618638fd0c603/vignettes/pillar.Rmd#L54-L85
  latlon <- function(lat, lon) {
    vctrs::new_rcrd(list(lat = lat, lon = lon), class = "earth_latlon")
  }

  vec <- latlon(c(32.71, 2.95), c(-117.17, 1.67))
  pl_series <- as_polars_series(vec)

  expect_s3_class(pl_series, "polars_series")
  expect_length(pl_series, 2L)
  expect_snapshot(print(pl_series))

  expect_equal(pl_series$name, "")
  expect_equal(as_polars_series(vec, "foo")$name, "foo")

  expect_equal(
    pl_series$dtype,
    pl$Struct(lat = pl$Float64, lon = pl$Float64)
  )
})

patrick::with_parameters_test_that("clock datetime classes support",
  {
    skip_if_not_installed("clock")

    naive_time_chr <- c(
      NA,
      "1900-01-01T12:34:56.123456789",
      "2012-01-01T12:34:56.123456789",
      "2212-01-01T12:34:56.123456789"
    )

    expected_time_unit <- switch(precision,
      nanosecond = "ns",
      microsecond = "us",
      "ms"
    )

    clock_naive_time <- clock::naive_time_parse(naive_time_chr, precision = precision)
    clock_sys_time <- clock::sys_time_parse(naive_time_chr, precision = precision)
    clock_zoned_time <- clock::as_zoned_time(clock_naive_time, "America/New_York")

    series_naive_time <- as_polars_series(clock_naive_time)
    series_sys_time <- as_polars_series(clock_sys_time)
    series_zoned_time <- as_polars_series(clock_zoned_time)

    expect_s3_class(series_naive_time, "polars_series")
    expect_s3_class(series_sys_time, "polars_series")
    expect_s3_class(series_zoned_time, "polars_series")

    expect_snapshot(print(series_naive_time))
    expect_snapshot(print(series_sys_time))
    expect_snapshot(print(series_zoned_time))

    expect_equal(series_naive_time$name, "")
    expect_equal(series_sys_time$name, "")
    expect_equal(series_zoned_time$name, "")

    expect_equal(as_polars_series(clock_naive_time, name = "foo")$name, "foo")
    expect_equal(as_polars_series(clock_sys_time, name = "foo")$name, "foo")
    expect_equal(as_polars_series(clock_zoned_time, name = "foo")$name, "foo")

    expect_equal(series_naive_time$dtype, pl$Datetime(expected_time_unit, NULL))
    expect_equal(series_sys_time$dtype, pl$Datetime(expected_time_unit, "UTC"))
    expect_equal(series_zoned_time$dtype, pl$Datetime(expected_time_unit, "America/New_York"))
  },
  precision = c("nanosecond", "microsecond", "millisecond", "second", "minute", "hour", "day"),
  .test_name = precision
)

patrick::with_parameters_test_that("clock duration class support",
  .cases = {
    skip_if_not_installed("clock")

    tibble::tribble(
      ~.test_name, ~time_unit, ~construct_function,
      "year", "ms", clock::duration_years,
      "quarter", "ms", clock::duration_quarters,
      "month", "ms", clock::duration_months,
      "week", "ms", clock::duration_weeks,
      "day", "ms", clock::duration_days,
      "hour", "ms", clock::duration_hours,
      "minute", "ms", clock::duration_minutes,
      "second", "ms", clock::duration_seconds,
      "millisecond", "ms", clock::duration_milliseconds,
      "microsecond", "us", clock::duration_microseconds,
      "nanosecond", "ns", clock::duration_nanoseconds,
    )
  },
  code = {
    clock_duration <- construct_function(c(NA, -1:1))
    series_duration <- as_polars_series(clock_duration)

    expect_s3_class(series_duration, "polars_series")
    expect_snapshot(print(series_duration))

    expect_equal(series_duration$name, "")
    expect_equal(as_polars_series(clock_duration, name = "foo")$name, "foo")

    expect_equal(series_duration$dtype, pl$Duration(time_unit))
  }
)
