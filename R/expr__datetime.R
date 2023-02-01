#' Truncate datetime
#' @description  Divide the date/datetime range into buckets.
#' Each date/datetime is mapped to the start of its bucket.
#' @name ExprDT_truncate
#' @param every string encoding duration see details.
#' @param ofset optional string encoding duration see details.
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
#' @format function
#' @aliases (Expr)$dt$truncate
#' @examples
#' t1 = as.POSIXct("3040-01-01",tz = "GMT")
#' t2 = t1 + as.difftime(25,units = "secs")
#' s = pl$date_range(t1, t2, interval = "2s", time_unit = "ms")
#'
#' #use a dt namespace function
#' df = pl$DataFrame(datetime = s)$with_columns(
#'   pl$col("datetime")$dt$truncate("4s")$alias("truncated_4s"),
#'   pl$col("datetime")$dt$truncate("4s",offset("3s"))$alias("truncated_4s_offset_2s")
#' )
#' df
ExprDT_truncate = function(
    every,# str
    offset = NULL#: str | timedelta | None = None,
) {
  .pr$Expr$dt_truncate(self, every, as_pl_duration(offset %||% "0ns"))
}

#' Round datetime
#' @description  Divide the date/datetime range into buckets.
#' Each date/datetime in the first half of the interval
#' is mapped to the start of its bucket.
#' Each date/datetime in the second half of the interval
#' is mapped to the end of its bucket.
#' @name ExprDT_round
#'
#' @param every string encoding duration see details.
#' @param ofset optional string encoding duration see details.
#'
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
#' @format function
#' @aliases (Expr)$dt$round
#' @examples
#' t1 = as.POSIXct("3040-01-01",tz = "GMT")
#' t2 = t1 + as.difftime(25,units = "secs")
#' s = pl$date_range(t1, t2, interval = "2s", time_unit = "ms")
#'
#' #use a dt namespace function
#' df = pl$DataFrame(datetime = s)$with_columns(
#'   pl$col("datetime")$dt$truncate("4s")$alias("truncated_4s"),
#'   pl$col("datetime")$dt$truncate("4s",offset("3s"))$alias("truncated_4s_offset_2s")
#' )
#' df
ExprDT_round = function(every, offset = NULL) {
  .pr$Expr$dt_round(self, every,  as_pl_duration(offset %||% "0ns"))
}

#ExprDT_combine = function(self, tm: time | pli.Expr, tu: TimeUnit = "us") -> pli.Expr:


#' Combine Data and Time
#' @description  Create a naive Datetime from an existing Date/Datetime expression and a Time.
#' Each date/datetime in the first half of the interval
#' is mapped to the start of its bucket.
#' Each date/datetime in the second half of the interval
#' is mapped to the end of its bucket.
#' @name ExprDT_combine
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
#' @format function
#' @aliases (Expr)$dt$combine
#' @examples
#' #Using pl$PTime
#' pl$lit(as.Date("2021-01-01"))$dt$combine(pl$PTime("02:34:12"))$lit_to_s()
#' pl$lit(as.Date("2021-01-01"))$dt$combine(pl$PTime(3600 * 1.5, tu="s"))$lit_to_s()
#' pl$lit(as.Date("2021-01-01"))$dt$combine(pl$PTime(3600 * 1.5E6 + 123, tu="us"))$lit_to_s()
#'
#' #pass double and set tu manually
#' pl$lit(as.Date("2021-01-01"))$dt$combine(3600 * 1.5E6 + 123, tu="us")$lit_to_s()
#'
#' #if needed to convert back to R it is more intuitive to set a specific time zone
#' expr = pl$lit(as.Date("2021-01-01"))$dt$combine(3600 * 1.5E6 + 123, tu="us")
#' expr$cast(pl$Datetime(tu = "us", tz = "GMT"))$to_r()
ExprDT_combine = function(tm, tu = "us") {
  if( inherits(tm, "PTime")) tu = "ns" #PTime implicitly gets converted to "ns"
  if(!is_string(tu)) stopf("combine: input tu is not a string, [%s ]",str_string(tu))
  unwrap(.pr$Expr$dt_combine(self, wrap_e(tm), tu))
}



