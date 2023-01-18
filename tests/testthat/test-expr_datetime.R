

test_that("pl$date_range", {

  #make a datetime
  t_ms = unclass(as.POSIXct("2022-01-01",tz = "GMT",origin="GMT")) * 1000
  s = pl$date_range(t_ms,t_ms+25000, interval = "2s", time_unit = "ms", time_zone = "GMT")

  #use a dt namespace function
  df = pl$DataFrame(datetime = s)$with_columns(
    pl$col("datetime")$dt$truncate("4s")$alias("truncated_10s")
  )

  #TODO
  #implement datetime to r
  #df$to_list()
  #s$to_r()

})
