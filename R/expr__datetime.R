#' Truncate datetime
#' @description  Divide the date/datetime range into buckets.
#' Each date/datetime is mapped to the start of its bucket.
#' @name dt_truncate
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
#' @aliases dt.truncate arr_truncate
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
#' @name dt_round
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
#' @aliases dt.round arr_round
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
#' @name dt_combine
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
#' @aliases dt.combine arr_combine
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
#' @name dt_combine
#'
#' @param fmt string format very much like in R passed to chrono
#'
#' @return   Date/Datetime expr
#' @keywords ExprDT
#' @format function
#' @aliases dt.strftime arr_strftime
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
#' @name dt_combine
#'
#' @param fmt string format very much like in R passed to chrono
#'
#' @return Expr of Year as Int32
#' @keywords ExprDT
#' @format function
#' @aliases dt.year arr_year
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
#' @name dt_combine
#'
#' @param fmt string format very much like in R passed to chrono
#'
#' @return Expr of iso_year as Int32
#' @keywords ExprDT
#' @format function
#' @aliases dt.iso_year arr_iso_year
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
