test_that("pl$datetime_range", {
  # no TZ -------------------------------------------
  t1 <- as.POSIXct("2022-01-01")
  t2 <- as.POSIXct("2022-01-02")

  expect_equal(
    pl$select(x = pl$datetime_range(start = t1, end = t2, interval = "6h")),
    pl$DataFrame(x = seq(t1, t2, by = as.difftime(6, units = "hours")))
  )
  expect_equal(
    pl$select(x = pl$datetime_range(start = t1, end = t2, interval = "6h", time_zone = NULL)),
    pl$DataFrame(x = seq(t1, t2, by = as.difftime(6, units = "hours")))
  )

  expect_equal(
    pl$select(x = pl$datetime_range(start = t1, end = t2, interval = "6h", time_zone = "GMT")),
    pl$DataFrame(x = seq(as.POSIXct("2022-01-01", tz = "GMT"), as.POSIXct("2022-01-02", tz = "GMT"), by = as.difftime(6, units = "hours")))
  )

  expect_equal(
    pl$select(x = pl$datetime_range(start = t1, end = t2, interval = "3h", time_unit = "ms")),
    pl$DataFrame(x = seq(t1, t2, by = as.difftime(3, units = "hours")))
  )

  expect_equal(
    pl$select(x = pl$datetime_range(start = t1, end = t2, interval = "3h", time_unit = "ns")),
    pl$DataFrame(x = seq(t1, t2, by = as.difftime(3, units = "hours")))$cast(pl$Datetime("ns"))
  )

  # GMT -------------------------------------------

  t1 <- as.POSIXct("2022-01-01", tz = "GMT")
  t2 <- as.POSIXct("2022-01-02", tz = "GMT")
  expect_equal(
    pl$select(x = pl$datetime_range(start = t1, end = t2, interval = "6h", time_zone = NULL)),
    pl$DataFrame(x = seq(t1, t2, by = as.difftime(6, units = "hours")))
  )

  expect_equal(
    pl$select(x = pl$datetime_range(start = t1, end = t2, interval = "6h", time_zone = "GMT")),
    pl$DataFrame(x = (seq(t1, t2, by = as.difftime(6, units = "hours")) |> "attr<-"("tzone", "GMT")))
  )
  expect_equal(
    pl$select(x = pl$datetime_range(start = t1, end = t2, interval = "3h", time_unit = "ms")),
    pl$DataFrame(x = seq(t1, t2, by = as.difftime(3, units = "hours")))
  )

  expect_equal(
    pl$select(x = pl$datetime_range(start = t1, end = t2, interval = "3h", time_unit = "ns")),
    pl$DataFrame(x = seq(t1, t2, by = as.difftime(3, units = "hours")))$cast(pl$Datetime("ns", time_zone = "GMT"))
  )

  # CET -------------------------------------------

  t1 <- as.POSIXct("2022-01-01", tz = "CET")
  t2 <- as.POSIXct("2022-01-02", tz = "CET")
  expect_equal(
    pl$select(x = pl$datetime_range(start = t1, end = t2, interval = "6h", time_zone = NULL)),
    pl$DataFrame(x = seq(t1, t2, by = as.difftime(6, units = "hours")))
  )

  expect_equal(
    pl$select(x = pl$datetime_range(start = t1, end = t2, interval = "6h", time_zone = NULL)),
    pl$DataFrame(x = seq(t1, t2, by = as.difftime(6, units = "hours")))
  )

  expect_equal(
    pl$select(x = pl$datetime_range(start = t1, end = t2, interval = "3h", time_unit = "ms")),
    pl$DataFrame(x = seq(t1, t2, by = as.difftime(3, units = "hours")))
  )

  expect_equal(
    pl$select(x = pl$datetime_range(start = t1, end = t2, interval = "3h", time_unit = "ns")),
    pl$DataFrame(x = seq(t1, t2, by = as.difftime(3, units = "hours")))$cast(pl$Datetime("ns", time_zone = "CET"))
  )

  # test difftime conversion to pl_duration
  t1 <- as.POSIXct("2022-01-01", tz = "GMT")
  t2 <- as.POSIXct("2022-01-10", tz = "GMT")
  for (i_diff_time in c("secs", "mins", "hours", "days", "weeks")) {
    expect_equal(
      pl$select(x = pl$datetime_range(start = t1, end = t2, as.difftime(25, units = i_diff_time), time_unit = "ns")),
      pl$DataFrame(x = seq(t1, t2, by = as.difftime(25, units = i_diff_time)))$cast(pl$Datetime("ns", "GMT"))
    )
  }
})

