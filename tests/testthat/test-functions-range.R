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
    out <- pl$datetime_range(
      as.Date("2020-01-01"),
      as.Date("2020-01-15"),
      interval = as.difftime(0.5, units = .test_name)
    )
    expected <- pl$datetime_range(
      as.Date("2020-01-01"),
      as.Date("2020-01-15"),
      interval = expected_interval
    )

    expect_equal(out, expected)
  }
)
