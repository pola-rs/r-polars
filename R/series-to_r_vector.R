# TODO: use options to set the default arguments
# TODO: more notes about naive time
# TODO: link to the type mapping vignette
#' Export the Series as an R vector
#'
#' @inheritParams rlang::args_dots_empty
#' @param int64 Determine how to convert Polars' Int64, UInt32, or UInt64 type values to R type.
#' One of the followings:
#' - `"double"`: Convert to the R's [double] type.
#' - `"character"`: Convert to the R's [character] type.
#' - `"integer"`: Convert to the R's [integer] type.
#'   If the value is out of the range of R's integer type, export as [NA_integer_].
#' - `"integer64"`: Convert to the [bit64::integer64] class.
#'   The [bit64][bit64::bit64-package] package must be installed.
#'   If the value is out of the range of [bit64::integer64], export as [bit64::NA_integer64_].
#' @param as_clock_class A logical value indicating whether to export datetimes and duration as
#' the [clock][clock::clock] package's classes.
#' - `FALSE` (default): Duration values are exported as [difftime]
#'   and datetime values are exported as [POSIXct].
#'   Accuracy may be degraded.
#' - `TRUE`: Duration values are exported as [clock_duration][clock::duration-helper],
#'   datetime without timezone values are exported as [clock_naive_time][clock::as_naive_time],
#'   and datetime with timezone values are exported as [clock_zoned_time][clock::as_zoned_time].
#'   For this case, the [clock][clock::clock] package must be installed.
#'   Accuracy will be maintained.
#' @param ambiguous Determine how to deal with ambiguous datetimes.
#' Only applicable when `as_clock_class` is set to `FALSE` and
#' datetime without timezone values are exported as [POSIXct].
#' Character vector or Expression containing the followings:
#' - `"raise"` (default): Throw an error
#' - `"earliest"`: Use the earliest datetime
#' - `"latest"`: Use the latest datetime
#' - `"null"`: Return a `NA` value
#' @param non_existent Determine how to deal with non-existent datetimes.
#' Only applicable when `as_clock_class` is set to `FALSE` and
#' datetime without timezone values are exported as [POSIXct].
#' One of the followings:
#' - `"raise"` (default): Throw an error
#' - `"null"`: Return a `NA` value
#' @return A [vector]
#' @examples
#' # Integer values handling
#' series_uint64 <- as_polars_series(
#'   c(NA, "0", "4294967295", "18446744073709551615")
#' )$cast(pl$UInt64)
#' series_uint64
#'
#' ## Export UInt64 as double
#' series_uint64$to_r_vector(int64 = "double")
#'
#' ## Export UInt64 as character
#' series_uint64$to_r_vector(int64 = "character")
#'
#' ## Export UInt64 as integer (overflow occurs)
#' series_uint64$to_r_vector(int64 = "integer")
#'
#' ## Export UInt64 as bit64::integer64 (overflow occurs)
#' if (requireNamespace("bit64", quietly = TRUE)) {
#'   series_uint64$to_r_vector(int64 = "integer64")
#' }
#'
#' # Duration values handling
#' series_duration <- as_polars_series(
#'   c(NA, -1000000000, -10, -1, 1000000000)
#' )$cast(pl$Duration("ns"))
#' series_duration
#'
#' ## Export Duration as difftime
#' series_duration$to_r_vector(as_clock_class = FALSE)
#'
#' ## Export Duration as clock_duration
#' if (requireNamespace("clock", quietly = TRUE)) {
#'   series_duration$to_r_vector(as_clock_class = TRUE)
#' }
#'
#' # Datetime values handling
#' series_datetime <- as_polars_series(
#'   as.POSIXct(
#'     c(NA, "1920-01-01 00:00:00", "1970-01-01 00:00:00", "2020-01-01 00:00:00"),
#'     tz = "UTC"
#'   )
#' )$cast(pl$Datetime("ns", "UTC"))
#' series_datetime
#'
#' ## Export zoned datetime as POSIXct
#' series_datetime$to_r_vector(as_clock_class = FALSE)
#'
#' ## Export zoned datetime as clock_zoned_time
#' if (requireNamespace("clock", quietly = TRUE)) {
#'   series_datetime$to_r_vector(as_clock_class = TRUE)
#' }
series__to_r_vector <- function(
    ...,
    int64 = "double",
    as_clock_class = FALSE,
    ambiguous = "raise",
    non_existent = "raise") {
  wrap({
    check_dots_empty0(...)

    # Ensure the bit64 package is loaded if int64 is set to 'integer64'
    if (identical(int64, "integer64")) {
      if (!is_installed("bit64")) {
        abort("If the `int64` argument is set to 'integer64', the `bit64` package must be installed.")
      }
    }
    if (isTRUE(as_clock_class)) {
      if (!is_installed("clock")) {
        abort("If the `as_clock_class` argument is set to `TRUE`, the `clock` package must be installed.")
      }
    }

    ambiguous <- as_polars_expr(ambiguous, str_as_lit = TRUE)$`_rexpr`
    self$`_s`$to_r_vector(
      int64 = int64,
      as_clock_class = as_clock_class,
      ambiguous = ambiguous,
      non_existent = non_existent,
      local_time_zone = Sys.timezone()
    )
  })
}
