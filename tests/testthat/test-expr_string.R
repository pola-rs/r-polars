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





test_that("str$lengths str$n_chars", {
  test_str = c("Café", NA, "345", "東京") |> enc2utf8()
  Encoding(test_str)

  df = pl$DataFrame(
    s = test_str
  )$select(
    pl$col("s"),
    pl$col("s")$str$lengths()$alias("lengths"),
    pl$col("s")$str$n_chars()$alias("n_chars")
  )

  expect_identical(
    df$to_list(),
    list(
      s = test_str,
      lengths = c(5, NA_integer_, 3, 6),
      n_chars = nchar(test_str) |> as.numeric()
    )
  )

})



test_that("str$concat", {

  #concatenate a Series of strings to a single string
  df = pl$DataFrame(foo = c("1", "a", 2))
  expect_identical(
    df$select(pl$col("foo")$str$concat())$to_list(),
    lapply(df$to_list(),paste,collapse = "-")
  )

  #Series list of strings to Series of concatenated strings
  df = pl$DataFrame(list(bar = list(c("a","b", "c"), c("1","2","æ"))))
  expect_identical(
    df$select(pl$col("bar")$arr$eval(pl$col()$str$concat())$arr$first())$to_list()$bar,
    sapply(df$to_list()[[1]],paste,collapse = "-")
  )

})


test_that("str$to_uppercase to_lowercase", {
  #concatenate a Series of strings to a single string
  df = pl$DataFrame(foo = c("1", "æøå", letters,LETTERS))

  expect_identical(
    df$select(pl$col("foo")$str$to_uppercase())$to_list()$foo,
    toupper(df$to_list()$foo)
  )

  expect_identical(
    df$select(pl$col("foo")$str$to_lowercase())$to_list()$foo,
    tolower(df$to_list()$foo)
  )
})
