test_that("pl$datetime_range", {
  t1 = as.POSIXct("2022-01-01")
  t2 = as.POSIXct("2022-01-02")

  expect_identical(
    pl$datetime_range(start = t1, end = t2, interval = "6h")$to_r(),
    seq(t1, t2, by = as.difftime(6, units = "hours"))
  )
  expect_identical(
    pl$datetime_range(start = t1, end = t2, interval = "6h", time_zone = NULL)$to_r(),
    seq(t1, t2, by = as.difftime(6, units = "hours"))
  )
  expect_identical(
    pl$datetime_range(start = t1, end = t2, interval = "6h", time_zone = "GMT")$to_r(),
    seq(
      as.POSIXct("2022-01-01", tz = "GMT"),
      as.POSIXct("2022-01-02", tz = "GMT"),
      by = as.difftime(6, units = "hours")
    )
  )
  expect_identical(
    pl$datetime_range(start = t1, end = t2, interval = "3h", time_unit = "ms")$to_r(),
    seq(t1, t2, by = as.difftime(3, units = "hours"))
  )
  expect_identical(
    pl$datetime_range(start = t1, end = t2, interval = "3h", time_unit = "ns")$to_r(),
    seq(t1, t2, by = as.difftime(3, units = "hours"))
  )

  t1 = as.POSIXct("2022-01-01", tz = "GMT")
  t2 = as.POSIXct("2022-01-02", tz = "GMT")
  expect_identical(
    pl$datetime_range(start = t1, end = t2, interval = "6h", time_zone = NULL)$to_r(),
    seq(t1, t2, by = as.difftime(6, units = "hours"))
  )
  expect_identical(
    pl$datetime_range(start = t1, end = t2, interval = "6h", time_zone = "GMT")$to_r(),
    seq(t1, t2, by = as.difftime(6, units = "hours")) |> "attr<-"("tzone", "GMT")
  )
  expect_identical(
    pl$datetime_range(start = t1, end = t2, interval = "3h", time_unit = "ms")$to_r(),
    seq(t1, t2, by = as.difftime(3, units = "hours"))
  )
  expect_identical(
    pl$datetime_range(start = t1, end = t2, interval = "3h", time_unit = "ns")$to_r(),
    seq(t1, t2, by = as.difftime(3, units = "hours"))
  )


  t1 = as.POSIXct("2022-01-01", tz = "CET")
  t2 = as.POSIXct("2022-01-02", tz = "CET")
  expect_identical(
    pl$datetime_range(start = t1, end = t2, interval = "6h", time_zone = NULL)$to_r(),
    seq(t1, t2, by = as.difftime(6, units = "hours"))
  )
  expect_identical(
    pl$datetime_range(start = t1, end = t2, interval = "6h", time_zone = NULL)$to_r(),
    seq(t1, t2, by = as.difftime(6, units = "hours"))
  )

  expect_identical(
    pl$datetime_range(start = t1, end = t2, interval = "3h", time_unit = "ms")$to_r(),
    seq(t1, t2, by = as.difftime(3, units = "hours"))
  )
  expect_identical(
    pl$datetime_range(start = t1, end = t2, interval = "3h", time_unit = "ns")$to_r(),
    seq(t1, t2, by = as.difftime(3, units = "hours"))
  )


  # test difftime conversion to pl_duration
  t1 = as.POSIXct("2022-01-01", tz = "GMT")
  t2 = as.POSIXct("2022-01-10", tz = "GMT")
  for (i_diff_time in c("secs", "mins", "hours", "days", "weeks")) {
    expect_identical(
      pl$datetime_range(
        start = t1, end = t2,
        as.difftime(25, units = i_diff_time),
        time_unit = "ns"
      )$to_r(),
      seq(t1, t2, by = as.difftime(25, units = i_diff_time))
    )
  }
})

