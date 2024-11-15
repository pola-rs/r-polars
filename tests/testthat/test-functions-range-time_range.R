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
