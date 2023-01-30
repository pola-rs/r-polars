test_that("pl$date_range", {

  t1 = as.POSIXct("2022-01-01")
  t2 = as.POSIXct("2022-01-02")

  expect_identical(
    pl$date_range(low = t1, high = t2, interval = "6h", time_zone = "CET")$to_r(),
    seq(t1,t2,by = as.difftime(6,units="hours")) |> "attr<-"("tzone","CET")
  )
  expect_identical(
    pl$date_range(low = t1, high = t2, interval = "6h", time_zone = NULL)$to_r(),
    seq(t1,t2,by = as.difftime(6,units="hours"))
  )
  expect_identical(
    pl$date_range(low = t1, high = t2, interval = "6h", time_zone = "GMT")$to_r(),
    seq(t1,t2,by = as.difftime(6,units="hours")) |> "attr<-"("tzone","GMT")
  )
  expect_identical(
    pl$date_range(low = t1, high = t2, interval = "3h", time_unit = "ms")$to_r(),
    seq(t1,t2,by = as.difftime(3,units="hours"))
  )
  expect_identical(
    pl$date_range(low = t1, high = t2, interval = "3h", time_unit = "ns")$to_r(),
    seq(t1,t2,by = as.difftime(3,units="hours"))
  )

  t1 = as.POSIXct("2022-01-01",tz = "GMT")
  t2 = as.POSIXct("2022-01-02", tz = "GMT")
  expect_identical(
    pl$date_range(low = t1, high = t2, interval = "6h", time_zone = "CET")$to_r(),
    seq(t1,t2,by = as.difftime(6,units="hours")) |> "attr<-"("tzone","CET")
  )
  expect_identical(
    pl$date_range(low = t1, high = t2, interval = "6h", time_zone = NULL)$to_r(),
    seq(t1,t2,by = as.difftime(6,units="hours")) |> "attr<-"("tzone","")
  )
  expect_identical(
    pl$date_range(low = t1, high = t2, interval = "6h", time_zone = "GMT")$to_r(),
    seq(t1,t2,by = as.difftime(6,units="hours")) |> "attr<-"("tzone","GMT")
  )
  expect_identical(
    pl$date_range(low = t1, high = t2, interval = "3h", time_unit = "ms")$to_r(),
    seq(t1,t2, by = as.difftime(3,units="hours"))|> "attr<-"("tzone","")
  )
  expect_identical(
    pl$date_range(low = t1, high = t2, interval = "3h", time_unit = "ns")$to_r(),
    seq(t1,t2,by = as.difftime(3,units="hours")) |> "attr<-"("tzone","")
  )


  #test difftime conversion to pl_duration
  t1 = as.POSIXct("2022-01-01",tz = "GMT")
  t2 = as.POSIXct("2022-01-10", tz = "GMT")
  for (i_diff_time in c("secs","mins","hours","days","weeks")) {
    expect_identical(
      pl$date_range(
        low = t1, high = t2,
        as.difftime(25,units=i_diff_time),
        time_unit = "ns"
      )$to_r(),
      seq(t1,t2,by = as.difftime(25,units=i_diff_time)) |> "attr<-"("tzone","")
    )
  }


})

test_that("dt$truncate", {

  #make a datetime
  t1 = as.POSIXct("3040-01-01",tz = "GMT")
  t2 = t1 + as.difftime(25,units = "secs")
  s = pl$date_range(t1, t2, interval = "2s", time_unit = "ms")

  #use a dt namespace function
  df = pl$DataFrame(datetime = s)$with_columns(
    pl$col("datetime")$dt$truncate("4s")$alias("truncated_4s"),
    pl$col("datetime")$dt$truncate("4s",offset("3s"))$alias("truncated_4s_offset_2s")
  )

  l_actual = df$to_list()
  expect_identical(
    lapply(l_actual,\(x) diff(x) |> as.numeric()),
    list(
      datetime = rep(2,12),
      truncated_4s = rep(c(0,4),6),
      truncated_4s_offset_2s = rep(c(0,4),6)
    )
  )

  expect_identical(
    as.numeric(l_actual$truncated_4s_offset_2s - l_actual$truncated_4s),
    rep(3,13)
  )
})


