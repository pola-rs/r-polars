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


#'
#' Round datetime
#' @description  Create a naive Datetime from an existing Date/Datetime expression and a Time.
#' Each date/datetime in the first half of the interval
#' is mapped to the start of its bucket.
#' Each date/datetime in the second half of the interval
#' is mapped to the end of its bucket.
#' @name dt_round
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
  if( inherits(tm, "PTime")) {
    tu = "ns" #PTime implicitly get converted to "ns"
  }
  if(!is_string(tu)) stopf("combine: input tu is not a string, [%s ]",str_string(tu))
  unwrap(.pr$Expr$dt_combine(self, wrap_e(tm), tu))
}