#' strftime
#' @description
#' Format Date/Datetime with a formatting rule.
#' See `chrono strftime/strptime
#' <https://docs.rs/chrono/latest/chrono/format/strftime/index.html>`_.
#' @name ExprDT_strftime
#'
#' @param fmt string format very much like in R passed to chrono
#'
#' @return   Date/Datetime expr
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$strftime
#' @examples
#' pl$lit(as.POSIXct("2021-01-02 12:13:14",tz="GMT"))$dt$strftime("this is the year: %Y")$to_r()
ExprDT_strftime = function(fmt) {
  .pr$Expr$dt_strftime(self, fmt)
}


#' Year
#' @description
#' Extract year from underlying Date representation.
#' Applies to Date and Datetime columns.
#' Returns the year number in the calendar date.
#' @name ExprDT_year
#'
#' @return Expr of Year as Int32
#' @keywords ExprDT
#' @format function
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
#' @name ExprDT_iso_year
#'
#'
#' @return Expr of iso_year as Int32
#' @keywords ExprDT
#' @format function
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
#' @name ExprDT_quarter
#' @return Expr of quater as UInt32
#' @keywords ExprDT
#' @format function
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
#' @name ExprDT_month
#' @return Expr of month as UInt32
#' @keywords ExprDT
#' @format function
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
#' @name ExprDT_week
#' @return Expr of week as UInt32
#' @keywords ExprDT
#' @format function
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
#' @name ExprDT_weekday
#' @return Expr of weekday as UInt32
#' @keywords ExprDT
#' @format function
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
#' @name ExprDT_day
#' @return Expr of day as UInt32
#' @keywords ExprDT
#' @format function
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
#' @name ExprDT_ordinal_day
#' @return Expr of ordinal_day as UInt32
#' @keywords ExprDT
#' @format function
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
#' Extract hour from underlying DateTime representation.
#' Applies to Datetime columns.
#' Returns the hour number from 0 to 23.
#' @name ExprDT_hour
#' @return Expr of hour as UInt32
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$hour
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
#'   pl$col("date")$dt$hour()$alias("hour")
#' )
ExprDT_hour = function() {
  .pr$Expr$dt_hour(self)
}

#' Minute
#' @description
#' Extract minutes from underlying DateTime representation.
#' Applies to Datetime columns.
#' Returns the minute number from 0 to 59.
#' @name ExprDT_minute
#' @return Expr of minute as UInt32
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$minute
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
#'   pl$col("date")$dt$minute()$alias("minute")
#' )
ExprDT_minute = function() {
  .pr$Expr$dt_minute(self)
}

#' Second
#' @description
#' Extract seconds from underlying DateTime representation.
#' Applies to Datetime columns.
#' Returns the integer second number from 0 to 59, or a floating
#' point number from 0 < 60 if ``fractional=True`` that includes
#' any milli/micro/nanosecond component.
#' @name ExprDT_second
#' @return Expr of second as UInt32
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$second
#' @examples
#' pl$DataFrame(date = pl$date_range(
#'   as.numeric(as.POSIXct("2001-1-1"))*1E6+456789, #manually convert to us
#'   as.numeric(as.POSIXct("2001-1-1 00:00:6"))*1E6,
#'   interval = "2s654321us",
#'   time_unit = "us" #instruct polars input is us, and store as us
#' ))$with_columns(
#'   pl$col("date")$dt$second()$alias("second"),
#'   pl$col("date")$dt$second(fractional = TRUE)$alias("second_frac")
#' )
ExprDT_second = function(fractional = FALSE) {
  sec = .pr$Expr$dt_second(self)
  if( fractional) {
    sec + .pr$Expr$dt_nanosecond(self) / pl$lit(1E9)
  } else {
    sec
  }
}

