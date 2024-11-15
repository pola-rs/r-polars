test_that("$date_range() error", {
  expect_snapshot(
    pl$date_range(1, as.Date("2000-01-01")),
    error = TRUE
  )
  expect_snapshot(
    pl$date_range(as.Date("2000-01-01"), TRUE),
    error = TRUE
  )
})

test_that("$date_ranges() error", {
  expect_snapshot(
    pl$date_ranges(1, as.Date("2000-01-01")),
    error = TRUE
  )
  expect_snapshot(
    pl$date_ranges(as.Date("2000-01-01"), TRUE),
    error = TRUE
  )
})
