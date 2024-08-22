#' Truncate datetime
#' @description  Divide the date/datetime range into buckets.
#' Each date/datetime is mapped to the start of its bucket.
#'
#' @param every Either an Expr or a string indicating a column name or a
#' duration (see Details).
#'
#' @details The ``every`` and ``offset`` argument are created with the
#' the following string language:
#' - 1ns # 1 nanosecond
#' - 1us # 1 microsecond
#' - 1ms # 1 millisecond
#' - 1s  # 1 second
#' - 1m  # 1 minute
#' - 1h  # 1 hour
#' - 1d  # 1 day
#' - 1w  # 1 calendar week
#' - 1mo # 1 calendar month
#' - 1y  # 1 calendar year
#' These strings can be combined:
#'   - 3d12h4m25s # 3 days, 12 hours, 4 minutes, and 25 seconds
#' @return   Date/Datetime expr
#' @examples
#' t1 = as.POSIXct("3040-01-01", tz = "GMT")
#' t2 = t1 + as.difftime(25, units = "secs")
#' s = pl$datetime_range(t1, t2, interval = "2s", time_unit = "ms")
#'
#' df = pl$DataFrame(datetime = s)$with_columns(
#'   pl$col("datetime")$dt$truncate("4s")$alias("truncated_4s")
#' )
#' df
ExprDT_truncate = function(every) {
  every = parse_as_polars_duration_string(every, default = "0ns")
  .pr$Expr$dt_truncate(self, every) |>
    unwrap("in $dt$truncate()")
}

#' Round datetime
#' @description  Divide the date/datetime range into buckets.
#' Each date/datetime in the first half of the interval
#' is mapped to the start of its bucket.
#' Each date/datetime in the second half of the interval
#' is mapped to the end of its bucket.
#'
#' @inherit ExprDT_truncate params details return
#'
#' @examples
#' t1 = as.POSIXct("3040-01-01", tz = "GMT")
#' t2 = t1 + as.difftime(25, units = "secs")
#' s = pl$datetime_range(t1, t2, interval = "2s", time_unit = "ms")
#'
#' df = pl$DataFrame(datetime = s)$with_columns(
#'   pl$col("datetime")$dt$round("4s")$alias("rounded_4s")
#' )
#' df
ExprDT_round = function(every) {
  every = parse_as_polars_duration_string(every, default = "0ns")
  .pr$Expr$dt_round(self, every) |>
    unwrap("in $dt$round()")
}

#' Combine Date and Time
#'
#' If the underlying expression is a Datetime then its time component is
#' replaced, and if it is a Date then a new Datetime is created by combining
#' the two values.
#'
#' @param time The number of epoch since or before (if negative) the Date. Can be
#' an Expr or a PTime.
#' @inheritParams DataType_Datetime
#'
#' @inherit ExprDT_truncate return
#' @examples
#' df = pl$DataFrame(
#'   dtm = c(
#'     ISOdatetime(2022, 12, 31, 10, 30, 45),
#'     ISOdatetime(2023, 7, 5, 23, 59, 59)
#'   ),
#'   dt = c(ISOdate(2022, 10, 10), ISOdate(2022, 7, 5)),
#'   tm = c(pl$time(1, 2, 3, 456000), pl$time(7, 8, 9, 101000))
#' )$explode("tm")
#'
#' df
#'
#' df$select(
#'   d1 = pl$col("dtm")$dt$combine(pl$col("tm")),
#'   s2 = pl$col("dt")$dt$combine(pl$col("tm")),
#'   d3 = pl$col("dt")$dt$combine(pl$time(4, 5, 6))
#' )
ExprDT_combine = function(time, time_unit = "us") {
  # PTime implicitly gets converted to "ns"
  if (inherits(time, "PTime")) time_unit = "ns"
  .pr$Expr$dt_combine(self, time, time_unit) |>
    unwrap("in $dt$combine():")
}



#' strftime
#' @description
#' Format Date/Datetime with a formatting rule.
#' See `chrono strftime/strptime
#' <https://docs.rs/chrono/latest/chrono/format/strftime/index.html>`_.
#'
#'
#' @param format string format very much like in R passed to chrono
#'
#' @return   Date/Datetime expr
#' @keywords ExprDT
#' @aliases (Expr)$dt$strftime
#' @examples
#' pl$lit(as.POSIXct("2021-01-02 12:13:14", tz = "GMT"))$dt$strftime("this is the year: %Y")$to_r()
ExprDT_strftime = function(format) {
  .pr$Expr$dt_strftime(self, format)
}