#' Millisecond
#' @description
#' Extract milliseconds from underlying DateTime representation.
#' Applies to Datetime columns.
#' @name ExprDT_millisecond
#' @return Expr of millisecond as Int64
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$millisecond
#' @examples
#' pl$DataFrame(date = pl$date_range(
#'   as.numeric(as.POSIXct("2001-1-1"))*1E6+456789, #manually convert to us
#'   as.numeric(as.POSIXct("2001-1-1 00:00:6"))*1E6,
#'   interval = "2s654321us",
#'   time_unit = "us" #instruct polars input is us, and store as us
#' ))$with_columns(
#'   pl$col("date")$cast(pl$Int64)$alias("datetime int64"),
#'   pl$col("date")$dt$millisecond()$alias("millisecond")
#' )
ExprDT_millisecond = function() {
  .pr$Expr$dt_millisecond(self)
}

#' Microsecond
#' @description
#' Extract microseconds from underlying DateTime representation.
#' Applies to Datetime columns.
#' @name ExprDT_microsecond
#' @return Expr of microsecond as Int64
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$microsecond
#' @examples
#' pl$DataFrame(date = pl$date_range(
#'   as.numeric(as.POSIXct("2001-1-1"))*1E6+456789, #manually convert to us
#'   as.numeric(as.POSIXct("2001-1-1 00:00:6"))*1E6,
#'   interval = "2s654321us",
#'   time_unit = "us" #instruct polars input is us, and store as us
#' ))$with_columns(
#'   pl$col("date")$cast(pl$Int64)$alias("datetime int64"),
#'   pl$col("date")$dt$microsecond()$alias("microsecond")
#' )
ExprDT_microsecond = function() {
  .pr$Expr$dt_microsecond(self)
}



