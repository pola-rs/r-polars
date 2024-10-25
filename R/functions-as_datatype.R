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
    ambiguous = c("raise", "earliest", "latest", "null")) {
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

# TODO: support `schema` argument
#' Collect columns into a struct column
#'
#' @inherit as_polars_expr return
#' @inheritParams lazyframe__select
#' @examples
#' # Collect all columns of a dataframe into a struct by passing pl.all().
#' df <- pl$DataFrame(
#'   int = 1:2,
#'   str = c("a", "b"),
#'   bool = c(TRUE, NA),
#'   list = list(1:2, 3L),
#' )
#' df$select(pl$struct(pl$all())$alias("my_struct"))
#'
#' # Name each struct field.
#' df$select(pl$struct(p = "int", q = "bool")$alias("my_struct"))$schema
pl__struct <- function(...) {
  parse_into_list_of_expressions(...) |>
    as_struct() |>
    wrap()
}
