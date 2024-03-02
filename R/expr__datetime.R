#' Truncate datetime
#' @description  Divide the date/datetime range into buckets.
#' Each date/datetime is mapped to the start of its bucket.
#'
#' @param every string encoding duration see details.
#' @param offset optional string encoding duration see details.
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
#' @keywords ExprDT
#' @aliases (Expr)$dt$truncate
#' @examples
#' t1 = as.POSIXct("3040-01-01", tz = "GMT")
#' t2 = t1 + as.difftime(25, units = "secs")
#' s = pl$date_range(t1, t2, interval = "2s", time_unit = "ms")
#'
#' # use a dt namespace function
#' df = pl$DataFrame(datetime = s)$with_columns(
#'   pl$col("datetime")$dt$truncate("4s")$alias("truncated_4s"),
#'   pl$col("datetime")$dt$truncate("4s", offset("3s"))$alias("truncated_4s_offset_2s")
#' )
#' df
ExprDT_truncate = function(every, offset = NULL) {
  .pr$Expr$dt_truncate(self, every, offset) |>
    unwrap("in dt$truncate()")
}

#' Round datetime
#' @description  Divide the date/datetime range into buckets.
#' Each date/datetime in the first half of the interval
#' is mapped to the start of its bucket.
#' Each date/datetime in the second half of the interval
#' is mapped to the end of its bucket.
#'
#'
#' @param every string encoding duration see details.
#' @param offset optional string encoding duration see details.
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
#'
#' This functionality is currently experimental and may
#' change without it being considered a breaking change.
#'
#' @return   Date/Datetime expr
#' @keywords ExprDT
#' @aliases (Expr)$dt$round
#' @examples
#' t1 = as.POSIXct("3040-01-01", tz = "GMT")
#' t2 = t1 + as.difftime(25, units = "secs")
#' s = pl$date_range(t1, t2, interval = "2s", time_unit = "ms")
#'
#' # use a dt namespace function
#' df = pl$DataFrame(datetime = s)$with_columns(
#'   pl$col("datetime")$dt$truncate("4s")$alias("truncated_4s"),
#'   pl$col("datetime")$dt$truncate("4s", offset("3s"))$alias("truncated_4s_offset_2s")
#' )
#' df
ExprDT_round = function(every, offset = NULL) {
  .pr$Expr$dt_round(self, every, offset) |>
    unwrap("in dt$round()")
}

# ExprDT_combine = function(self, tm: time | pli.RPolarsExpr, tu: TimeUnit = "us") -> pli.RPolarsExpr:


#' Combine Data and Time
#' @description  Create a naive Datetime from an existing Date/Datetime expression and a Time.
#' Each date/datetime in the first half of the interval
#' is mapped to the start of its bucket.
#' Each date/datetime in the second half of the interval
#' is mapped to the end of its bucket.
#'
#'
#' @param tm Expr or numeric or PTime, the number of epoch since or before(if negative) the Date
#' or tm is an Expr e.g. a column of DataType 'Time' or something into an Expr.
#' @param tu time unit of epochs, default is "us", if tm is a PTime, then tz passed via PTime.
#'
#'
#' @details The ``tu`` allows the following time time units
#' the following string language:
#' - 1ns # 1 nanosecond
#' - 1us # 1 microsecond
#' - 1ms # 1 millisecond
#'
#' @return   Date/Datetime expr
#' @keywords ExprDT
#' @aliases (Expr)$dt$combine
#' @examples
#' # Using pl$PTime
#' pl$lit(as.Date("2021-01-01"))$dt$combine(pl$PTime("02:34:12"))$to_series()
#' pl$lit(as.Date("2021-01-01"))$dt$combine(pl$PTime(3600 * 1.5, tu = "s"))$to_series()
#' pl$lit(as.Date("2021-01-01"))$dt$combine(pl$PTime(3600 * 1.5E6 + 123, tu = "us"))$to_series()
#'
#' # pass double and set tu manually
#' pl$lit(as.Date("2021-01-01"))$dt$combine(3600 * 1.5E6 + 123, tu = "us")$to_series()
#'
#' # if needed to convert back to R it is more intuitive to set a specific time zone
#' expr = pl$lit(as.Date("2021-01-01"))$dt$combine(3600 * 1.5E6 + 123, tu = "us")
#' expr$cast(pl$Datetime(tu = "us", tz = "GMT"))$to_r()
ExprDT_combine = function(tm, tu = "us") {
  if (inherits(tm, "PTime")) tu = "ns" # PTime implicitly gets converted to "ns"
  if (!is_string(tu)) stop("combine: input tu is not a string, [%s ]", str_string(tu))
  unwrap(.pr$Expr$dt_combine(self, wrap_e(tm), tu))
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
#'   date = pl$date_range(
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
#'   date = pl$date_range(
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

#' Second
#' @description
#' Extract seconds from underlying Datetime representation.
#' Applies to Datetime columns.
#' Returns the integer second number from 0 to 59, or a floating
#' point number from 0 < 60 if ``fractional=True`` that includes
#' any milli/micro/nanosecond component.
#'
#' @param fractional Whether to include the fractional component of the second.
#'
#' @return Expr of second as UInt32
#' @keywords ExprDT
#' @aliases (Expr)$dt$second
#' @examples
#' pl$DataFrame(date = pl$date_range(
#'   as.numeric(as.POSIXct("2001-1-1")) * 1E6 + 456789, # manually convert to us
#'   as.numeric(as.POSIXct("2001-1-1 00:00:6")) * 1E6,
#'   interval = "2s654321us",
#'   time_unit = "us", # instruct polars input is us, and store as us
#' ))$with_columns(
#'   pl$col("date")$dt$second()$alias("second"),
#'   pl$col("date")$dt$second(fractional = TRUE)$alias("second_frac")
#' )
ExprDT_second = function(fractional = FALSE) {
  sec = .pr$Expr$dt_second(self)
  if (fractional) {
    sec + .pr$Expr$dt_nanosecond(self) / pl$lit(1E9)
  } else {
    sec
  }
}

#' Millisecond
#' @description
#' Extract milliseconds from underlying Datetime representation.
#' Applies to Datetime columns.
#'
#' @return Expr of millisecond as Int64
#' @keywords ExprDT
#' @aliases (Expr)$dt$millisecond
#' @examples
#' pl$DataFrame(date = pl$date_range(
#'   as.numeric(as.POSIXct("2001-1-1")) * 1E6 + 456789, # manually convert to us
#'   as.numeric(as.POSIXct("2001-1-1 00:00:6")) * 1E6,
#'   interval = "2s654321us",
#'   time_unit = "us", # instruct polars input is us, and store as us
#' ))$with_columns(
#'   pl$col("date")$cast(pl$Int64)$alias("datetime int64"),
#'   pl$col("date")$dt$millisecond()$alias("millisecond")
#' )
ExprDT_millisecond = function() {
  .pr$Expr$dt_millisecond(self)
}

#' Microsecond
#' @description
#' Extract microseconds from underlying Datetime representation.
#' Applies to Datetime columns.
#'
#' @return Expr of microsecond as Int64
#' @keywords ExprDT
#' @aliases (Expr)$dt$microsecond
#' @examples
#' pl$DataFrame(
#'   date = pl$date_range(
#'     as.numeric(as.POSIXct("2001-1-1")) * 1E6 + 456789, # manually convert to us
#'     as.numeric(as.POSIXct("2001-1-1 00:00:6")) * 1E6,
#'     interval = "2s654321us",
#'     time_unit = "us" # instruct polars input is us, and store as us
#'   )
#' )$with_columns(
#'   pl$col("date")$cast(pl$Int64)$alias("datetime int64"),
#'   pl$col("date")$dt$microsecond()$alias("microsecond")
#' )
ExprDT_microsecond = function() {
  .pr$Expr$dt_microsecond(self)
}



#' Nanosecond
#' @description
#' Extract seconds from underlying Datetime representation.
#' Applies to Datetime columns.
#' Returns the integer second number from 0 to 59, or a floating
#' point number from 0 < 60 if ``fractional=True`` that includes
#' any milli/micro/nanosecond component.
#'
#' @return Expr of second as Int64
#' @keywords ExprDT
#' @aliases (Expr)$dt$nanosecond
#' @examples
#' pl$DataFrame(date = pl$date_range(
#'   as.numeric(as.POSIXct("2001-1-1")) * 1E9 + 123456789, # manually convert to us
#'   as.numeric(as.POSIXct("2001-1-1 00:00:6")) * 1E9,
#'   interval = "1s987654321ns",
#'   time_unit = "ns" # instruct polars input is us, and store as us
#' ))$with_columns(
#'   pl$col("date")$cast(pl$Int64)$alias("datetime int64"),
#'   pl$col("date")$dt$nanosecond()$alias("nanosecond")
#' )
ExprDT_nanosecond = function() {
  .pr$Expr$dt_nanosecond(self)
}



#' Epoch
#' @description
#' Get the time passed since the Unix EPOCH in the give time unit.
#'
#' @param tu string option either 'ns', 'us', 'ms', 's' or  'd'
#' @details ns and perhaps us will exceed integerish limit if returning to
#' R as flaot64/double.
#' @return Expr of epoch as UInt32
#' @keywords ExprDT
#' @aliases (Expr)$dt$epoch
#' @examples
#' pl$date_range(as.Date("2022-1-1"))$dt$epoch("ns")$to_series()
#' pl$date_range(as.Date("2022-1-1"))$dt$epoch("ms")$to_series()
#' pl$date_range(as.Date("2022-1-1"))$dt$epoch("s")$to_series()
#' pl$date_range(as.Date("2022-1-1"))$dt$epoch("d")$to_series()
ExprDT_epoch = function(tu = c("us", "ns", "ms", "s", "d")) {
  tu = tu[1]

  # experimental rust-like error handling on R side for the fun of it, sorry
  # jokes aside here the use case is to tie various rust functions together
  # and add context to the error messages
  expr_result = pcase(
    !is_string(tu), Err("tu must be a string"),
    tu %in% c("ms", "us", "ns"), .pr$Expr$timestamp(self, tu),
    tu == "s", Ok(.pr$Expr$dt_epoch_seconds(self)),
    tu == "d", Ok(self$cast(pl$Date)$cast(pl$Int32)),
    or_else = Err(
      paste("tu must be one of 'ns', 'us', 'ms', 's', 'd', got", str_string(tu))
    )
  ) |> map_err(\(err) paste("in dt$epoch:", err))

  unwrap(expr_result)
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
#'   date = pl$date_range(
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
  .pr$Expr$timestamp(self, tu[1]) |>
    map_err(\(err) paste("in dt$timestamp:", err)) |>
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
#'   date = pl$date_range(
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
    map_err(\(err) paste("in dt$with_time_unit:", err)) |>
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
#'   date = pl$date_range(
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
    map_err(\(err) paste("in dt$cast_time_unit:", err)) |>
    unwrap()
}

#' With Time Zone
#' @description Set time zone for a Series of type Datetime.
#' Use to change time zone annotation, but keep the corresponding global timepoint.
#'
#' @param tz String time zone from base::OlsonNames()
#' @return Expr of i64
#' @keywords ExprDT
#' @details corresponds to in R manually modifying the tzone attribute of POSIXt objects
#' @aliases (Expr)$dt$convert_time_zone
#' @examples
#' df = pl$DataFrame(
#'   london_timezone = pl$date_range(
#'     as.POSIXct("2020-03-01", tz = "UTC"),
#'     as.POSIXct("2020-07-01", tz = "UTC"),
#'     "1mo",
#'     time_zone = "UTC"
#'   )$dt$convert_time_zone("Europe/London")
#' )
#'
#' df$select(
#'   "london_timezone",
#'   London_to_Amsterdam = pl$col(
#'     "london_timezone"
#'   )$dt$replace_time_zone("Europe/Amsterdam")
#' )
#'
#' # You can use `ambiguous` to deal with ambiguous datetimes:
#' dates = c(
#'   "2018-10-28 01:30",
#'   "2018-10-28 02:00",
#'   "2018-10-28 02:30",
#'   "2018-10-28 02:00"
#' )
#'
#' df = pl$DataFrame(
#'   ts = pl$Series(dates)$str$strptime(pl$Datetime("us"), "%F %H:%M"),
#'   ambiguous = c("earliest", "earliest", "latest", "latest")
#' )
#'
#' df$with_columns(
#'   ts_localized = pl$col("ts")$dt$replace_time_zone(
#'     "Europe/Brussels",
#'     ambiguous = pl$col("ambiguous")
#'   )
#' )
#'
#' # Polars Datetime type without a time zone will be converted to R
#' # with respect to the session time zone. If ambiguous times are present
#' # an error will be raised. It is recommended to add a time zone before
#' # converting to R.
#' s_without_tz = pl$Series(dates)$str$strptime(pl$Datetime("us"), "%F %H:%M")
#' s_without_tz
#'
#' s_with_tz = s_without_tz$dt$replace_time_zone("UTC")
#' s_with_tz
#'
#' as.vector(s_with_tz)
ExprDT_convert_time_zone = function(tz) {
  check_tz_to_result(tz) |>
    map(\(valid_tz) .pr$Expr$dt_convert_time_zone(self, valid_tz)) |>
    map_err(\(err) paste("in dt$convert_time_zone:", err)) |>
    unwrap()
}

#' replace_time_zone
#' @description
#' Cast time zone for a Series of type Datetime.
#' Different from ``convert_time_zone``, this will also modify the underlying timestamp.
#' Use to correct a wrong time zone annotation. This will change the corresponding global timepoint.
#'
#'
#' @param tz NULL or string time zone from [base::OlsonNames()]
#' @param ambiguous Determine how to deal with ambiguous datetimes:
#' * `"raise"` (default): raise
#' * `"earliest"`: use the earliest datetime
#' * `"latest"`: use the latest datetime
#' @return Expr of i64
#' @keywords ExprDT
#' @aliases (Expr)$dt$replace_time_zone
#' @examples
#' df_1 = pl$DataFrame(x = as.POSIXct("2009-08-07 00:00:01", tz = "America/New_York"))
#'
#' df_1$with_columns(
#'   pl$col("x")$dt$replace_time_zone("UTC")$alias("utc"),
#'   pl$col("x")$dt$replace_time_zone("Europe/Amsterdam")$alias("cest")
#' )
#'
#' # You can use ambiguous to deal with ambiguous datetimes
#' df_2 = pl$DataFrame(
#'   x = seq(
#'     as.POSIXct("2018-10-28 01:30", tz = "UTC"),
#'     as.POSIXct("2018-10-28 02:30", tz = "UTC"),
#'     by = "30 min"
#'   )
#' )
#'
#' df_2$with_columns(
#'   pl$col("x")$dt$replace_time_zone("Europe/Brussels", "earliest")$alias("earliest"),
#'   pl$col("x")$dt$replace_time_zone("Europe/Brussels", "latest")$alias("latest")
#' )
ExprDT_replace_time_zone = function(tz, ambiguous = "raise") {
  check_tz_to_result(tz) |>
    and_then(\(valid_tz) {
      .pr$Expr$dt_replace_time_zone(self, valid_tz, ambiguous)
    }) |>
    unwrap("in $replace_time_zone():")
}

#' Days
#' @description Extract the days from a Duration type.
#'
#' @return Expr of i64
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(
#'     start = as.Date("2020-3-1"),
#'     end = as.Date("2020-5-1"),
#'     interval = "1mo"
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
#' df = pl$DataFrame(date = pl$date_range(
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
#' df = pl$DataFrame(date = pl$date_range(
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
#' df = pl$DataFrame(date = pl$date_range(
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
#' df = pl$DataFrame(date = pl$date_range(
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
#'   dates = pl$date_range(
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
#' df = pl$DataFrame(dates = pl$date_range(
#'   as.Date("2000-1-1"),
#'   as.Date("2000-1-2"),
#'   "1h"
#' ))
#'
#' df$with_columns(times = pl$col("dates")$dt$time())
ExprDT_time = function() {
  .pr$Expr$dt_time(self) |>
    unwrap("in dt$time()")
}
