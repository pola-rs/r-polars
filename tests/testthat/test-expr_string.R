test_that("str$strptime datetime", {
  txt_datetimes = c(
    "2023-01-01 11:22:33 -0100",
    "2023-01-01 11:22:33 +0300",
    "invalid time"
  )

  expect_grepl_error(
   pl$lit(txt_datetimes)$str$strptime(pl$Datetime(),fmt = "%Y-%m-%d %H:%M:%S")$lit_to_s(),
   "strict conversion to dates failed"
  )

  expect_grepl_error(
    pl$lit(txt_datetimes)$str$strptime(
    pl$Datetime(),fmt = "%Y-%m-%d %H:%M:%S %z", strict = FALSE, tz_aware = TRUE, utc =FALSE
    )$lit_to_s(),
  "Different timezones found during 'strptime' operation"
  )


  expect_identical(
    pl$lit(txt_datetimes)$str$strptime(
      pl$Datetime(),fmt = "%Y-%m-%d %H:%M:%S %z", strict = FALSE, tz_aware = TRUE, utc =TRUE
    )$to_r(),
    as.POSIXct(txt_datetimes,format="%Y-%m-%d %H:%M:%S %z", tz = "UTC")
  )
})


test_that("str$strptime date", {
  txt_dates = c(
    "2023-01-01 11:22:33 -0100",
    "2023-01-01 11:22:33 +0300",
    "2022-1-1",
    "invalid time"
  )

  expect_grepl_error(
   pl$lit(txt_dates)$str$strptime(pl$Int32,fmt = "%Y-%m-%d ")$lit_to_s(),
   "datatype should be of type \\{Date, Datetime, Time\\}"
  )

  expect_grepl_error(
   pl$lit(txt_dates)$str$strptime(pl$Date,fmt = "%Y-%m-%d ")$lit_to_s(),
   "strict conversion to dates failed"
  )

  expect_identical(
    pl$lit(txt_dates)$str$strptime(
       pl$Date,fmt = "%Y-%m-%d ", exact = TRUE, strict = FALSE,
    )$to_r(),
    as.Date(c(NA,NA,"2022-1-1",NA))
  )

  expect_identical(
    pl$lit(txt_dates)$str$strptime(
       pl$Date,fmt = "%Y-%m-%d ", exact = FALSE, strict = FALSE,
    )$to_r(),
    as.Date(txt_dates)
  )


})



test_that("str$strptime time", {
  txt_times = c(
    "11:22:33 -0100",
    "11:22:33 +0300",
    "invalid time"
  )

  expect_grepl_error(
   pl$lit(txt_times)$str$strptime(pl$Int32,fmt = "%H:%M:%S %z")$lit_to_s(),
   "datatype should be of type \\{Date, Datetime, Time\\}"
  )

  expect_grepl_error(
    pl$lit(txt_times)$str$strptime(pl$Time,fmt = "%H:%M:%S %z")$lit_to_s(),
   "strict conversion to dates failed"
  )

  expect_identical(
    pl$lit(txt_times)$str$strptime(
      pl$Time,fmt = "%H:%M:%S %z", strict=FALSE,
    )$to_r(),
    pl$PTime(txt_times,tu="ns")
  )

})