test_that("pl$date_range lazy ", {

  t1 = ISOdate(2022,1,1,0)
  t2 = ISOdate(2022,1,2,0)

  expect_identical(
    pl$date_range(low = t1, high = t2, interval = "6h", time_zone = "GMT")$to_r(),
    pl$date_range(low = t1, high = t2, interval = "6h", time_zone = "GMT",lazy = TRUE)$to_r()
  )
  expect_identical(
    pl$date_range(low = t1, high = t2, interval = "6h", time_zone = "CET")$to_r(),
    pl$date_range(low = t1, high = t2, interval = "6h", time_zone = "CET",lazy = TRUE)$to_r()
  )

  #check variations of lazy input gives same result
  df = pl$DataFrame(
    t1 = t1, t2 = t2
  )$select(
    pl$date_range("t1","t2","6h")$alias("s1"),
    pl$date_range("t1","t2","6h",lazy = TRUE)$alias("s2"),
    pl$date_range(pl$col("t1"),pl$col("t2"),"6h",lazy = TRUE)$alias("s3"),
    pl$date_range(t1,t2,"6h",lazy = TRUE)$alias("s4")
  )
  l = df$to_list()
  for(i in length(l)-1) {
    expect_identical(l[[i]],l[[i+1]])
  }
})


test_that("pl$date_range Date lazy/eager", {
  r_vers = paste(unlist(R.version[c("major","minor")]),collapse = ".")
  if( r_vers >= "4.3.0") {
    d1 = as.Date("2022-01-01")
    s_d  = pl$Series(d1, name = "Date")
    s_dt = pl$Series(as.POSIXct(d1), name = "Date") #since R4.3 this becomes UTC timezone
    df = pl$DataFrame(Date = d1)$to_series()
    dr_e = pl$date_range(d1, d1+1, interval = "6h")
    dr_l = pl$date_range(d1, d1+1, interval = "6h", lazy=TRUE)
    expect_identical(as.POSIXct(s_d$to_r()) |> 'attr<-'("tzone","UTC"),s_dt$to_r())
    expect_identical(d1, s_d$to_r())
    expect_identical(d1, df$to_r())
    expect_identical(s_dt$to_r(), dr_e$to_r()[1]|> 'attr<-'("tzone","UTC"))
    expect_identical(s_dt$to_r(), dr_l$to_r()[1]|> 'attr<-'("tzone","UTC"))
  } else {
    d1 = as.Date("2022-01-01")
    s_d  = pl$Series(d1, name = "Date")
    s_dt = pl$Series(as.POSIXct(d1), name = "Date")
    df = pl$DataFrame(Date = d1)$to_series()
    dr_e = pl$date_range(d1, d1+1, interval = "6h")
    dr_l = pl$date_range(d1, d1+1, interval = "6h", lazy=TRUE)
    expect_identical(as.POSIXct(s_d$to_r()) |> 'attr<-'("tzone",""),s_dt$to_r())
    expect_identical(d1, s_d$to_r())
    expect_identical(d1, df$to_r())
    expect_identical(s_dt$to_r(), dr_e$to_r()[1])
    expect_identical(s_dt$to_r(), dr_l$to_r()[1])
  }

})


test_that("dt$round", {

  #make a datetime
  t1 = as.POSIXct("3040-01-01",tz = "GMT")
  t2 = t1 + as.difftime(24,units = "secs")
  s = pl$date_range(t1, t2, interval = "2s", time_unit = "ms")

  #use a dt namespace function
  ##TODO contribute POLARS, offset makes little sense, it should be implemented
  ##before round not after.
  df = pl$DataFrame(datetime = s)$with_columns(
    pl$col("datetime")$dt$round("8s")$alias("truncated_4s"),
    pl$col("datetime")$dt$round("8s",offset("4s1ms"))$alias("truncated_4s_offset_2s")
  )

  l_actual = df$to_list()
  expect_identical(
    lapply(l_actual,\(x) diff(x) |> as.numeric()),
    list(
      datetime = rep(2,12),
      truncated_4s = rep(c(0,8,0,0),3),
      truncated_4s_offset_2s = rep(c(0,8,0,0),3)
    )
  )

})


test_that("dt$combine", {

  #Using pl$PTime
  expect_identical(
    (
      pl$lit(as.Date("2021-01-01"))
        $dt$combine(pl$PTime("02:34:12"))
        $cast(pl$Datetime(tu="us",tz="GMT"))
        $to_r()
    ),
    as.POSIXct("2021-01-01 02:34:12",tz="GMT")
  )

  expect_identical(
    (
      pl$lit(as.Date("2021-01-01"))
      $dt$combine(pl$PTime(3600 * 1.5E3, tu="ms"))
      $cast(pl$Datetime(tu="us",tz="GMT"))
      $to_r()
    ),
    as.POSIXct("2021-01-01 01:30:00",tz="GMT")
  )

  expect_identical(
    (
      pl$lit(as.Date("2021-01-01"))
      $dt$combine(3600 * 1.5E9, tu="ns")
      $cast(pl$Datetime(tu="us",tz="GMT"))
      $to_r()
    ),
    as.POSIXct("2021-01-01 01:30:00",tz="GMT")
  )

  expect_identical(
    (
      pl$lit(as.Date("2021-01-01"))
      $dt$combine(-3600 * 1.5E9, tu="ns")
      $cast(pl$Datetime(tu="us",tz="GMT"))
      $to_r()
    ),
    as.POSIXct("2020-12-31 22:30:00",tz="GMT")
  )

  expect_grepl_error(
    pl$lit(as.Date("2021-01-01"))$dt$combine(1, tu="s"),
    "str to polars TimeUnit: \\[s\\] is not any of 'ns', 'us' or 'ms'"
  )


})


