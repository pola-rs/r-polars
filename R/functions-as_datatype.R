#' Create a Polars literal expression of type Datetime
#'
#' @inherit as_polars_expr return
#' @inheritParams rlang::args_dots_empty
#' @inheritParams pl__Datetime
#' @inheritParams expr_dt_replace_time_zone
#' @param year An [polars expression][Expr] or something can be coerced to
#' an [polars expression][Expr] by [as_polars_expr()],
#' which represents a column or literal number of year.
#' @param month An [polars expression][Expr] or something can be coerced to
#' an [polars expression][Expr] by [as_polars_expr()],
#' which represents a column or literal number of month. Range: 1-12.
#' @param day An [polars expression][Expr] or something can be coerced to
#' an [polars expression][Expr] by [as_polars_expr()],
#' which represents a column or literal number of day. Range: 1-31.
#' @param hour An [polars expression][Expr] or something can be coerced to
#' an [polars expression][Expr] by [as_polars_expr()],
#' which represents a column or literal number of hour. Range: 0-23.
#' @param minute An [polars expression][Expr] or something can be coerced to
#' an [polars expression][Expr] by [as_polars_expr()],
#' which represents a column or literal number of minute. Range: 0-59.
#' @param second An [polars expression][Expr] or something can be coerced to
#' an [polars expression][Expr] by [as_polars_expr()],
#' which represents a column or literal number of second. Range: 0-59.
#' @param microsecond An [polars expression][Expr] or something can be coerced to
#' an [polars expression][Expr] by [as_polars_expr()],
#' which represents a column or literal number of microsecond. Range: 0-999999.
#' @examples
#' df <- pl$DataFrame(
#'   month = c(1, 2, 3),
#'   day = c(4, 5, 6),
#'   hour = c(12, 13, 14),
#'   minute = c(15, 30, 45)
#' )
#'
#' df$with_columns(
#'   pl$datetime(
#'     2024,
#'     pl$col("month"),
#'     pl$col("day"),
#'     pl$col("hour"),
#'     pl$col("minute"),
#'     time_zone = "Australia/Sydney"
#'   )
#' )
#'
#' # We can also use `pl$datetime()` for filtering:
#' df <- pl$select(
#'   start = ISOdatetime(2024, 1, 1, 0, 0, 0),
#'   end = c(
#'     ISOdatetime(2024, 5, 1, 20, 15, 10),
#'     ISOdatetime(2024, 7, 1, 21, 25, 20),
#'     ISOdatetime(2024, 9, 1, 22, 35, 30)
#'   )
#' )
#'
#' df$filter(pl$col("end") > pl$datetime(2024, 6, 1))
pl__datetime <- function(
  year,
  month,
  day,
  hour = NULL,
  minute = NULL,
  second = NULL,
  microsecond = NULL,
  ...,
  time_unit = c("us", "ns", "ms"),
  time_zone = NULL,
  ambiguous = c("raise", "earliest", "latest", "null")
) {
  wrap({
    check_dots_empty0(...)

    time_unit <- arg_match0(time_unit, c("us", "ns", "ms"))
    if (!is_polars_expr(ambiguous)) {
      ambiguous <- arg_match0(ambiguous, c("raise", "earliest", "latest", "null")) |>
        as_polars_expr(as_lit = TRUE)
    }

    year <- as_polars_expr(year)
    month <- as_polars_expr(month)
    day <- as_polars_expr(day)

    if (!is.null(hour)) {
      hour <- as_polars_expr(hour)
    }
    if (!is.null(minute)) {
      minute <- as_polars_expr(minute)
    }
    if (!is.null(second)) {
      second <- as_polars_expr(second)
    }
    if (!is.null(microsecond)) {
      microsecond <- as_polars_expr(microsecond)
    }

    datetime(
      year = year$`_rexpr`,
      month = month$`_rexpr`,
      day = day$`_rexpr`,
      hour = hour$`_rexpr`,
      minute = minute$`_rexpr`,
      second = second$`_rexpr`,
      microsecond = microsecond$`_rexpr`,
      time_unit = time_unit,
      time_zone = time_zone,
      ambiguous = ambiguous$`_rexpr`
    )
  })
}

#' Create a Polars literal expression of type Date
#'
#' @inherit pl__datetime params return
#' @examples
#' df <- pl$DataFrame(month = 1:3, day = 4:6)
#' df$with_columns(pl$date(2024, pl$col("month"), pl$col("day")))
#'
#' # We can also use `pl$date()` for filtering:
#' df <- pl$DataFrame(
#'   start = rep(as.Date("2024-01-01"), 3),
#'   end = as.Date(c("2024-05-01", "2024-07-01", "2024-09-01"))
#' )
#' df$filter(pl$col("end") > pl$date(2024, 6, 1))
pl__date <- function(year, month, day) {
  pl__datetime(year, month, day)$cast(pl$Date)$alias("date") |>
    wrap()
}