#' Year
#' @description
#' Extract year from underlying Date representation.
#' Applies to Date and Datetime columns.
#' Returns the year number in the calendar date.
#'
#'
#' @return Expr of Year as Int32
#' @keywords ExprDT
#' @aliases (Expr)$dt$year
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(
#'     as.Date("2020-12-25"),
#'     as.Date("2021-1-05"),
#'     interval = "1d",
#'     time_zone = "GMT"
#'   )
#' )
#' df$with_columns(
#'   pl$col("date")$dt$year()$alias("year"),
#'   pl$col("date")$dt$iso_year()$alias("iso_year")
#' )
ExprDT_year = function() {
  .pr$Expr$dt_year(self)
}

#' Iso-Year
#' @description
#' Extract ISO year from underlying Date representation.
#' Applies to Date and Datetime columns.
#' Returns the year number in the ISO standard.
#' This may not correspond with the calendar year.
#'
#'
#'
#' @return Expr of iso_year as Int32
#' @keywords ExprDT
#' @aliases (Expr)$dt$iso_year
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(
#'     as.Date("2020-12-25"),
#'     as.Date("2021-1-05"),
#'     interval = "1d",
#'     time_zone = "GMT"
#'   )
#' )
#' df$with_columns(
#'   pl$col("date")$dt$year()$alias("year"),
#'   pl$col("date")$dt$iso_year()$alias("iso_year")
#' )
ExprDT_iso_year = function() {
  .pr$Expr$dt_iso_year(self)
}


#' Quarter
#' @description
#' Extract quarter from underlying Date representation.
#' Applies to Date and Datetime columns.
#' Returns the quarter ranging from 1 to 4.
#'
#' @return Expr of quarter as UInt32
#' @keywords ExprDT
#' @aliases (Expr)$dt$quarter
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(
#'     as.Date("2020-12-25"),
#'     as.Date("2021-1-05"),
#'     interval = "1d",
#'     time_zone = "GMT"
#'   )
#' )
#' df$with_columns(
#'   pl$col("date")$dt$quarter()$alias("quarter")
#' )
ExprDT_quarter = function() {
  .pr$Expr$dt_quarter(self)
}

#' Month
#' @description
#' Extract month from underlying Date representation.
#' Applies to Date and Datetime columns.
#' Returns the month number starting from 1.
#' The return value ranges from 1 to 12.
#'
#' @return Expr of month as UInt32
#' @keywords ExprDT
#' @aliases (Expr)$dtmonth
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(
#'     as.Date("2020-12-25"),
#'     as.Date("2021-1-05"),
#'     interval = "1d",
#'     time_zone = "GMT"
#'   )
#' )
#' df$with_columns(
#'   pl$col("date")$dt$month()$alias("month")
#' )
ExprDT_month = function() {
  .pr$Expr$dt_month(self)
}


#' Week
#' @description
#' Extract the week from the underlying Date representation.
#' Applies to Date and Datetime columns.
#' Returns the ISO week number starting from 1.
#' The return value ranges from 1 to 53. (The last week of year differs by years.)
#'
#' @return Expr of week as UInt32
#' @keywords ExprDT
#' @aliases (Expr)$dt$week
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(
#'     as.Date("2020-12-25"),
#'     as.Date("2021-1-05"),
#'     interval = "1d",
#'     time_zone = "GMT"
#'   )
#' )
#' df$with_columns(
#'   pl$col("date")$dt$week()$alias("week")
#' )
ExprDT_week = function() {
  .pr$Expr$dt_week(self)
}

#' Weekday
#' @description
#' Extract the week day from the underlying Date representation.
#' Applies to Date and Datetime columns.
#' Returns the ISO weekday number where monday = 1 and sunday = 7
#'
#' @return Expr of weekday as UInt32
#' @keywords ExprDT
#' @aliases (Expr)$dt$weekday
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(
#'     as.Date("2020-12-25"),
#'     as.Date("2021-1-05"),
#'     interval = "1d",
#'     time_zone = "GMT"
#'   )
#' )
#' df$with_columns(
#'   pl$col("date")$dt$weekday()$alias("weekday")
#' )
ExprDT_weekday = function() {
  .pr$Expr$dt_weekday(self)
}


#' Day
#' @description
#' Extract day from underlying Date representation.
#' Applies to Date and Datetime columns.
#' Returns the day of month starting from 1.
#' The return value ranges from 1 to 31. (The last day of month differs by months.)
#'
#' @return Expr of day as UInt32
#' @keywords ExprDT
#' @aliases (Expr)$dt$day
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(
#'     as.Date("2020-12-25"),
#'     as.Date("2021-1-05"),
#'     interval = "1d",
#'     time_zone = "GMT"
#'   )
#' )
#' df$with_columns(
#'   pl$col("date")$dt$day()$alias("day")
#' )
ExprDT_day = function() {
  .pr$Expr$dt_day(self)
}

#' Ordinal Day
#' @description
#' Extract ordinal day from underlying Date representation.
#' Applies to Date and Datetime columns.
#' Returns the day of year starting from 1.
#' The return value ranges from 1 to 366. (The last day of year differs by years.)
#'
#' @return Expr of ordinal_day as UInt32
#' @keywords ExprDT
#' @aliases (Expr)$dt$ordinal_day
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(
#'     as.Date("2020-12-25"),
#'     as.Date("2021-1-05"),
#'     interval = "1d",
#'     time_zone = "GMT"
#'   )
#' )
#' df$with_columns(
#'   pl$col("date")$dt$ordinal_day()$alias("ordinal_day")
#' )
ExprDT_ordinal_day = function() {
  .pr$Expr$dt_ordinal_day(self)
}


#' Hour
#' @description
#' Extract hour from underlying Datetime representation.
#' Applies to Datetime columns.
#' Returns the hour number from 0 to 23.
#'
#' @return Expr of hour as UInt32
#' @keywords ExprDT
#' @aliases (Expr)$dt$hour
#' @examples
#' df = pl$DataFrame(
#'   date = pl$datetime_range(
#'     as.Date("2020-12-25"),
#'     as.Date("2021-1-05"),
#'     interval = "1d2h",
#'     time_zone = "GMT"
#'   )
#' )
#' df$with_columns(
#'   pl$col("date")$dt$hour()$alias("hour")
#' )
ExprDT_hour = function() {
  .pr$Expr$dt_hour(self)
}

#' Minute
#' @description
#' Extract minutes from underlying Datetime representation.
#' Applies to Datetime columns.
#' Returns the minute number from 0 to 59.
#'
#' @return Expr of minute as UInt32
#' @keywords ExprDT
#' @aliases (Expr)$dt$minute
#' @examples
#' df = pl$DataFrame(
#'   date = pl$datetime_range(
#'     as.Date("2020-12-25"),
#'     as.Date("2021-1-05"),
#'     interval = "1d5s",
#'     time_zone = "GMT"
#'   )
#' )
#' df$with_columns(
#'   pl$col("date")$dt$minute()$alias("minute")
#' )
ExprDT_minute = function() {
  .pr$Expr$dt_minute(self)
}

#' Extract seconds from underlying Datetime representation
#'
#' Applies to Datetime columns.
#' Returns the integer second number from 0 to 59, or a floating
#' point number from 0 < 60 if `fractional=TRUE` that includes
#' any milli/micro/nanosecond component.
#' @param fractional A logical.
#' Whether to include the fractional component of the second.
#' @return [Expr][Expr_class] of data type Int8 or Float64
#' @examples
#' df = pl$DataFrame(
#'   datetime = as.POSIXct(
#'     c(
#'       "1978-01-01 01:01:01",
#'       "2024-10-13 05:30:14.500",
#'       "2065-01-01 10:20:30.06"
#'     ),
#'     "UTC"
#'   )
#' )
#'
#' df$with_columns(
#'   second = pl$col("datetime")$dt$second(),
#'   second_fractional = pl$col("datetime")$dt$second(fractional = TRUE)
#' )
ExprDT_second = function(fractional = FALSE) {
  sec = .pr$Expr$dt_second(self)
  if (fractional) {
    sec + .pr$Expr$dt_nanosecond(self) / pl$lit(1E9)
  } else {
    sec
  }
}


#' Extract milliseconds from underlying Datetime representation
#'
#' Applies to Datetime columns.
#' @return [Expr][Expr_class] of data type Int32
#' @examples
#' df = pl$DataFrame(
#'   datetime = as.POSIXct(
#'     c(
#'       "1978-01-01 01:01:01",
#'       "2024-10-13 05:30:14.500",
#'       "2065-01-01 10:20:30.06"
#'     ),
#'     "UTC"
#'   )
#' )
#'
#' df$with_columns(
#'   millisecond = pl$col("datetime")$dt$millisecond()
#' )
ExprDT_millisecond = function() {
  .pr$Expr$dt_millisecond(self)
}


#' Extract microseconds from underlying Datetime representation.
#' @inherit ExprDT_millisecond description return
#' @examples
#' df = pl$DataFrame(
#'   datetime = as.POSIXct(
#'     c(
#'       "1978-01-01 01:01:01",
#'       "2024-10-13 05:30:14.500",
#'       "2065-01-01 10:20:30.06"
#'     ),
#'     "UTC"
#'   )
#' )
#'
#' df$with_columns(
#'   microsecond = pl$col("datetime")$dt$microsecond()
#' )
ExprDT_microsecond = function() {
  .pr$Expr$dt_microsecond(self)
}


#' Extract nanoseconds from underlying Datetime representation
#' @inherit ExprDT_millisecond description return
#' @examples
#' df = pl$DataFrame(
#'   datetime = as.POSIXct(
#'     c(
#'       "1978-01-01 01:01:01",
#'       "2024-10-13 05:30:14.500",
#'       "2065-01-01 10:20:30.06"
#'     ),
#'     "UTC"
#'   )
#' )
#'
#' df$with_columns(
#'   nanosecond = pl$col("datetime")$dt$nanosecond()
#' )
ExprDT_nanosecond = function() {
  .pr$Expr$dt_nanosecond(self)
}


#' Epoch
#'
#' Get the time passed since the Unix EPOCH in the give time unit.
#'
#' @param time_unit Time unit, one of `"ns"`, `"us"`, `"ms"`, `"s"` or  `"d"`.
#'
#' @return Expr with datatype Int64
#' @examples
#' df = pl$DataFrame(date = pl$date_range(as.Date("2001-1-1"), as.Date("2001-1-3")))
#'
#' df$with_columns(
#'   epoch_ns = pl$col("date")$dt$epoch(),
#'   epoch_s = pl$col("date")$dt$epoch(time_unit = "s")
#' )
ExprDT_epoch = function(time_unit = "us") {
  time_unit = match.arg(time_unit, choices = c("us", "ns", "ms", "s", "d"))
  uw = \(res) unwrap(res, "in $dt$epoch:")

  switch(time_unit,
    "ms" = ,
    "us" = ,
    "ns" = .pr$Expr$dt_timestamp(self, time_unit) |> uw(),
    "s" = .pr$Expr$dt_epoch_seconds(self),
    "d" = self$cast(pl$Date)$cast(pl$Int32)
  )
}


#' timestamp
#' @description Return a timestamp in the given time unit.
#'
#' @param tu string option either 'ns', 'us', or 'ms'
#' @return Expr of i64
#' @keywords ExprDT
#' @aliases (Expr)$dt$timestamp
#' @examples
#' df = pl$DataFrame(
#'   date = pl$datetime_range(
#'     start = as.Date("2001-1-1"),
#'     end = as.Date("2001-1-3"),
#'     interval = "1d1s"
#'   )
#' )
#' df$select(
#'   pl$col("date"),
#'   pl$col("date")$dt$timestamp()$alias("timestamp_ns"),
#'   pl$col("date")$dt$timestamp(tu = "ms")$alias("timestamp_ms")
#' )
ExprDT_timestamp = function(tu = c("ns", "us", "ms")) {
  .pr$Expr$dt_timestamp(self, tu[1]) |>
    map_err(\(err) paste("in $dt$timestamp:", err)) |>
    unwrap()
}


#' with_time_unit
#' @description  Set time unit of a Series of dtype Datetime or Duration.
#' This does not modify underlying data, and should be used to fix an incorrect time unit.
#' The corresponding global timepoint will change.
#'
#' @param tu string option either 'ns', 'us', or 'ms'
#' @return Expr of i64
#' @keywords ExprDT
#' @aliases (Expr)$dt$with_time_unit
#' @examples
#' df = pl$DataFrame(
#'   date = pl$datetime_range(
#'     start = as.Date("2001-1-1"),
#'     end = as.Date("2001-1-3"),
#'     interval = "1d1s"
#'   )
#' )
#' df$select(
#'   pl$col("date"),
#'   pl$col("date")$dt$with_time_unit()$alias("with_time_unit_ns"),
#'   pl$col("date")$dt$with_time_unit(tu = "ms")$alias("with_time_unit_ms")
#' )
ExprDT_with_time_unit = function(tu = c("ns", "us", "ms")) {
  .pr$Expr$dt_with_time_unit(self, tu[1]) |>
    map_err(\(err) paste("in $dt$with_time_unit:", err)) |>
    unwrap()
}


#' cast_time_unit
#' @description
#' Cast the underlying data to another time unit. This may lose precision.
#' The corresponding global timepoint will stay unchanged +/- precision.
#'
#'
#' @param tu string option either 'ns', 'us', or 'ms'
#' @return Expr of i64
#' @keywords ExprDT
#' @aliases (Expr)$dt$cast_time_unit
#' @examples
#' df = pl$DataFrame(
#'   date = pl$datetime_range(
#'     start = as.Date("2001-1-1"),
#'     end = as.Date("2001-1-3"),
#'     interval = "1d1s"
#'   )
#' )
#' df$select(
#'   pl$col("date"),
#'   pl$col("date")$dt$cast_time_unit()$alias("cast_time_unit_ns"),
#'   pl$col("date")$dt$cast_time_unit(tu = "ms")$alias("cast_time_unit_ms")
#' )
ExprDT_cast_time_unit = function(tu = c("ns", "us", "ms")) {
  .pr$Expr$dt_cast_time_unit(self, tu[1]) |>
    map_err(\(err) paste("in $dt$cast_time_unit:", err)) |>
    unwrap()
}

#' Convert to given time zone for an expression of type Datetime.
#'
#' If converting from a time-zone-naive datetime,
#' then conversion will happen as if converting from UTC,
#' regardless of your system’s time zone.
#' @param time_zone String time zone from [base::OlsonNames()]
#' @return Expr of i64
#' @examples
#' df = pl$DataFrame(
#'   date = pl$datetime_range(
#'     as.POSIXct("2020-03-01", tz = "UTC"),
#'     as.POSIXct("2020-05-01", tz = "UTC"),
#'     "1mo1s"
#'   )
#' )
#'
#' df$select(
#'   "date",
#'   London = pl$col("date")$dt$convert_time_zone("Europe/London")
#' )
ExprDT_convert_time_zone = function(time_zone) {
  check_tz_to_result(time_zone) |>
    and_then(\(valid_tz) .pr$Expr$dt_convert_time_zone(self, valid_tz)) |>
    map_err(\(err) paste("in $dt$convert_time_zone:", err)) |>
    unwrap("in $convert_time_zone():")
}

#' Replace time zone
#'
#' Cast time zone for a Series of type Datetime. This is different from
#' [`$convert_time_zone()`][ExprDT_convert_time_zone] as it will also modify the
#' underlying timestamp. Use to correct a wrong time zone annotation. This will
#' change the corresponding global timepoint.
#'
#' @param time_zone `NULL` or string time zone from [base::OlsonNames()]
#' @param ... Ignored.
#' @param ambiguous Determine how to deal with ambiguous datetimes:
#' * `"raise"` (default): throw an error
#' * `"earliest"`: use the earliest datetime
#' * `"latest"`: use the latest datetime
#' * `"null"`: return a null value
#' @param non_existent Determine how to deal with non-existent datetimes:
#' * `"raise"` (default): throw an error
#' * `"null"`: return a null value
#' @return Expr of i64
#' @keywords ExprDT
#' @aliases (Expr)$dt$replace_time_zone
#' @examples
#' df1 = pl$DataFrame(
#'   london_timezone = pl$datetime_range(
#'     as.POSIXct("2020-03-01", tz = "UTC"),
#'     as.POSIXct("2020-07-01", tz = "UTC"),
#'     "1mo1s"
#'   )$dt$convert_time_zone("Europe/London")
#' )
#'
#' df1$select(
#'   "london_timezone",
#'   London_to_Amsterdam = pl$col("london_timezone")$dt$replace_time_zone("Europe/Amsterdam")
#' )
#'
#' # You can use `ambiguous` to deal with ambiguous datetimes:
#' dates = c(
#'   "2018-10-28 01:30",
#'   "2018-10-28 02:00",
#'   "2018-10-28 02:30",
#'   "2018-10-28 02:00"
#' )
#' df2 = pl$DataFrame(
#'   ts = as_polars_series(dates)$str$strptime(pl$Datetime("us")),
#'   ambiguous = c("earliest", "earliest", "latest", "latest")
#' )
#'
#' df2$with_columns(
#'   ts_localized = pl$col("ts")$dt$replace_time_zone(
#'     "Europe/Brussels",
#'     ambiguous = pl$col("ambiguous")
#'   )
#' )
ExprDT_replace_time_zone = function(
    time_zone,
    ...,
    ambiguous = "raise",
    non_existent = "raise") {
  check_tz_to_result(time_zone) |>
    and_then(\(valid_tz) {
      .pr$Expr$dt_replace_time_zone(self, valid_tz, ambiguous, non_existent)
    }) |>
    unwrap("in $replace_time_zone():")
}

#' Days
#' @description Extract the days from a Duration type.
#'
#' @return Expr of i64
#' @examples
#' df = pl$DataFrame(
#'   date = pl$datetime_range(
#'     start = as.Date("2020-3-1"),
#'     end = as.Date("2020-5-1"),
#'     interval = "1mo1s"
#'   )
#' )
#' df$select(
#'   pl$col("date"),
#'   diff_days = pl$col("date")$diff()$dt$total_days()
#' )
ExprDT_total_days = function() {
  .pr$Expr$dt_total_days(self) |>
    unwrap("in $dt$total_days():")
}

#' Hours
#' @description Extract the hours from a Duration type.
#'
#' @return Expr of i64
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(
#'     start = as.Date("2020-1-1"),
#'     end = as.Date("2020-1-4"),
#'     interval = "1d"
#'   )
#' )
#' df$select(
#'   pl$col("date"),
#'   diff_hours = pl$col("date")$diff()$dt$total_hours()
#' )
ExprDT_total_hours = function() {
  .pr$Expr$dt_total_hours(self) |>
    unwrap("in $dt$total_hours():")
}

#' Minutes
#' @description Extract the minutes from a Duration type.
#'
#' @return Expr of i64
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(
#'     start = as.Date("2020-1-1"),
#'     end = as.Date("2020-1-4"),
#'     interval = "1d"
#'   )
#' )
#' df$select(
#'   pl$col("date"),
#'   diff_minutes = pl$col("date")$diff()$dt$total_minutes()
#' )
ExprDT_total_minutes = function() {
  .pr$Expr$dt_total_minutes(self) |>
    unwrap("in $dt$total_minutes():")
}

#' Seconds
#' @description Extract the seconds from a Duration type.
#'
#' @return Expr of i64
#' @examples
#' df = pl$DataFrame(date = pl$datetime_range(
#'   start = as.POSIXct("2020-1-1", tz = "GMT"),
#'   end = as.POSIXct("2020-1-1 00:04:00", tz = "GMT"),
#'   interval = "1m"
#' ))
#' df$select(
#'   pl$col("date"),
#'   diff_sec = pl$col("date")$diff()$dt$total_seconds()
#' )
ExprDT_total_seconds = function() {
  .pr$Expr$dt_total_seconds(self) |>
    unwrap("in $dt$total_seconds():")
}

#' milliseconds
#' @description Extract the milliseconds from a Duration type.
#'
#' @return Expr of i64
#' @examples
#' df = pl$DataFrame(date = pl$datetime_range(
#'   start = as.POSIXct("2020-1-1", tz = "GMT"),
#'   end = as.POSIXct("2020-1-1 00:00:01", tz = "GMT"),
#'   interval = "1ms"
#' ))
#' df$select(
#'   pl$col("date"),
#'   diff_millisec = pl$col("date")$diff()$dt$total_milliseconds()
#' )
ExprDT_total_milliseconds = function() {
  .pr$Expr$dt_total_milliseconds(self) |>
    unwrap("in $dt$total_milliseconds():")
}

#' microseconds
#' @description Extract the microseconds from a Duration type.
#'
#' @return Expr of i64
#' @examples
#' df = pl$DataFrame(date = pl$datetime_range(
#'   start = as.POSIXct("2020-1-1", tz = "GMT"),
#'   end = as.POSIXct("2020-1-1 00:00:01", tz = "GMT"),
#'   interval = "1ms"
#' ))
#' df$select(
#'   pl$col("date"),
#'   diff_microsec = pl$col("date")$diff()$dt$total_microseconds()
#' )
ExprDT_total_microseconds = function() {
  .pr$Expr$dt_total_microseconds(self) |>
    unwrap("in $dt$total_microseconds():")
}

#' nanoseconds
#' @description Extract the nanoseconds from a Duration type.
#'
#' @return Expr of i64
#' @examples
#' df = pl$DataFrame(date = pl$datetime_range(
#'   start = as.POSIXct("2020-1-1", tz = "GMT"),
#'   end = as.POSIXct("2020-1-1 00:00:01", tz = "GMT"),
#'   interval = "1ms"
#' ))
#' df$select(
#'   pl$col("date"),
#'   diff_nanosec = pl$col("date")$diff()$dt$total_nanoseconds()
#' )
ExprDT_total_nanoseconds = function() {
  .pr$Expr$dt_total_nanoseconds(self) |>
    unwrap("in $dt$total_nanoseconds():")
}

#' Offset By
#' @description  Offset this date by a relative time offset.
#' This differs from ``pl$col("foo_datetime_tu") + value_tu`` in that it can
#' take months and leap years into account. Note that only a single minus
#' sign is allowed in the ``by`` string, as the first character.
#'
#'
#' @param by optional string encoding duration see details.
#'
#'
#' @details
#' The ``by`` are created with the the following string language:
#' - 1ns # 1 nanosecond
#' - 1us # 1 microsecond
#' - 1ms # 1 millisecond
#' - 1s  # 1 second
#' - 1m  # 1 minute
#' - 1h  # 1 hour
#' - 1d  # 1 day
#' - 1w  # 1 calendar week
#' - 1mo # 1 calendar month
#' - 1y  # 1 calendar year
#' - 1i  # 1 index count
#'
#' These strings can be combined:
#'   - 3d12h4m25s # 3 days, 12 hours, 4 minutes, and 25 seconds
#'
#' @return   Date/Datetime expr
#' @keywords ExprDT
#' @aliases (Expr)$dt$offset_by
#' @examples
#' df = pl$DataFrame(
#'   dates = pl$date_range(
#'     as.Date("2000-1-1"),
#'     as.Date("2005-1-1"),
#'     "1y"
#'   )
#' )
#' df$select(
#'   pl$col("dates")$dt$offset_by("1y")$alias("date_plus_1y"),
#'   pl$col("dates")$dt$offset_by("-1y2mo")$alias("date_min")
#' )
#'
#' # the "by" argument also accepts expressions
#' df = pl$DataFrame(
#'   dates = pl$datetime_range(
#'     as.POSIXct("2022-01-01", tz = "GMT"),
#'     as.POSIXct("2022-01-02", tz = "GMT"),
#'     interval = "6h", time_unit = "ms", time_zone = "GMT"
#'   )$to_r(),
#'   offset = c("1d", "-2d", "1mo", NA, "1y")
#' )
#'
#' df
#'
#' df$with_columns(new_dates = pl$col("dates")$dt$offset_by(pl$col("offset")))
ExprDT_offset_by = function(by) {
  .pr$Expr$dt_offset_by(self, by) |>
    unwrap("in $offset_by():")
}


#' Extract time from a Datetime Series
#'
#' This only works on Datetime Series, it will error on Date Series.
#'
#' @return A Time Expr
#'
#'
#' @examples
#' df = pl$DataFrame(dates = pl$datetime_range(
#'   as.Date("2000-1-1"),
#'   as.Date("2000-1-2"),
#'   "1h"
#' ))
#'
#' df$with_columns(times = pl$col("dates")$dt$time())
ExprDT_time = function() {
  .pr$Expr$dt_time(self) |>
    unwrap("in $dt$time()")
}

#' Determine whether the year of the underlying date is a leap year
#'
#' @return An Expr of datatype Bool
#'
#' @examples
#' df = pl$DataFrame(date = as.Date(c("2000-01-01", "2001-01-01", "2002-01-01")))
#'
#' df$with_columns(
#'   leap_year = pl$col("date")$dt$is_leap_year()
#' )
ExprDT_is_leap_year = function() {
  .pr$Expr$dt_is_leap_year(self)
}