test_that("pl$date_range", {
  expect_equal(
    pl$select(x = pl$date_range(
      as.Date("2022-01-01"), as.Date("2022-03-01"), "1mo"
    )),
    pl$DataFrame(x = seq(as.Date("2022-01-01"), as.Date("2022-03-01"), by = "1 month"))
  )
})

test_that("dt$truncate", {
  t1 <- as.POSIXct("2020-01-01", tz = "GMT")
  t2 <- t1 + as.difftime(59, units = "secs")
  s <- pl$datetime_range(t1, t2, interval = "5s", time_unit = "ms")
  df <- pl$select(datetime = s)$with_columns(
    pl$col("datetime")$dt$truncate("15s")$alias("truncated_15s")
  )

  expect_equal(
    df$select(pl$col("truncated_15s")$dt$second()),
    pl$DataFrame(truncated_15s = rep(seq(0, 45, by = 15), each = 3))$cast(pl$Int8)
  )
})

test_that("dt$round", {
  t1 <- as.POSIXct("2020-01-01", tz = "GMT")
  t2 <- t1 + as.difftime(59, units = "secs")
  s <- pl$datetime_range(t1, t2, interval = "5s", time_unit = "ms")
  df <- pl$select(datetime = s)$with_columns(
    pl$col("datetime")$dt$round("15s")$alias("rounded_15s")
  )
  expect_equal(
    df$select(pl$col("rounded_15s")$dt$second()),
    pl$DataFrame(rounded_15s = c(0, 0, 15, 15, 15, 30, 30, 30, 45, 45, 45, 0))$cast(pl$Int8)
  )

  expect_snapshot(
    pl$col("datetime")$dt$round(42),
    error = TRUE
  )
  expect_snapshot(
    pl$col("datetime")$dt$round(c("2s", "1h")),
    error = TRUE
  )
})

test_that("dt$combine", {
  skip_if_not_installed("hms")
  expect_equal(
    pl$DataFrame(x = as.Date("2021-01-01"))$
      with_columns(
      pl$col("x")$dt$combine(hms::parse_hms("02:34:12"))$
        cast(pl$Datetime("ms", "GMT"))
    ),
    pl$DataFrame(x = as.POSIXct("2021-01-01 02:34:12", tz = "GMT"))
  )

  expect_snapshot(
    pl$lit(as.Date("2021-01-01"))$dt$combine(1, time_unit = "s"),
    error = TRUE
  )
})

test_that("dt$strftime and dt$to_string", {
  expect_equal(
    pl$DataFrame(x = as.POSIXct("2021-01-02 12:13:14", tz = "GMT"))$with_columns(pl$col("x")$dt$strftime("this is the year: %Y")),
    pl$DataFrame(x = "this is the year: 2021")
  )
  expect_equal(
    pl$DataFrame(x = as.POSIXct("2021-01-02 12:13:14", tz = "GMT"))$with_columns(pl$col("x")$dt$to_string("this is the year: %Y")),
    pl$DataFrame(x = "this is the year: 2021")
  )
})