test_that("pl$date_range", {
  expect_identical(
    pl$date_range(
      as.Date("2022-01-01"), as.Date("2022-03-01"), "1mo"
    )$to_series()$to_vector(),
    seq(as.Date("2022-01-01"), as.Date("2022-03-01"), by = "1 month")
  )
})

test_that("dt$truncate", {
  # make a datetime
  t1 = as.POSIXct("3040-01-01", tz = "GMT")
  t2 = t1 + as.difftime(25, units = "secs")
  s = pl$datetime_range(t1, t2, interval = "2s", time_unit = "ms")

  # use a dt namespace function
  df = pl$DataFrame(datetime = s)$with_columns(
    pl$col("datetime")$dt$truncate("4s")$alias("truncated_4s")
  )

  l_actual = df$to_list()
  expect_identical(
    lapply(l_actual, \(x) diff(x) |> as.numeric()),
    list(
      datetime = rep(2, 12),
      truncated_4s = rep(c(0, 4), 6)
    )
  )
})


test_that("dt$round", {
  # make a datetime
  t1 = as.POSIXct("3040-01-01", tz = "GMT")
  t2 = t1 + as.difftime(24, units = "secs")
  s = pl$datetime_range(t1, t2, interval = "2s", time_unit = "ms")

  # use a dt namespace function
  df = pl$DataFrame(datetime = s)$with_columns(
    pl$col("datetime")$dt$round("8s")$alias("truncated_4s")
  )

  l_actual = df$to_list()
  expect_identical(
    lapply(l_actual, \(x) diff(x) |> as.numeric()),
    list(
      datetime = rep(2, 12),
      truncated_4s = rep(c(0, 8, 0, 0), 3)
    )
  )

  expect_grepl_error(
    pl$col("datetime")$dt$round(42),
    "`every` must be a single non-NA character or difftime"
  )
  expect_grepl_error(
    pl$col("datetime")$dt$round(c("2s", "1h")),
    "`every` must be a single non-NA character or difftime"
  )
})

test_that("dt$combine", {
  # Using pl$PTime
  expect_identical(
    (
      pl$lit(as.Date("2021-01-01"))
      $dt$combine(pl$PTime("02:34:12"))
      $cast(pl$Datetime("us", "GMT"))
      $to_r()
    ),
    as.POSIXct("2021-01-01 02:34:12", tz = "GMT")
  )

  expect_identical(
    (
      pl$lit(as.Date("2021-01-01"))
      $dt$combine(pl$PTime(3600 * 1.5E3, tu = "ms"))
      $cast(pl$Datetime("us", "GMT"))
      $to_r()
    ),
    as.POSIXct("2021-01-01 01:30:00", tz = "GMT")
  )

  expect_identical(
    (
      pl$lit(as.Date("2021-01-01"))
      $dt$combine(3600 * 1.5E9, time_unit = "ns")
      $cast(pl$Datetime("us", "GMT"))
      $to_r()
    ),
    as.POSIXct("2021-01-01 01:30:00", tz = "GMT")
  )

  expect_identical(
    (
      pl$lit(as.Date("2021-01-01"))
      $dt$combine(-3600 * 1.5E9, time_unit = "ns")
      $cast(pl$Datetime("us", "GMT"))
      $to_r()
    ),
    as.POSIXct("2020-12-31 22:30:00", tz = "GMT")
  )

  expect_grepl_error(
    pl$lit(as.Date("2021-01-01"))$dt$combine(1, time_unit = "s")
  )
})


test_that("dt$strftime", {
  expect_identical(
    pl$lit(as.POSIXct("2021-01-02 12:13:14", tz = "GMT"))$dt$strftime("this is the year: %Y")$to_r(),
    "this is the year: 2021"
  )
})