test_that("dt$strftime", {

  expect_identical(
    pl$lit(as.POSIXct("2021-01-02 12:13:14",tz="GMT"))$dt$strftime("this is the year: %Y")$to_r(),
    "this is the year: 2021"
  )

})


test_that("dt$year iso_year",{
  df = pl$DataFrame(
    date = pl$date_range(
      as.Date("2020-12-25"),
      as.Date("2021-1-05"),
      interval = "1d",
      time_zone = "GMT"
    )
  )$with_columns(
    pl$col("date")$dt$year()$alias("year"),
    pl$col("date")$dt$iso_year()$alias("iso_year")
  )

  #dput(lubridate::isoyear(df$to_list()$date))
  lubridate_iso_year = c(2020, 2020, 2020, 2020, 2020, 2020, 2020, 2020, 2020, 2020,2021, 2021)
  #dput(lubridate::year(df$to_list()$date))
  lubridate_year = c(2020, 2020, 2020, 2020, 2020, 2020, 2020, 2021, 2021, 2021,2021, 2021)
  expect_identical(
    df$get_column("iso_year")$to_r(),
    as.integer(lubridate_iso_year)
  )

  expect_identical(
    df$get_column("year")$to_r(),
    as.integer(lubridate_year)
  )
})


test_that("dt$quarter, month, day",{

  df = pl$DataFrame(
    date = pl$date_range(
      as.Date("2020-12-25"),
      as.Date("2021-1-05"),
      interval = "1d",
      time_zone = "GMT"
    )
  )$with_columns(
    pl$col("date")$dt$quarter()$alias("quarter"),
    pl$col("date")$dt$month()$alias("month"),
    pl$col("date")$dt$day()$alias("day")
  )


  # dput(df$to_list()$date |> (\(x) list(
  #   quarter = lubridate::quarter(x),
  #   month = lubridate::month(x),
  #   day = lubridate::day(x)
  # ))() |> lapply(as.numeric))
  l_exp = list(quarter = c(4, 4, 4, 4, 4, 4, 4, 1, 1, 1, 1, 1), month = c(12,
    12, 12, 12, 12, 12, 12, 1, 1, 1, 1, 1), day = c(25, 26, 27, 28,
    29, 30, 31, 1, 2, 3, 4, 5))

  expect_identical(
    df$select(pl$col(c("quarter","month","day")))$to_list(),
    l_exp
  )

})


test_that("hour minute",{

  df = pl$DataFrame(
    date = pl$date_range(
      as.Date("2020-12-25"),
      as.Date("2021-05-05"),
      interval = "1d2h3m4s",
      time_zone = "GMT"
    )
  )$with_columns(
    pl$col("date")$dt$hour()$alias("hour"),
    pl$col("date")$dt$minute()$alias("minute")
  )


  # dput(df$to_list()$date |> (\(x) list(
  #   hour = lubridate::hour(x),
  #   minute = lubridate::minute(x)
  # ))() |> lapply(as.numeric))
  l_exp =
    list(hour = c(0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 0, 2,
                  4, 6, 8, 10, 12, 14, 17, 19, 21, 23, 1, 3, 5, 7, 9, 11, 13, 15,
                  17, 19, 21, 23, 1, 3, 5, 7, 10, 12, 14, 16, 18, 20, 22, 0, 2,
                  4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 1, 3, 5, 7, 9, 11, 13, 15,
                  17, 19, 21, 23, 1, 3, 5, 7, 9, 11, 13, 15, 18, 20, 22, 0, 2,
                  4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 0, 2, 4, 6, 9, 11, 13, 15,
                  17, 19, 21, 23, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 2,
                  4, 6), minute = c(0, 3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33,
                                    36, 39, 42, 46, 49, 52, 55, 58, 1, 4, 7, 10, 13, 16, 19, 22,
                                    25, 28, 32, 35, 38, 41, 44, 47, 50, 53, 56, 59, 2, 5, 8, 11,
                                    14, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 0,
                                    4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34, 37, 40, 43, 46, 50,
                                    53, 56, 59, 2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 36, 39,
                                    42, 45, 48, 51, 54, 57, 0, 3, 6, 9, 12, 15, 18, 22, 25, 28, 31,
                                    34, 37, 40, 43, 46, 49, 52, 55, 58, 1, 4, 8))
  expect_identical(
    df$select(pl$col(c("hour","minute")))$to_list(),
    l_exp
  )

})



