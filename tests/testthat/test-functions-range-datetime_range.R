test_that("$datetime_range() error", {
  expect_snapshot(
    pl$datetime_range(1, as.POSIXct("2000-01-01")),
    error = TRUE
  )
  expect_snapshot(
    pl$datetime_range(as.POSIXct("2000-01-01"), TRUE),
    error = TRUE
  )
})

test_that("$datetime_ranges() error", {
  expect_snapshot(
    pl$datetime_ranges(1, as.POSIXct("2000-01-01")),
    error = TRUE
  )
  expect_snapshot(
    pl$datetime_ranges(as.POSIXct("2000-01-01"), TRUE),
    error = TRUE
  )
})

patrick::with_parameters_test_that(
  "difftime interval works",
  .cases = {
    # fmt: skip
    tibble::tribble(
      ~.test_name, ~expected_interval,
      "secs", "500ms",
      "mins", "30s",
      "hours", "30m",
      "days", "12h",
      "weeks", "3d12h",
    )
  },
  code = {
    start_date <- as.Date("2020-01-01")
    end_date <- as.Date("2020-01-15")

    out <- pl$datetime_range(
      start_date,
      end_date,
      interval = as.difftime(0.5, units = .test_name)
    )
    expected <- pl$datetime_range(
      start_date,
      end_date,
      interval = expected_interval
    )

    expect_equal(out, expected)
  }
)

patrick::with_parameters_test_that(
  "clock_duration interval works",
  .cases = {
    skip_if_not_installed("clock")

    # fmt: skip
    tibble::tribble(
      ~.test_name, ~construct_fn, ~expected_interval,
      "ns", clock::duration_nanoseconds, "10ns",
      "us", clock::duration_microseconds, "10us",
      "ms", clock::duration_milliseconds, "10ms",
      "s", clock::duration_seconds, "10s",
      "m", clock::duration_minutes, "10m",
      "h", clock::duration_hours, "10h",
      "d", clock::duration_days, "10d",
      "w", clock::duration_weeks, "10w",
      "mo", clock::duration_months, "10mo",
      "q", clock::duration_quarters, "10q",
      "y", clock::duration_years, "10y",
    )
  },
  code = {
    start_date <- as.Date("2020-01-01")
    end_date <- as.Date("2040-01-15")

    out <- pl$datetime_range(
      start_date,
      end_date,
      interval = construct_fn(10)
    )
    expected <- pl$datetime_range(
      start_date,
      end_date,
      interval = expected_interval
    )

    expect_equal(out, expected)
  }
)