test_that("dt$year iso_year", {
  df = pl$DataFrame(
    date = pl$datetime_range(
      as.Date("2020-12-25"),
      as.Date("2021-1-05"),
      interval = "1d",
      time_zone = "GMT"
    )
  )$with_columns(
    pl$col("date")$dt$year()$alias("year"),
    pl$col("date")$dt$iso_year()$alias("iso_year")
  )

  # dput(lubridate::isoyear(df$to_list()$date))
  lubridate_iso_year = c(2020, 2020, 2020, 2020, 2020, 2020, 2020, 2020, 2020, 2020, 2021, 2021)
  # dput(lubridate::year(df$to_list()$date))
  lubridate_year = c(2020, 2020, 2020, 2020, 2020, 2020, 2020, 2021, 2021, 2021, 2021, 2021)
  expect_identical(
    df$get_column("iso_year")$to_r(),
    as.integer(lubridate_iso_year)
  )

  expect_identical(
    df$get_column("year")$to_r(),
    as.integer(lubridate_year)
  )
})


test_that("dt$quarter, month, day", {
  df = pl$DataFrame(
    date = pl$datetime_range(
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
  l_exp = list(
    quarter = c(4, 4, 4, 4, 4, 4, 4, 1, 1, 1, 1, 1),
    month = c(12, 12, 12, 12, 12, 12, 12, 1, 1, 1, 1, 1),
    day = c(25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5)
  )

  expect_identical(
    df$select(pl$col(c("quarter", "month", "day")))$to_list() |> lapply(as.numeric),
    l_exp
  )
})


test_that("hour minute", {
  df = pl$DataFrame(
    date = pl$datetime_range(
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
  l_exp = list(
    hour = c(
      0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 0, 2,
      4, 6, 8, 10, 12, 14, 17, 19, 21, 23, 1, 3, 5, 7, 9, 11, 13, 15,
      17, 19, 21, 23, 1, 3, 5, 7, 10, 12, 14, 16, 18, 20, 22, 0, 2,
      4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 1, 3, 5, 7, 9, 11, 13, 15,
      17, 19, 21, 23, 1, 3, 5, 7, 9, 11, 13, 15, 18, 20, 22, 0, 2,
      4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 0, 2, 4, 6, 9, 11, 13, 15,
      17, 19, 21, 23, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 2,
      4, 6
    ),
    minute = c(
      0, 3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33,
      36, 39, 42, 46, 49, 52, 55, 58, 1, 4, 7, 10, 13, 16, 19, 22,
      25, 28, 32, 35, 38, 41, 44, 47, 50, 53, 56, 59, 2, 5, 8, 11,
      14, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 0,
      4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34, 37, 40, 43, 46, 50,
      53, 56, 59, 2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 36, 39,
      42, 45, 48, 51, 54, 57, 0, 3, 6, 9, 12, 15, 18, 22, 25, 28, 31,
      34, 37, 40, 43, 46, 49, 52, 55, 58, 1, 4, 8
    )
  )
  expect_identical(
    df$select(pl$col(c("hour", "minute")))$to_list() |> lapply(as.numeric),
    l_exp
  )
})



test_that("second, milli, micro, nano", {
  df = pl$DataFrame(
    date = pl$datetime_range(
      as.Date("2020-12-25"),
      as.Date("2021-05-05"),
      interval = "2h3m4s555ms666us777ns",
      time_zone = "GMT",
      time_unit = "ns"
    )$to_series()
  )$with_columns(
    pl$col("date")$dt$second()$alias("second"),
    pl$col("date")$dt$second(fractional = TRUE)$alias("second_frac"),
    pl$col("date")$dt$millisecond()$alias("millisecond"),
    pl$col("date")$dt$microsecond()$alias("microsecond"),
    pl$col("date")$dt$nanosecond()$alias("nanosecond"),
    pl$col("date")$cast(pl$Float64)$alias("f64")
  )

  # check s
  expect_identical(
    as.numeric(df$get_column("second")$to_r()),
    as.numeric(format(df$get_column("date")$to_r(), "%S"))
  )
  n = df$get_column("f64")$to_r() / 1E9
  expect_equal(
    df$get_column("second_frac")$to_r(),
    as.numeric(format(df$get_column("date")$to_r(), "%S"))
    + n - floor(n)
  )

  # check millisecond versus micro nano
  expect_identical(
    floor(df$get_column("microsecond")$to_r() / 1000),
    as.numeric(df$get_column("millisecond")$to_r())
  )
  expect_identical(
    floor(df$get_column("nanosecond")$to_r() / 1000),
    as.numeric(df$get_column("microsecond")$to_r())
  )


  # TODO No longer TRUE since rust-polars 0.30 -> 0.32. Don't know why or of less or more correct.
  # check milli micro versus
  # n = df$get_column("f64")$to_r() / 1E9
  # expect_identical(
  #   round((n - floor(n)) * 1E3),
  #   as.numeric(df$get_column("millisecond")$to_r())
  # )
  # expect_identical(
  #   round((n - floor(n)) * 1E6),
  #   as.numeric(df$get_column("microsecond")$to_r())
  # )
})

test_that("offset_by", {
  df = pl$DataFrame(
    dates = pl$date_range(
      as.Date("2000-1-1"), as.Date("2005-1-1"), "1y"
    )
  )
  l_actual = df$with_columns(
    pl$col("dates")$dt$offset_by("1y")$alias("date_plus_1y"),
    pl$col("dates")$dt$offset_by("-1y2mo")$alias("date_min")
  )$to_list()


  # helper function to add whole years and months
  add_yemo = \(dates, years, months) {
    as.POSIXlt(dates) |>
      unclass() |>
      (\(x) {
        l_ym = mapply(y = x$year, m = x$mon, FUN = \(y, m) {
          y = y + years
          m = m + months
          if (m < 0L) {
            y = y - 1L
            m = m + 12L
          }
          if (m >= 12L) {
            y = y + 1L
            m = m - 12L
          }
          c(y, m)
        }, SIMPLIFY = FALSE)

        x$year = l_ym |> sapply(head, 1)
        x$mon = l_ym |> sapply(tail, 1)
        class(x) = "POSIXlt"
        x
      })() |>
      as.Date()
  }

  # compute offset_by with base R
  dates = df$to_list()$dates
  l_expected = list(
    dates = dates,
    date_plus_1y = add_yemo(dates, 1, 0),
    date_min = add_yemo(dates, -1, -2)
  )

  # compare
  expect_identical(
    l_actual,
    l_expected
  )

  # using expression in arg "by"
  df = pl$DataFrame(
    dates = pl$datetime_range(
      as.POSIXct("2022-01-01", tz = "GMT"),
      as.POSIXct("2022-01-02", tz = "GMT"),
      interval = "6h", time_unit = "ms", time_zone = "GMT"
    )$to_r(),
    offset = c("1d", "-2d", "1mo", NA, "1y")
  )
  expect_identical(
    df$with_columns(pl$col("dates")$dt$offset_by(pl$col("offset")))$to_data_frame()[["dates"]],
    as.POSIXct(
      c(
        "2022-01-02 00:00:00", "2021-12-30 06:00:00", "2022-02-01 12:00:00", NA,
        "2023-01-02 00:00:00"
      ),
      tz = "GMT"
    )
  )
})



test_that("dt$epoch", {
  df = pl$select(
    as_polars_series(as.Date("2022-1-1"))$dt$epoch("ns")$alias("e_ns"),
    as_polars_series(as.Date("2022-1-1"))$dt$epoch("us")$alias("e_us"),
    as_polars_series(as.Date("2022-1-1"))$dt$epoch("ms")$alias("e_ms"),
    as_polars_series(as.Date("2022-1-1"))$dt$epoch("s")$alias("e_s"),
    as_polars_series(as.Date("2022-1-1"))$dt$epoch("d")$alias("e_d")
  )
  l_act = df$to_list()

  base_r_s_epochs = as.numeric(as.POSIXct("2022-1-1", tz = "GMT"))
  expect_identical(as.numeric(l_act$e_s), base_r_s_epochs)
  expect_identical(as.numeric(l_act$e_ms), base_r_s_epochs * 1E3)
  expect_identical(as.numeric(l_act$e_us), base_r_s_epochs * 1E6)
  expect_identical(suppressWarnings(as.numeric(l_act$e_ns)), base_r_s_epochs * 1E9)

  base_r_d_epochs = as.integer(as.Date("2022-1-1"))
  expect_identical(l_act$e_d, base_r_d_epochs)

  expect_grepl_error(
    as_polars_series(as.Date("2022-1-1"))$dt$epoch("bob"),
    "should be one of"
  )
  expect_grepl_error(
    as_polars_series(as.Date("2022-1-1"))$dt$epoch(42),
    "must be NULL or a character vector"
  )
})


test_that("dt$timestamp", {
  df = pl$DataFrame(
    date = pl$date_range(
      start = as.Date("2001-1-1"), end = as.Date("2001-1-3"), interval = "1d"
    )
  )
  l_exp = df$select(
    pl$col("date"),
    pl$col("date")$dt$timestamp()$alias("timestamp_ns"),
    pl$col("date")$dt$timestamp(tu = "us")$alias("timestamp_us"),
    pl$col("date")$dt$timestamp(tu = "ms")$alias("timestamp_ms")
  )$to_list()

  base_r_s_timestamp = as.numeric(seq(
    as.POSIXct("2001-1-1", tz = "GMT"),
    as.POSIXct("2001-1-3", tz = "GMT"),
    by = as.difftime(1, units = "days")
  ))


  expect_identical(as.numeric(l_exp$timestamp_ms), base_r_s_timestamp * 1E3)
  expect_identical(as.numeric(l_exp$timestamp_us), base_r_s_timestamp * 1E6)
  expect_identical(suppressWarnings(as.numeric(l_exp$timestamp_ns)), base_r_s_timestamp * 1E9)

  expect_grepl_error(
    as_polars_series(as.Date("2022-1-1"))$dt$timestamp("bob")
  )

  expect_grepl_error(
    as_polars_series(as.Date("2022-1-1"))$dt$timestamp(42)
  )
})


test_that("dt$with_time_unit cast_time_unit", {
  df_time = pl$DataFrame(
    date = pl$datetime_range(
      start = as.POSIXct("2001-1-1"), end = as.POSIXct("2001-1-3"), interval = "1d", time_unit = "us"
    )
  )$select(
    pl$col("date"),
    pl$col("date")$dt$cast_time_unit()$alias("cast_time_unit_ns"),
    pl$col("date")$dt$cast_time_unit(tu = "us")$alias("cast_time_unit_us"),
    pl$col("date")$dt$cast_time_unit(tu = "ms")$alias("cast_time_unit_ms"),
    pl$col("date")$dt$with_time_unit()$alias("with_time_unit_ns"),
    pl$col("date")$dt$with_time_unit(tu = "us")$alias("with_time_unit_us"),
    pl$col("date")$dt$with_time_unit(tu = "ms")$alias("with_time_unit_ms")
  )

  l_exp = df_time$select(
    pl$all()$cast(pl$Float64)
  )$to_list()


  # cast time unit changes the value
  expect_identical(l_exp$cast_time_unit_ns, l_exp$cast_time_unit_us * 1E3)
  expect_identical(l_exp$cast_time_unit_us, l_exp$cast_time_unit_ms * 1E3)

  # with does not
  expect_identical(l_exp$with_time_unit_ns, l_exp$with_time_unit_us)
  expect_identical(l_exp$with_time_unit_us, l_exp$with_time_unit_ms)

  # both with and cast change the value
  types = df_time$schema
  expect_true(types$with_time_unit_ns == pl$Datetime("ns"))
  expect_true(types$with_time_unit_us == pl$Datetime("us"))
  expect_true(types$with_time_unit_ms == pl$Datetime("ms"))

  expect_true(types$cast_time_unit_ns == pl$Datetime("ns"))
  expect_true(types$cast_time_unit_us == pl$Datetime("us"))
  expect_true(types$cast_time_unit_ms == pl$Datetime("ms"))

  # cast wrong inputs
  expect_grepl_error(
    as_polars_series(as.Date("2022-1-1"))$dt$cast_time_unit("bob"),
    r"{The argument \[tu\] caused an error}"
  )
  expect_grepl_error(
    as_polars_series(as.Date("2022-1-1"))$dt$cast_time_unit(42),
    r"{Expected a value of type \[\&str\]}"
  )

  # with wrong inputs
  expect_grepl_error(
    as_polars_series(as.Date("2022-1-1"))$dt$with_time_unit("bob"),
    r"{The argument \[tu\] caused an error}"
  )

  expect_grepl_error(
    as_polars_series(as.Date("2022-1-1"))$dt$with_time_unit(42),
    r"{Expected a value of type \[\&str\]}"
  )
})

test_that("$convert_time_zone() works", {
  df_time = pl$DataFrame(
    date = pl$datetime_range(
      start = as.Date("2001-3-1"),
      end = as.Date("2001-5-1"),
      interval = "1mo",
      time_zone = "UTC"
    )
  )
  df_casts = df_time$with_columns(
    pl$col("date")
    $dt$convert_time_zone("Europe/London")
    $alias("London")
  )

  orig_r = as.POSIXct(
    c("2001-03-01 00:00:00", "2001-04-01 00:00:00", "2001-05-01 00:00:00"),
    tz = "UTC"
  )
  new_r = orig_r
  attributes(new_r)$tzone = "Europe/London"

  expect_equal(
    df_casts$to_list()[["London"]],
    new_r
  )
})

test_that("dt$replace_time_zone() works", {
  df = pl$DataFrame(
    london_timezone = pl$datetime_range(
      start = as.POSIXct("2001-3-1"),
      end = as.POSIXct("2001-7-1"),
      interval = "1mo",
      time_zone = "Europe/London"
    )
  )

  df = df$with_columns(
    pl$col("london_timezone")
    $dt$replace_time_zone("Europe/Amsterdam")
    $alias("Amsterdam")
  )
  l = df$to_list()

  expect_identical(
    as.numeric(l$london_timezone - l$Amsterdam),
    rep(1, 5)
  )

  r_amst_tz = l$london_timezone - 3600
  attr(r_amst_tz, "tzone") = "Europe/Amsterdam"

  expect_identical(
    l$Amsterdam,
    r_amst_tz
  )
})

test_that("replace_time_zone for ambiguous time", {
  skip_if_not_installed("lubridate")

  x = seq(as.POSIXct("2018-10-28 01:30", tz = "UTC"), as.POSIXct("2018-10-28 02:30", tz = "UTC"), by = "30 min")

  pl_out = pl$DataFrame(x = x)$with_columns(
    pl$col("x")$dt$replace_time_zone("Europe/Brussels", ambiguous = "earliest")$alias("earliest"),
    pl$col("x")$dt$replace_time_zone("Europe/Brussels", ambiguous = "latest")$alias("latest"),
    pl$col("x")$dt$replace_time_zone("Europe/Brussels", ambiguous = "null")$alias("null")
  )$to_data_frame()

  lubridate_out = data.frame(
    x = x,
    earliest = lubridate::force_tz(x, "Europe/Brussels", roll_dst = c("NA", "pre")),
    latest = lubridate::force_tz(x, "Europe/Brussels", roll_dst = c("NA", "post")),
    null = as.POSIXct(c("2018-10-28 01:30:00 CEST", NA, NA), tz = "Europe/Brussels")
  )

  expect_equal(pl_out, lubridate_out)
})


test_that("dt$days, dt$hours, dt$mminutes, dt$seconds, + ms, us, ns", {
  # diff with settable units
  diffy = \(x, units) as.numeric(diff(x), units = units)
  # days
  df = pl$DataFrame(date = pl$date_range(
    start = as.Date("2020-3-1"), end = as.Date("2020-5-1"), interval = "1mo"
  ))$with_columns(
    pl$col("date")$diff()$dt$total_days()$alias("diff")
  )$to_list()
  expect_identical(df$diff, c(NA, diffy(df$date, "days")))

  # hours
  df = pl$DataFrame(date = pl$date_range(
    start = as.Date("2020-1-1"), end = as.Date("2020-1-4"), interval = "1d"
  ))$with_columns(
    pl$col("date")$diff()$dt$total_hours()$alias("diff")
  )$to_list()
  expect_identical(df$diff, c(NA, diffy(df$date, "hours")))

  # minutes
  df = pl$DataFrame(date = pl$date_range(
    start = as.Date("2020-1-1"), end = as.Date("2020-1-4"), interval = "1d"
  ))$with_columns(
    pl$col("date")$diff()$dt$total_minutes()$alias("diff")
  )$to_list()
  expect_identical(df$diff, c(NA, diffy(df$date, "mins")))

  # seconds
  df = pl$DataFrame(date = pl$datetime_range(
    start = as.Date("2020-1-1"), end = as.POSIXct("2020-1-1 00:04:00", tz = "GMT"),
    interval = "1m"
  ))$with_columns(
    pl$col("date")$diff()$dt$total_seconds()$alias("diff")
  )$to_list()
  expect_identical(df$diff, c(NA, diffy(df$date, "secs")))


  # milliseconds
  df = pl$DataFrame(date = pl$datetime_range(
    start = as.Date("2020-1-1"), end = as.POSIXct("2020-1-1 00:04:00", tz = "GMT"),
    interval = "1m"
  ))$with_columns(
    pl$col("date")$diff()$dt$total_milliseconds()$alias("diff")
  )$to_list()
  expect_identical(df$diff, c(NA, diffy(df$date, "secs")) * 1000)

  # microseconds
  df = pl$DataFrame(date = pl$datetime_range(
    start = as.Date("2020-1-1"), end = as.POSIXct("2020-1-1 00:04:00", tz = "GMT"),
    interval = "1m"
  ))$with_columns(
    pl$col("date")$diff()$dt$total_microseconds()$alias("diff")
  )$to_list()
  expect_identical(df$diff, c(NA, diffy(df$date, "secs")) * 1E6)

  # nanoseconds
  df = pl$DataFrame(date = pl$datetime_range(
    start = as.Date("2020-1-1"), end = as.POSIXct("2020-1-1 00:04:00", tz = "GMT"),
    interval = "1m"
  ))$with_columns(
    pl$col("date")$diff()$dt$total_nanoseconds()$alias("diff")
  )$to_list()
  expect_identical(df$diff, c(NA, diffy(df$date, "secs")) * 1E9)
})

test_that("$dt$time()", {
  df = pl$DataFrame(
    dates = pl$datetime_range(
      as.Date("2000-1-1"),
      as.Date("2000-1-2"),
      "6h"
    )
  )
  expect_identical(
    as.numeric(df$select(times = pl$col("dates")$dt$time())$to_list()[[1]]),
    c(0.00e+00, 2.16e+13, 4.32e+13, 6.48e+13, 0.00e+00)
  )
})

test_that("$dt$is_leap_year()", {
  df = pl$DataFrame(
    date = as.Date(c("2000-01-01", "2001-01-01", "2002-01-01")),
    datetime = pl$datetime_range(as.Date("2000-01-01"), as.Date("2002-01-01"), "1y")
  )

  expect_equal(
    df$select(leap_year = pl$col("date")$dt$is_leap_year())$to_list(),
    list(leap_year = c(TRUE, FALSE, FALSE))
  )
  expect_equal(
    df$select(leap_year = pl$col("datetime")$dt$is_leap_year())$to_list(),
    list(leap_year = c(TRUE, FALSE, FALSE))
  )
})