#' Nanosecond
#' @description
#' Extract seconds from underlying DateTime representation.
#' Applies to Datetime columns.
#' Returns the integer second number from 0 to 59, or a floating
#' point number from 0 < 60 if ``fractional=True`` that includes
#' any milli/micro/nanosecond component.
#' @name ExprDT_nanosecond
#' @return Expr of second as Int64
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$nanosecond
#' @examples
#' pl$DataFrame(date = pl$date_range(
#'   as.numeric(as.POSIXct("2001-1-1"))*1E9+123456789, #manually convert to us
#'   as.numeric(as.POSIXct("2001-1-1 00:00:6"))*1E9,
#'   interval = "1s987654321ns",
#'   time_unit = "ns" #instruct polars input is us, and store as us
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
#' @name ExprDT_epoch
#' @param tu string option either 'ns', 'us', 'ms', 's' or  'd'
#' @details ns and perhaps us will exceed integerish limit if returning to
#' R as flaot64/double.
#' @return Expr of epoch as UInt32
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$epoch
#' @examples
#' pl$date_range(as.Date("2022-1-1"),lazy = TRUE)$dt$epoch("ns")$lit_to_s()
#' pl$date_range(as.Date("2022-1-1"),lazy = TRUE)$dt$epoch("ms")$lit_to_s()
#' pl$date_range(as.Date("2022-1-1"),lazy = TRUE)$dt$epoch("s")$lit_to_s()
#' pl$date_range(as.Date("2022-1-1"),lazy = TRUE)$dt$epoch("d")$lit_to_s()
ExprDT_epoch = function(tu = c('us', 'ns', 'ms', 's', 'd')) {
  tu = tu[1]

  #experimental rust-like error handling on R side for the fun of it, sorry
  #jokes aside here the use case is to tie various rust functions together
  #and add context to the error messages
  expr_result = pcase(
    !is_string(tu), Err("tu must be a string"),
    tu %in% c("ms","us","ns"), .pr$Expr$timestamp(self, tu),
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
#' @name ExprDT_timestamp
#' @param tu string option either 'ns', 'us', or 'ms'
#' @return Expr of i64
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$timestamp
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(low = as.Date("2001-1-1"), high = as.Date("2001-1-3"), interval = "1d")
#' )
#' df$select(
#'   pl$col("date"),
#'   pl$col("date")$dt$timestamp()$alias("timestamp_ns"),
#'   pl$col("date")$dt$timestamp(tu="ms")$alias("timestamp_ms")
#' )
ExprDT_timestamp = function(tu = c('ns', 'us', 'ms')) {
  .pr$Expr$timestamp(self, tu[1]) |>
    map_err(\(err) paste("in dt$timestamp:", err)) |>
    unwrap()
}


#' with_time_unit
#' @description  Set time unit of a Series of dtype Datetime or Duration.
#' This does not modify underlying data, and should be used to fix an incorrect time unit.
#' The corresponding global timepoint will change.
#' @name ExprDT_with_time_unit
#' @param tu string option either 'ns', 'us', or 'ms'
#' @return Expr of i64
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$with_time_unit
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(low = as.Date("2001-1-1"), high = as.Date("2001-1-3"), interval = "1d")
#' )
#' df$select(
#'   pl$col("date"),
#'   pl$col("date")$dt$with_time_unit()$alias("with_time_unit_ns"),
#'   pl$col("date")$dt$with_time_unit(tu="ms")$alias("with_time_unit_ms")
#' )
ExprDT_with_time_unit = function(tu = c('ns', 'us', 'ms')) {
  .pr$Expr$dt_with_time_unit(self, tu[1]) |>
    map_err(\(err) paste("in dt$with_time_unit:", err)) |>
    unwrap()
}


#' cast_time_unit
#' @description
#' Cast the underlying data to another time unit. This may lose precision.
#' The corresponding global timepoint will stay unchanged +/- precision.
#'
#' @name ExprDT_cast_time_unit
#' @param tu string option either 'ns', 'us', or 'ms'
#' @return Expr of i64
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$cast_time_unit
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(low = as.Date("2001-1-1"), high = as.Date("2001-1-3"), interval = "1d")
#' )
#' df$select(
#'   pl$col("date"),
#'   pl$col("date")$dt$cast_time_unit()$alias("cast_time_unit_ns"),
#'   pl$col("date")$dt$cast_time_unit(tu="ms")$alias("cast_time_unit_ms")
#' )
ExprDT_cast_time_unit = function(tu = c('ns', 'us', 'ms')) {
  .pr$Expr$dt_cast_time_unit(self, tu[1]) |>
    map_err(\(err) paste("in dt$cast_time_unit:", err)) |>
    unwrap()
}

#' With Time Zone
#' @description Set time zone for a Series of type Datetime.
#' Use to change time zone annotation, but keep the corresponding global timepoint.
#' @name ExprDT_with_time_zone
#' @param tz Null or string time zone from base::OlsonNames()
#' @return Expr of i64
#' @keywords ExprDT
#' @details corresponds to in R manually modifying the tzone attribute of POSIXt objects
#' @format function
#' @aliases (Expr)$dt$with_time_zone
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(low = as.Date("2001-3-1"), high = as.Date("2001-5-1"), interval = "1mo")
#' )
#' df$select(
#'   pl$col("date"),
#'   pl$col("date")
#'     $dt$with_time_zone("Europe/London")
#'     $alias("London_with"),
#'   pl$col("date")
#'     $dt$tz_localize("Europe/London")
#'     $alias("London_localize")
#' )
ExprDT_with_time_zone = function(tz) {
  check_tz_to_result(tz) |>
    map(\(valid_tz) .pr$Expr$dt_with_time_zone(self, valid_tz)) |>
    map_err(\(err) paste("in dt$with_time_zone:", err)) |>
    unwrap()
}

#' cast_time_zone
#' @description
#' Cast time zone for a Series of type Datetime.
#' Different from ``with_time_zone``, this will also modify the underlying timestamp.
#' Use to correct a wrong time zone annotation. This will change the corresponding global timepoint.
#'
#' @name ExprDT_cast_time_zone
#' @param tz Null or string time zone from base::OlsonNames()
#' @return Expr of i64
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$cast_time_zone
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(low = as.Date("2001-3-1"), high = as.Date("2001-7-1"), interval = "1mo")
#' )
#' df = df$with_columns(
#'   pl$col("date")
#'     $dt$with_time_zone("Europe/London")
#'     $alias("london_timezone")
#' )
#'
#' df2 = df$with_columns(
#'   pl$col("london_timezone")
#'     $dt$cast_time_zone("Europe/Amsterdam")
#'     $alias("cast London_to_Amsterdam"),
#'   pl$col("london_timezone")
#'     $dt$with_time_zone("Europe/Amsterdam")
#'     $alias("with London_to_Amsterdam"),
#'   pl$col("london_timezone")
#'     $dt$with_time_zone("Europe/Amsterdam")
#'     $dt$cast_time_zone(NULL)
#'     $alias("strip tz from with-'Europe/Amsterdam'")
#' )
#' df2
ExprDT_cast_time_zone = function(tz) {
  check_tz_to_result(tz) |>
    map(\(valid_tz) .pr$Expr$dt_cast_time_zone(self, valid_tz)) |>
    map_err(\(err) paste("in dt$cast_time_zone:", err)) |>
    unwrap()
}


#' Localize time zone
#' @description
#' Localize tz-naive Datetime Series to tz-aware Datetime Series.
#' This method takes a naive Datetime Series and makes this time zone aware.
#' It does not move the time to another time zone.
#'
#' @param tz string of time zone (no NULL allowed) see allowed timezone in base::OlsonNames()
#' @name ExprDT_tz_localize
#' @details In R as modifying tzone attribute manually but takes into account summertime.
#' See unittest "dt$with_time_zone dt$tz_localize" for a more detailed comparison to base R.
#' @return Expr of i64
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$tz_localize
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(low = as.Date("2001-3-1"), high = as.Date("2001-7-1"), interval = "1mo")
#' )
#' df = df$with_columns(
#'   pl$col("date")
#'     $dt$with_time_zone("Europe/London")
#'     $alias("london_timezone"),
#'   pl$col("date")
#'     $dt$tz_localize("Europe/London")
#'     $alias("tz_loc_london")
#' )
#'
#' df2 = df$with_columns(
#'   pl$col("london_timezone")
#'     $dt$cast_time_zone("Europe/Amsterdam")
#'     $alias("cast London_to_Amsterdam"),
#'   pl$col("london_timezone")
#'     $dt$with_time_zone("Europe/Amsterdam")
#'     $alias("with London_to_Amsterdam"),
#'   pl$col("london_timezone")
#'     $dt$with_time_zone("Europe/Amsterdam")
#'     $dt$cast_time_zone(NULL)
#'     $alias("strip tz from with-'Europe/Amsterdam'")
#' )
#' df2
ExprDT_tz_localize = function(tz) {
  check_tz_to_result(tz, allow_null = FALSE) |>
    map(\(valid_tz) .pr$Expr$dt_tz_localize(self, valid_tz)) |>
    map_err(\(err) paste("in dt$tz_localize:", err)) |>
    unwrap()
}

#' Days
#' @description Extract the days from a Duration type.
#' @name ExprDT_days
#' @return Expr of i64
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$days
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(low = as.Date("2020-3-1"), high = as.Date("2020-5-1"), interval = "1mo")
#' )
#' df$select(
#'   pl$col("date"),
#'   pl$col("date")$diff()$dt$days()$alias("days_diff")
#' )
ExprDT_days = function() {
  .pr$Expr$duration_days(self)
}

#' Hours
#' @description Extract the hours from a Duration type.
#' @name ExprDT_hours
#' @return Expr of i64
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$hours
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(low = as.Date("2020-1-1"), high = as.Date("2020-1-4"), interval = "1d")
#' )
#' df$select(
#'   pl$col("date"),
#'   pl$col("date")$diff()$dt$hours()$alias("hours_diff")
#' )
ExprDT_hours = function() {
  .pr$Expr$duration_hours(self)
}

#' Minutes
#' @description Extract the minutes from a Duration type.
#' @name ExprDT_minutes
#' @return Expr of i64
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$minutes
#' @examples
#' df = pl$DataFrame(
#'   date = pl$date_range(low = as.Date("2020-1-1"), high = as.Date("2020-1-4"), interval = "1d")
#' )
#' df$select(
#'   pl$col("date"),
#'   pl$col("date")$diff()$dt$minutes()$alias("minutes_diff")
#' )
ExprDT_minutes = function() {
  .pr$Expr$duration_minutes(self)
}


#' Seconds
#' @description Extract the seconds from a Duration type.
#' @name ExprDT_seconds
#' @return Expr of i64
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$seconds
#' @examples
#' df = pl$DataFrame(date = pl$date_range(
#'     low = as.POSIXct("2020-1-1", tz = "GMT"),
#'     high = as.POSIXct("2020-1-1 00:04:00", tz = "GMT"),
#'     interval = "1m"
#' ))
#' df$select(
#'   pl$col("date"),
#'   pl$col("date")$diff()$dt$seconds()$alias("seconds_diff")
#' )
ExprDT_seconds = function() {
  .pr$Expr$duration_seconds(self)
}

#' milliseconds
#' @description Extract the milliseconds from a Duration type.
#' @name ExprDT_milliseconds
#' @return Expr of i64
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$milliseconds
#' @examples
#' df = pl$DataFrame(date = pl$date_range(
#'     low = as.POSIXct("2020-1-1", tz = "GMT"),
#'     high = as.POSIXct("2020-1-1 00:00:01", tz = "GMT"),
#'     interval = "1ms"
#' ))
#' df$select(
#'   pl$col("date"),
#'   pl$col("date")$diff()$dt$milliseconds()$alias("seconds_diff")
#' )
ExprDT_milliseconds = function() {
  .pr$Expr$duration_milliseconds(self)
}

#' microseconds
#' @description Extract the microseconds from a Duration type.
#' @name ExprDT_microseconds
#' @return Expr of i64
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$microseconds
#' @examples
#' df = pl$DataFrame(date = pl$date_range(
#'     low = as.POSIXct("2020-1-1", tz = "GMT"),
#'     high = as.POSIXct("2020-1-1 00:00:01", tz = "GMT"),
#'     interval = "1ms"
#' ))
#' df$select(
#'   pl$col("date"),
#'   pl$col("date")$diff()$dt$microseconds()$alias("seconds_diff")
#' )
ExprDT_microseconds = function() {
  .pr$Expr$duration_microseconds(self)
}

#' nanoseconds
#' @description Extract the nanoseconds from a Duration type.
#' @name ExprDT_nanoseconds
#' @return Expr of i64
#' @keywords ExprDT
#' @format function
#' @aliases (Expr)$dt$nanoseconds
#' @examples
#' df = pl$DataFrame(date = pl$date_range(
#'     low = as.POSIXct("2020-1-1", tz = "GMT"),
#'     high = as.POSIXct("2020-1-1 00:00:01", tz = "GMT"),
#'     interval = "1ms"
#' ))
#' df$select(
#'   pl$col("date"),
#'   pl$col("date")$diff()$dt$nanoseconds()$alias("seconds_diff")
#' )
ExprDT_nanoseconds = function() {
  .pr$Expr$duration_nanoseconds(self)
}


#' Offset By
#' @description  Offset this date by a relative time offset.
#' This differs from ``pl$col("foo_datetime_tu") + value_tu`` in that it can
#' take months and leap years into account. Note that only a single minus
#' sign is allowed in the ``by`` string, as the first character.
#' @name ExprDT_offset_by
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
#' @format function
#' @aliases (Expr)$dt$offset_by
#' @examples
#' df = pl$DataFrame(
#'   dates = pl$date_range(as.Date("2000-1-1"),as.Date("2005-1-1"), "1y")
#' )
#' df$select(
#'   pl$col("dates")$dt$offset_by("1y")$alias("date_plus_1y"),
#'   pl$col("dates")$dt$offset_by("-1y2mo")$alias("date_min")
#' )
ExprDT_offset_by = function(by) {
  .pr$Expr$dt_offset_by(self,by)
}
