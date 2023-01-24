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
#' t_ms = unclass(as.POSIXct("3040-01-01",tz = "GMT",origin="GMT")) * 1000
#' s = pl$date_range(t_ms,t_ms+25000, interval = "2s", time_unit = "ms", time_zone = "CET")
#'
#' #use a dt namespace function
#' df = pl$DataFrame(datetime = s)$with_columns(
#'   pl$col("datetime")$dt$truncate("4s")$alias("truncated_4s"),
#'   pl$col("datetime")$dt$truncate("4s",offset("3s"))$alias("truncated_4s_offset_2s")
#' )
#' df
ExprDT_truncate = function(
    every,# str | timedelta, #support R difftime
    offset = NULL#: str | timedelta | None = None,
) {
  .pr$Expr$dt_truncate(self, every, offset %||% "0ns")
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
  .pr$Expr$dt_round(self, every, offset %||% "0ns")
}