test_that("dt$year iso_year", {
  df <- pl$select(
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

  iso_years <- c(2020L, 2020L, 2020L, 2020L, 2020L, 2020L, 2020L, 2020L, 2020L, 2020L, 2021L, 2021L)
  years <- c(2020L, 2020L, 2020L, 2020L, 2020L, 2020L, 2020L, 2021L, 2021L, 2021L, 2021L, 2021L)
  expect_equal(
    df$select("iso_year"),
    pl$DataFrame(iso_year = iso_years)
  )

  expect_equal(
    df$select("year"),
    pl$DataFrame(year = years)
  )
})


test_that("dt$quarter, month, day", {
  df <- pl$select(
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
  l_exp <- list(
    quarter = c(4, 4, 4, 4, 4, 4, 4, 1, 1, 1, 1, 1),
    month = c(12, 12, 12, 12, 12, 12, 12, 1, 1, 1, 1, 1),
    day = c(25, 26, 27, 28, 29, 30, 31, 1, 2, 3, 4, 5)
  )

  expect_equal(
    df$select(pl$col("quarter", "month", "day")$cast(pl$Float64)),
    pl$DataFrame(!!!l_exp)
  )
})


test_that("hour minute", {
  df <- pl$select(
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
  l_exp <- list(
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
  expect_equal(
    df$select(pl$col("hour", "minute")$cast(pl$Float64)),
    pl$DataFrame(!!!l_exp)
  )
})


test_that("second, milli, micro, nano", {
  df <- pl$select(
    date = pl$datetime_range(
      as.Date("2020-12-25"),
      as.Date("2021-05-05"),
      interval = "2h3m4s555ms666us777ns",
      time_zone = "GMT",
      time_unit = "ns"
    )
  )$with_columns(
    pl$col("date")$dt$second()$alias("second"),
    pl$col("date")$dt$second(fractional = TRUE)$alias("second_frac"),
    pl$col("date")$dt$millisecond()$alias("millisecond"),
    pl$col("date")$dt$microsecond()$alias("microsecond"),
    pl$col("date")$dt$nanosecond()$alias("nanosecond"),
    pl$col("date")$cast(pl$Float64)$alias("f64")
  )

  # check s
  expect_equal(
    df$select("second"),
    pl$DataFrame(
      !!!df$select(second = "date") |>
        as.list() |>
        lapply(format, "%S") |>
        lapply(as.numeric)
    )$cast(pl$Int8)
  )

  # check fractional second
  vals <- df$select("f64") |>
    as_polars_series() |>
    as.vector()
  vals <- vals$f64
  n <- vals / 1E9

  frac <- df$select("second_frac") |>
    as_polars_series() |>
    as.vector()
  frac <- frac$second_frac

  dts <- df$select("date") |>
    as_polars_series() |>
    as.vector()
  dts <- dts$date

  expect_equal(
    frac,
    as.numeric(format(dts, "%S")) + n - floor(n)
  )

  # check millisecond versus micro nano
  expect_equal(
    df$select(millisecond = pl$col("microsecond") / 1000)$cast(pl$Int64),
    df$select(pl$col("millisecond"))$cast(pl$Int64)
  )
  expect_equal(
    df$select(microsecond = pl$col("nanosecond") / 1000)$cast(pl$Int64),
    df$select(pl$col("microsecond"))$cast(pl$Int64)
  )
})

test_that("offset_by", {
  vals <- c(
    as.Date("2000-1-1"), as.Date("2000-1-2"), as.Date("2000-1-3"),
    as.Date("2000-1-4"), as.Date("2000-1-5")
  )
  df <- pl$DataFrame(dates = vals)
  l_actual <- df$with_columns(
    pl$col("dates")$dt$offset_by("1y")$alias("date_plus_1y"),
    pl$col("dates")$dt$offset_by("-1y2mo")$alias("date_min")
  )

  # helper function to add whole years and months
  add_yemo <- \(dates, years, months) {
    as.POSIXlt(dates) |>
      unclass() |>
      (\(x) {
        l_ym <- mapply(y = x$year, m = x$mon, FUN = \(y, m) {
          y <- y + years
          m <- m + months
          if (m < 0L) {
            y <- y - 1L
            m <- m + 12L
          }
          if (m >= 12L) {
            y <- y + 1L
            m <- m - 12L
          }
          c(y, m)
        }, SIMPLIFY = FALSE)

        x$year <- l_ym |> sapply(head, 1)
        x$mon <- l_ym |> sapply(tail, 1)
        class(x) <- "POSIXlt"
        x
      })() |>
      as.Date()
  }

  # compute offset_by with base R
  l_expected <- pl$DataFrame(
    dates = vals,
    date_plus_1y = add_yemo(vals, 1, 0),
    date_min = add_yemo(vals, -1, -2)
  )

  # compare
  expect_equal(l_actual, l_expected)

  # using expression in arg "by"
  df <- pl$select(
    dates = pl$datetime_range(
      as.POSIXct("2022-01-01", tz = "GMT"),
      as.POSIXct("2022-01-02", tz = "GMT"),
      interval = "6h", time_unit = "ms", time_zone = "GMT"
    ),
    offset = pl$lit(c("1d", "-2d", "1mo", NA, "1y"))
  )
  expect_equal(
    df$select(pl$col("dates")$dt$offset_by(pl$col("offset"))),
    pl$DataFrame(dates = as.POSIXct(
      c(
        "2022-01-02 00:00:00", "2021-12-30 06:00:00", "2022-02-01 12:00:00", NA,
        "2023-01-02 00:00:00"
      ),
      tz = "GMT"
    ))
  )
})

test_that("dt$epoch", {
  df <- pl$DataFrame(x = as.Date("2022-1-1"))$select(
    pl$col("x")$dt$epoch("ns")$alias("e_ns"),
    pl$col("x")$dt$epoch("us")$alias("e_us"),
    pl$col("x")$dt$epoch("ms")$alias("e_ms"),
    pl$col("x")$dt$epoch("s")$alias("e_s"),
    pl$col("x")$dt$epoch("d")$alias("e_d")
  )

  base_r_s_epochs <- as.numeric(as.POSIXct("2022-1-1", tz = "GMT"))
  expect_equal(
    df$select("e_s"),
    pl$DataFrame(e_s = base_r_s_epochs)$cast(pl$Int64)
  )
  expect_equal(
    df$select("e_ms"),
    pl$DataFrame(e_ms = base_r_s_epochs * 1E3)$cast(pl$Int64)
  )
  expect_equal(
    df$select("e_us"),
    pl$DataFrame(e_us = base_r_s_epochs * 1E6)$cast(pl$Int64)
  )
  expect_equal(
    df$select("e_ns"),
    pl$DataFrame(e_ns = base_r_s_epochs * 1E9)$cast(pl$Int64)
  )

  base_r_d_epochs <- as.integer(as.Date("2022-1-1"))
  expect_equal(
    df$select("e_d"),
    pl$DataFrame(e_d = base_r_d_epochs)$cast(pl$Int32)
  )
  expect_snapshot(
    as_polars_series(as.Date("2022-1-1"))$dt$epoch("bob"),
    error = TRUE
  )

  expect_snapshot(
    as_polars_series(as.Date("2022-1-1"))$dt$epoch(42),
    error = TRUE
  )
})


test_that("dt$timestamp", {
  df <- pl$select(
    date = pl$date_range(
      start = as.Date("2001-1-1"), end = as.Date("2001-1-3"), interval = "1d"
    )
  )
  l_exp <- df$select(
    pl$col("date")$dt$timestamp("ns")$alias("timestamp_ns"),
    pl$col("date")$dt$timestamp(time_unit = "us")$alias("timestamp_us"),
    pl$col("date")$dt$timestamp(time_unit = "ms")$alias("timestamp_ms")
  )

  base_r_s_timestamp <- as.numeric(seq(
    as.POSIXct("2001-1-1", tz = "GMT"),
    as.POSIXct("2001-1-3", tz = "GMT"),
    by = as.difftime(1, units = "days")
  ))

  expect_equal(
    l_exp,
    pl$DataFrame(
      timestamp_ns = base_r_s_timestamp * 1e9,
      timestamp_us = base_r_s_timestamp * 1e6,
      timestamp_ms = base_r_s_timestamp * 1e3,
    )$cast(pl$Int64)
  )

  expect_snapshot(
    as_polars_series(as.Date("2022-1-1"))$dt$timestamp("bob"),
    error = TRUE
  )

  expect_snapshot(
    as_polars_series(as.Date("2022-1-1"))$dt$timestamp(42),
    error = TRUE
  )
})


test_that("dt$with_time_unit cast_time_unit", {
  suppressWarnings(df_time <- pl$select(
    date = pl$datetime_range(
      start = as.POSIXct("2001-1-1"), end = as.POSIXct("2001-1-3"), interval = "1d", time_unit = "us"
    )
  )$select(
    pl$col("date"),
    pl$col("date")$dt$cast_time_unit("ns")$alias("cast_time_unit_ns"),
    pl$col("date")$dt$cast_time_unit(time_unit = "us")$alias("cast_time_unit_us"),
    pl$col("date")$dt$cast_time_unit(time_unit = "ms")$alias("cast_time_unit_ms"),
    pl$col("date")$dt$with_time_unit()$alias("with_time_unit_ns"),
    pl$col("date")$dt$with_time_unit(time_unit = "us")$alias("with_time_unit_us"),
    pl$col("date")$dt$with_time_unit(time_unit = "ms")$alias("with_time_unit_ms")
  ))

  df_time_num <- df_time$cast(pl$Float64)

  # cast time unit changes the value
  expect_equal(
    df_time_num$select("cast_time_unit_ns"),
    df_time_num$select(cast_time_unit_ns = pl$col("cast_time_unit_us") * 1E3)
  )
  expect_equal(
    df_time_num$select("cast_time_unit_us"),
    df_time_num$select(cast_time_unit_us = pl$col("cast_time_unit_ms") * 1E3)
  )
  # with does not
  expect_equal(
    df_time_num$select("with_time_unit_ns"),
    df_time_num$select(with_time_unit_ns = "with_time_unit_us")
  )
  expect_equal(
    df_time_num$select("with_time_unit_us"),
    df_time_num$select(with_time_unit_us = "with_time_unit_ms")
  )

  # both with and cast change the value
  types <- df_time$schema
  expect_true(types$with_time_unit_ns$eq(pl$Datetime("ns")))
  expect_true(types$with_time_unit_us$eq(pl$Datetime("us")))
  expect_true(types$with_time_unit_ms$eq(pl$Datetime("ms")))

  expect_true(types$cast_time_unit_ns$eq(pl$Datetime("ns")))
  expect_true(types$cast_time_unit_us$eq(pl$Datetime("us")))
  expect_true(types$cast_time_unit_ms$eq(pl$Datetime("ms")))

  # cast wrong inputs
  expect_snapshot(
    as_polars_series(as.Date("2022-1-1"))$dt$cast_time_unit("bob"),
    error = TRUE
  )
  expect_snapshot(
    as_polars_series(as.Date("2022-1-1"))$dt$cast_time_unit(42),
    error = TRUE
  )
  # with wrong inputs
  expect_snapshot(
    as_polars_series(as.Date("2022-1-1"))$dt$with_time_unit("bob"),
    error = TRUE
  )
  expect_snapshot(
    as_polars_series(as.Date("2022-1-1"))$dt$with_time_unit(42),
    error = TRUE
  )
})

test_that("$convert_time_zone() works", {
  df_time <- pl$select(
    date = pl$datetime_range(
      start = as.Date("2001-3-1"),
      end = as.Date("2001-5-1"),
      interval = "1mo",
      time_zone = "UTC",
      time_unit = "ms"
    )
  )
  df_casts <- df_time$with_columns(
    pl$col("date")
    $dt$convert_time_zone("Europe/London")
    $alias("London")
  )

  orig_r <- as.POSIXct(
    c("2001-03-01 00:00:00", "2001-04-01 00:00:00", "2001-05-01 00:00:00"),
    tz = "UTC"
  )
  new_r <- orig_r
  attributes(new_r)$tzone <- "Europe/London"

  expect_equal(
    df_casts,
    pl$DataFrame(date = orig_r, London = new_r)
  )
})

test_that("dt$replace_time_zone() works", {
  df <- pl$select(
    London = pl$datetime_range(
      start = as.POSIXct("2001-3-1"),
      end = as.POSIXct("2001-7-1"),
      interval = "1mo",
      time_zone = "Europe/London"
    )
  )

  df <- df$with_columns(
    pl$col("London")
    $dt$replace_time_zone("Europe/Amsterdam")
    $alias("Amsterdam")
  )

  r_vals <- as.list(df)

  expect_equal(
    r_vals |> lapply(attr, "tz"),
    list(London = "Europe/London", Amsterdam = "Europe/Amsterdam")
  )

  r_vals <- lapply(r_vals, as.numeric)
  expect_equal(r_vals[["London"]], r_vals[["Amsterdam"]] + 3600)
})

test_that("replace_time_zone for ambiguous time", {
  skip_if_not_installed("clock")

  x <- seq(
    clock::naive_time_parse("2018-10-28T01:30:00"),
    clock::naive_time_parse("2018-10-28T02:30:00"),
    by = clock::duration_minutes(30)
  )

  pl_out <- pl$select(
    earliest = pl$lit(x)$dt$replace_time_zone("Europe/Brussels", ambiguous = "earliest"),
    latest = pl$lit(x)$dt$replace_time_zone("Europe/Brussels", ambiguous = "latest"),
    null = pl$lit(x)$dt$replace_time_zone("Europe/Brussels", ambiguous = "null")
  )

  clock_out <- pl$select(
    earliest = clock::as_zoned_time(x, "Europe/Brussels", ambiguous = "earliest"),
    latest = clock::as_zoned_time(x, "Europe/Brussels", ambiguous = "latest"),
    null = clock::as_zoned_time(x, "Europe/Brussels", ambiguous = "NA")
  )

  expect_equal(pl_out, clock_out)
})


test_that("dt$days, dt$hours, dt$minutes, dt$seconds, + ms, us, ns", {
  # diff with settable units
  diffy <- \(x, units) as.numeric(diff(x), units = units)
  # days
  vals <- c(as.Date("2020-3-1"), as.Date("2020-4-1"), as.Date("2020-5-1"))
  df <- pl$DataFrame(date = vals)$select(
    diff = pl$col("date")$diff()$dt$total_days()
  )
  expect_equal(
    df,
    pl$DataFrame(diff = c(NA, diffy(vals, "days")))$cast(pl$Int64)
  )

  # hours
  vals <- c(as.Date("2020-1-1"), as.Date("2020-1-2"), as.Date("2020-1-3"), as.Date("2020-1-4"))
  df <- pl$DataFrame(date = vals)$select(
    pl$col("date")$diff()$dt$total_hours()$alias("diff")
  )
  expect_equal(
    df,
    pl$DataFrame(diff = c(NA, diffy(vals, "hours")))$cast(pl$Int64)
  )

  # minutes
  vals <- c(as.Date("2020-1-1"), as.Date("2020-1-2"), as.Date("2020-1-3"), as.Date("2020-1-4"))
  df <- pl$select(date = pl$date_range(
    start = as.Date("2020-1-1"), end = as.Date("2020-1-4"), interval = "1d"
  ))$select(
    pl$col("date")$diff()$dt$total_minutes()$alias("diff")
  )
  expect_equal(
    df,
    pl$DataFrame(diff = c(NA, diffy(vals, "mins")))$cast(pl$Int64)
  )

  # seconds
  vals <- as.POSIXct(
    c(
      "2020-01-01 00:00:00", "2020-01-01 00:01:00", "2020-01-01 00:02:00",
      "2020-01-01 00:03:00", "2020-01-01 00:04:00"
    )
  )
  df <- pl$DataFrame(date = vals)$select(
    pl$col("date")$diff()$dt$total_seconds()$alias("diff")
  )
  expect_equal(
    df,
    pl$DataFrame(diff = c(NA, diffy(vals, "secs")))$cast(pl$Int64)
  )


  # milliseconds
  df <- pl$DataFrame(date = vals)$select(
    pl$col("date")$diff()$dt$total_milliseconds()$alias("diff")
  )
  expect_equal(
    df,
    pl$DataFrame(diff = c(NA, diffy(vals, "secs")) * 1000)$cast(pl$Int64)
  )

  # microseconds
  df <- pl$DataFrame(date = vals)$select(
    pl$col("date")$diff()$dt$total_microseconds()$alias("diff")
  )
  expect_equal(
    df,
    pl$DataFrame(diff = c(NA, diffy(vals, "secs")) * 1E6)$cast(pl$Int64)
  )

  # nanoseconds
  df <- pl$DataFrame(date = vals)$select(
    pl$col("date")$diff()$dt$total_nanoseconds()$alias("diff")
  )
  expect_equal(
    df,
    pl$DataFrame(diff = c(NA, diffy(vals, "secs")) * 1E9)$cast(pl$Int64)
  )
})

test_that("$dt$time()", {
  df <- pl$select(
    dates = pl$datetime_range(
      as.Date("2000-1-1"),
      as.Date("2000-1-2"),
      "6h"
    )
  )
  expect_equal(
    df$select(times = pl$col("dates")$dt$time()$cast(pl$Float64)),
    pl$DataFrame(times = c(0.00e+00, 2.16e+13, 4.32e+13, 6.48e+13, 0.00e+00))
  )
})

test_that("$dt$is_leap_year()", {
  df <- pl$select(
    date = as.Date(c("2000-01-01", "2001-01-01", "2002-01-01")),
    datetime = pl$datetime_range(as.Date("2000-01-01"), as.Date("2002-01-01"), "1y")
  )

  expect_equal(
    df$select(leap_year = pl$col("date")$dt$is_leap_year()),
    pl$DataFrame(leap_year = c(TRUE, FALSE, FALSE))
  )
  expect_equal(
    df$select(leap_year = pl$col("datetime")$dt$is_leap_year()),
    pl$DataFrame(leap_year = c(TRUE, FALSE, FALSE))
  )
})

test_that("dt$century", {
  df <- pl$DataFrame(
    x = as.Date(
      c("999-12-31", "1897-05-07", "2000-01-01", "2001-07-05", "3002-10-20")
    )
  )
  expect_equal(
    df$select(pl$col("x")$dt$century()),
    pl$DataFrame(x = c(10, 19, 20, 21, 31))$cast(pl$Int32)
  )
})

test_that("dt$date", {
  df <- pl$DataFrame(
    x = as.POSIXct(c("1978-1-1 1:1:1", "1897-5-7 00:00:00"), tz = "UTC")
  )
  expect_equal(
    df$select(pl$col("x")$dt$date()),
    pl$DataFrame(x = as.Date(c("1978-1-1", "1897-5-7")))
  )
})

test_that("dt$month_start", {
  df <- pl$DataFrame(x = as.Date(c("2000-01-23", "2001-01-12", "2002-01-01")))
  expect_equal(
    df$select(pl$col("x")$dt$month_start()),
    pl$DataFrame(x = as.Date(c("2000-01-01", "2001-01-01", "2002-01-01")))
  )
})

test_that("dt$month_end", {
  df <- pl$DataFrame(x = as.Date(c("2000-01-23", "2001-01-12", "2002-01-01")))
  expect_equal(
    df$select(pl$col("x")$dt$month_end()),
    pl$DataFrame(x = as.Date(c("2000-01-31", "2001-01-31", "2002-01-31")))
  )
})

test_that("dt$base_utc_offset", {
  df <- pl$DataFrame(
    x = as.POSIXct(c("2011-12-29", "2012-01-01"), tz = "Pacific/Apia")
  )
  expect_equal(
    df$select(pl$col("x")$dt$base_utc_offset()),
    pl$DataFrame(x = as.difftime(c(-11, 13), units = "hours"))
  )
})

test_that("dt$dst_offset", {
  df <- pl$DataFrame(
    x = as.POSIXct(c("2020-10-25", "2020-10-26"), tz = "Europe/London")
  )
  expect_equal(
    df$select(pl$col("x")$dt$dst_offset()),
    pl$DataFrame(x = as.difftime(c(1, 0), units = "hours"))
  )
})

test_that("dt$add_business_days", {
  df <- pl$DataFrame(x = as.Date(c("2020-1-1", "2020-1-2")))

  expect_equal(
    df$select(pl$col("x")$dt$add_business_days(5)),
    pl$DataFrame(x = as.Date(c("2020-1-8", "2020-1-9")))
  )
  expect_equal(
    df$select(pl$col("x")$dt$add_business_days(pl$lit(5L))),
    pl$DataFrame(x = as.Date(c("2020-1-8", "2020-1-9")))
  )
  expect_equal(
    df$select(
      pl$col("x")$dt$add_business_days(5, week_mask = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE))
    ),
    pl$DataFrame(x = as.Date(c("2020-1-7", "2020-1-8")))
  )
  expect_equal(
    df$select(pl$col("x")$dt$add_business_days(5, holidays = as.Date(c("2020-1-3", "2020-1-6")))),
    pl$DataFrame(x = as.Date(c("2020-1-10", "2020-1-13")))
  )
  # `as.Date(-0.001)` shows `1969-12-31`. Sub-day values should be floored
  expect_equal(
    pl$select(
      x = pl$lit(as.Date(-7:-8))$dt$add_business_days(4, holidays = as.Date(-0.001))
    ),
    pl$DataFrame(x = as.Date(c("1970-01-01", "1969-12-30")))
  )
  expect_equal(
    pl$select(
      x = pl$lit(as.Date(c("2020-1-5", "2020-1-6")))$dt$add_business_days(0, roll = "forward")
    ),
    pl$DataFrame(x = as.Date(c("2020-1-6", "2020-1-6")))
  )

  # Basic errors
  expect_snapshot(
    df$select(pl$col("x")$dt$add_business_days(5.2)),
    error = TRUE
  )
  expect_snapshot(
    df$select(pl$col("x")$dt$add_business_days(pl$lit(5))),
    error = TRUE
  )
  expect_snapshot(
    df$select(pl$col("x")$dt$add_business_days(0, week_mask = rep(TRUE, 6))),
    error = TRUE
  )
  expect_snapshot(
    df$select(pl$col("x")$dt$add_business_days(0, week_mask = c(rep(TRUE, 6), NA))),
    error = TRUE
  )
  expect_snapshot(
    df$select(pl$col("x")$dt$add_business_days(0, week_mask = 1)),
    error = TRUE
  )
  expect_snapshot(
    df$select(pl$col("x")$dt$add_business_days(0, roll = "foo")),
    error = TRUE
  )
})
