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

})

test_that("truncate", {

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


##TODO  missing test for dt_round
