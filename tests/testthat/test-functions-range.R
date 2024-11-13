test_that("$date_range(), $datetime_range() error", {
  expect_snapshot(
    pl$date_range(1, as.Date("2000-01-01")),
    error = TRUE
  )
  expect_snapshot(
    pl$date_range(as.Date("2000-01-01"), TRUE),
    error = TRUE
  )
  expect_snapshot(
    pl$datetime_range(1, as.POSIXct("2000-01-01")),
    error = TRUE
  )
  expect_snapshot(
    pl$datetime_range(as.POSIXct("2000-01-01"), TRUE),
    error = TRUE
  )
})

test_that("$date_ranges(), $datetime_ranges() error", {
  expect_snapshot(
    pl$date_ranges(1, as.Date("2000-01-01")),
    error = TRUE
  )
  expect_snapshot(
    pl$date_ranges(as.Date("2000-01-01"), TRUE),
    error = TRUE
  )
  expect_snapshot(
    pl$datetime_ranges(1, as.POSIXct("2000-01-01")),
    error = TRUE
  )
  expect_snapshot(
    pl$datetime_ranges(as.POSIXct("2000-01-01"), TRUE),
    error = TRUE
  )
})

patrick::with_parameters_test_that("difftime interval works",
  .cases = {
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

patrick::with_parameters_test_that("clock_duration interval works",
  .cases = {
    skip_if_not_installed("clock")

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

test_that("$int_range, $int_ranges", {
  expect_equal(
    pl$select(int = pl$int_range(0, 3)),
    pl$DataFrame(int = 0:2)$cast(pl$Int64)
  )
  expect_equal(
    pl$select(int = pl$int_range(3)),
    pl$DataFrame(int = 0:2)$cast(pl$Int64)
  )
  expect_equal(
    pl$select(int = pl$int_range(0, 3, step = 2)),
    pl$DataFrame(int = c(0L, 2L))$cast(pl$Int64)
  )
  expect_equal(
    pl$select(int = pl$int_range(0, 3, dtype = pl$Int16)),
    pl$DataFrame(int = 0:2)$cast(pl$Int16)
  )

  df <- pl$DataFrame(start = c(1, -1), end = c(3, 2))
  expect_equal(
    df$select(int_range = pl$int_ranges("start", "end")),
    pl$DataFrame(int_range = list(1:2, -1:1))$cast(pl$List(pl$Int64))
  )
  expect_equal(
    df$select(int_range = pl$int_ranges("end")),
    pl$DataFrame(int_range = list(0:2, 0:1))$cast(pl$List(pl$Int64))
  )
  expect_equal(
    df$select(int_range = pl$int_ranges("end", step = 2)),
    pl$DataFrame(int_range = list(c(0L, 2L), 0L))$cast(pl$List(pl$Int64))
  )
  expect_equal(
    df$select(int_range = pl$int_ranges("start", "end", dtype = pl$Int16)),
    pl$DataFrame(int_range = list(1:2, -1:1))$cast(pl$List(pl$Int16))
  )
})

test_that("$time_range", {
  skip_if_not_installed("hms")
  expect_equal(
    pl$select(
      time = pl$time_range(
        start = hms::parse_hms("14:00:00"),
        interval = as.difftime("3:15:00")
      )
    ),
    pl$DataFrame(time = hms::parse_hms(
      c("14:00:00", "17:15:00", "20:30:00", "23:45:00")
    ))
  )
  expect_equal(
    pl$select(
      time = pl$time_range(
        start = hms::parse_hms("14:00:00"),
        interval = "3h15m"
      )
    ),
    pl$DataFrame(time = hms::parse_hms(
      c("14:00:00", "17:15:00", "20:30:00", "23:45:00")
    ))
  )
  expect_snapshot(
    pl$time_range(
      start = hms::parse_hms("14:00:00"),
      interval = "2y"
    ),
    error = TRUE
  )
})

test_that("$time_ranges", {
  skip_if_not_installed("hms")
  df <- pl$DataFrame(
    start = hms::parse_hms(c("21:00:00", "22:00:00")),
    end = hms::parse_hms(c("23:00:00", "23:00:00"))
  )
  expect_equal(
    df$select(time_range = pl$time_ranges("start", "end")),
    pl$DataFrame(time_range = list(
      hms::parse_hms(c("21:00:00", "22:00:00", "23:00:00")),
      hms::parse_hms(c("22:00:00", "23:00:00"))
    ))
  )
  expect_equal(
    df$select(time_range = pl$time_ranges("start")),
    pl$DataFrame(time_range = list(
      hms::parse_hms(c("21:00:00", "22:00:00", "23:00:00")),
      hms::parse_hms(c("22:00:00", "23:00:00"))
    ))
  )
  expect_snapshot(
    pl$time_ranges(
      start = hms::parse_hms("14:00:00"),
      interval = "2y"
    ),
    error = TRUE
  )
})