# TODO: more examples
#' Create polars Duration from distinct time components
#'
#' A [Duration][pl__Duration] represents a fixed amount of time. For example,
#' `pl$duration(days = 1)` means "exactly 24 hours". By contrast,
#' [`<expr>$dt$offset_by("1d")`][expr_dt_offset_by] means "1 calendar day", which could sometimes be
#' 23 hours or 25 hours depending on Daylight Savings Time.
#' For non-fixed durations such as "calendar month" or "calendar day",
#' please use [`<expr>$dt$offset_by()`][expr_dt_offset_by] instead.
#' @inherit as_polars_expr return
#' @inheritParams rlang::args_dots_empty
#' @param weeks Something can be coerced to an [polars expression][Expr] by [as_polars_expr()]
#' which represents a column or literal number of weeks, or `NULL` (default).
#' @param days Something can be coerced to an [polars expression][Expr] by [as_polars_expr()]
#' which represents a column or literal number of days, or `NULL` (default).
#' @param hours Something can be coerced to an [polars expression][Expr] by [as_polars_expr()]
#' which represents a column or literal number of hours, or `NULL` (default).
#' @param minutes Something can be coerced to an [polars expression][Expr] by [as_polars_expr()]
#' which represents a column or literal number of minutes, or `NULL` (default).
#' @param seconds Something can be coerced to an [polars expression][Expr] by [as_polars_expr()]
#' which represents a column or literal number of seconds, or `NULL` (default).
#' @param milliseconds Something can be coerced to an [polars expression][Expr]
#' by [as_polars_expr()]
#' which represents a column or literal number of milliseconds, or `NULL` (default).
#' @param microseconds Something can be coerced to an [polars expression][Expr]
#' by [as_polars_expr()]
#' which represents a column or literal number of microseconds, or `NULL` (default).
#' @param nanoseconds Something can be coerced to an [polars expression][Expr] by [as_polars_expr()]
#' which represents a column or literal number of nanoseconds, or `NULL` (default).
#' @param time_unit One of `NULL`, `"us"` (microseconds),
#' `"ns"` (nanoseconds) or `"ms"`(milliseconds). Representing the unit of time.
#' If `NULL` (default), the time unit will be inferred from the other inputs:
#' `"ns"` if `nanoseconds` was specified, `"us"` otherwise.
#' @examples
#' df <- pl$DataFrame(
#'   dt = as.POSIXct(c("2022-01-01", "2022-01-02")),
#'   add = c(1, 2)
#' )
#' df
#'
#' df$select(
#'   add_weeks = pl$col("dt") + pl$duration(weeks = pl$col("add")),
#'   add_days = pl$col("dt") + pl$duration(days = pl$col("add")),
#'   add_seconds = pl$col("dt") + pl$duration(seconds = pl$col("add")),
#'   add_millis = pl$col("dt") + pl$duration(milliseconds = pl$col("add")),
#'   add_hours = pl$col("dt") + pl$duration(hours = pl$col("add"))
#' )
pl__duration <- function(
  ...,
  weeks = NULL,
  days = NULL,
  hours = NULL,
  minutes = NULL,
  seconds = NULL,
  milliseconds = NULL,
  microseconds = NULL,
  nanoseconds = NULL,
  time_unit = NULL
) {
  wrap({
    check_dots_empty0(...)

    if (!is.null(weeks)) {
      weeks <- as_polars_expr(weeks)
    }
    if (!is.null(days)) {
      days <- as_polars_expr(days)
    }
    if (!is.null(hours)) {
      hours <- as_polars_expr(hours)
    }
    if (!is.null(minutes)) {
      minutes <- as_polars_expr(minutes)
    }
    if (!is.null(seconds)) {
      seconds <- as_polars_expr(seconds)
    }
    if (!is.null(milliseconds)) {
      milliseconds <- as_polars_expr(milliseconds)
    }
    if (!is.null(microseconds)) {
      microseconds <- as_polars_expr(microseconds)
    }
    if (!is.null(nanoseconds)) {
      nanoseconds <- as_polars_expr(nanoseconds)
      time_unit <- time_unit %||% "ns"
    }

    time_unit <- time_unit %||% "us"

    time_unit <- arg_match0(time_unit, c("us", "ns", "ms"))

    duration(
      weeks = weeks$`_rexpr`,
      days = days$`_rexpr`,
      hours = hours$`_rexpr`,
      minutes = minutes$`_rexpr`,
      seconds = seconds$`_rexpr`,
      milliseconds = milliseconds$`_rexpr`,
      microseconds = microseconds$`_rexpr`,
      nanoseconds = nanoseconds$`_rexpr`,
      time_unit = time_unit
    )
  })
}

#' Collect columns into a struct column
#'
#' @inheritParams lazyframe__select
#' @param .schema Optional schema that explicitly defines the struct field
#' dtypes. If no columns or expressions are provided, `.schema` keys are used
#' to define columns.
#'
#' @inherit as_polars_expr return
#' @examples
#' # Collect all columns of a dataframe into a struct by passing pl$all().
#' df <- pl$DataFrame(
#'   int = 1:2,
#'   str = c("a", "b"),
#'   bool = c(TRUE, NA),
#'   list = list(1:2, 3L),
#' )
#' df$select(pl$struct(pl$all())$alias("my_struct"))
#'
#' # Collect selected columns into a struct by either passing a list of
#' # columns, or by specifying each column as a positional argument.
#' df$select(pl$struct("int", FALSE)$alias("my_struct"))
#'
#' # Name each struct field.
#' df$select(pl$struct(p = "int", q = "bool")$alias("my_struct"))$schema
#'
#' # Pass a schema to specify the datatype of each field in the struct:
#' struct_schema <- list(int = pl$UInt32, list = pl$List(pl$Float32))
#' df$select(
#'   new_struct = pl$struct(pl$col("int", "list"), .schema = struct_schema)
#' )$unnest("new_struct")
pl__struct <- function(..., .schema = NULL) {
  wrap({
    rexprs <- parse_into_list_of_expressions(...)
    if (is.null(.schema)) {
      as_struct(rexprs)
    } else {
      check_list_of_polars_dtype(.schema)
      if (length(rexprs) == 0L) {
        expr <- parse_into_list_of_expressions(!!!names(.schema)) |>
          as_struct() |>
          wrap()
      } else {
        expr <- wrap(as_struct(rexprs))
      }
      expr$cast(pl$Struct(!!!.schema), strict = FALSE)
    }
  })
}

#' Horizontally concatenate columns into a single list column
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Columns to concatenate into a
#' single list column. Accepts expression input. Strings are parsed as column
#' names, other non-expression inputs are parsed as literals.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(a = list(1:2, 3, 4:5), b = list(4, integer(0), NULL))
#'
#' # Concatenate two existing list columns. Null values are propagated.
#' df$with_columns(concat_list = pl$concat_list("a", "b"))
#'
#' # Non-list columns are cast to a list before concatenation. The output data
#' # type is the supertype of the concatenated columns.
#' df$select("a", concat_list = pl$concat_list("a", pl$lit("x")))
#'
#' # Create lagged columns and collect them into a list. This mimics a rolling
#' # window.
#' df <- pl$DataFrame(A = c(1, 2, 9, 2, 13))
#' df <- df$select(
#'   A_lag_1 = pl$col("A")$shift(1),
#'   A_lag_2 = pl$col("A")$shift(2),
#'   A_lag_3 = pl$col("A")$shift(3)
#' )
#' df$select(A_rolling = pl$concat_list("A_lag_1", "A_lag_2", "A_lag_3"))
pl__concat_list <- function(...) {
  wrap({
    check_dots_unnamed()
    parse_into_list_of_expressions(...) |>
      concat_list()
  })
}

#' Horizontally concatenate columns into a single string column
#'
#' Operates in linear time.
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Columns to concatenate into a
#' single string column. Accepts expression input. Strings are parsed as column
#' names, other non-expression inputs are parsed as literals. Non-`String`
#' columns are cast to `String`.
#' @param separator String that will be used to separate the values of each
#' column.
#' @param ignore_nulls If `FALSE` (default), null values will be propagated,
#' i.e. if the row contains any null values, the output is null.
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   a = 1:3,
#'   b = c("dogs", "cats", NA),
#'   c = c("play", "swim", "walk")
#' )
#' df$with_columns(
#'   full_sentence = pl$concat_str(
#'     pl$col("a") * 2L,
#'     pl$col("b"),
#'     pl$col("c"),
#'     separator = " ",
#'   )
#' )
pl__concat_str <- function(..., separator = "", ignore_nulls = FALSE) {
  wrap({
    check_dots_unnamed()
    exprs <- parse_into_list_of_expressions(...)
    concat_str(exprs, separator, ignore_nulls)
  })
}
