# TODO: use options to set the default arguments
# TODO: more notes about naive time
# TODO: link to the type mapping vignette
# TODO: link to the data type doc
#' Export the Series as an R vector
#'
#' Export the [Series] as an R [vector].
#' But note that the Struct data type is exported as a [data.frame] by default for consistency,
#' and a [data.frame] is not a vector.
#' If you want to ensure the return value is a [vector], please set `ensure_vector = TRUE`,
#' or use the [as.vector()] function instead.
#'
#' The class/type of the exported object depends on the data type of the Series as follows:
#' - Boolean: [logical].
#' - UInt8: [integer] or [raw], depending on the `uint8` argument.
#' - UInt16, Int8, Int16, Int32: [integer].
#' - Int64, UInt32, UInt64: [double], [character], [integer], or [bit64::integer64],
#'   depending on the `int64` argument.
#' - Float32, Float64: [double].
#' - Decimal: [double].
#' - String: [character].
#' - Categorical: [factor].
#' - Date: [Date] or [data.table::IDate][data.table::IDateTime],
#'   depending on the `date` argument.
#' - Time: [hms::hms] or [data.table::ITime][data.table::IDateTime],
#'   depending on the `time` argument.
#' - Datetime (without timezone): [POSIXct] or [clock_naive_time][clock::as_naive_time],
#'   depending on the `as_clock_class` argument.
#' - Datetime (with timezone): [POSIXct] or [clock_zoned_time][clock::as_zoned_time],
#'   depending on the `as_clock_class` argument.
#' - Duration: [difftime] or [clock_duration][clock::duration-helper],
#'   depending on the `as_clock_class` argument.
#' - Binary: [blob::blob].
#' - Null: [vctrs::unspecified].
#' - List, Array: [vctrs::list_of].
#' - Struct: [data.frame] or [tibble][tibble::tbl_df], depending on the `struct` argument.
#'   If `ensure_vector = TRUE`, the top-level Struct is exported as a named [list] for
#'   to ensure the return value is a [vector].
#' @inheritParams rlang::args_dots_empty
#' @param ensure_vector A logical value indicating whether to ensure the return value is a [vector].
#' When the Series has the Struct data type and this argument is `FALSE` (default),
#' the return value is a [data.frame], not a [vector] (`is.vector(<data.frame>)` is `FALSE`).
#' If `TRUE`, return a named [list] instead of a [data.frame].
#' @param uint8 Determine how to convert Polars' UInt8 type values to R type.
#' One of the followings:
#' - `"integer"` (default): Convert to the R's [integer] type.
#' - `"raw"`: Convert to the R's [raw] type.
#'   If the value is `null`, export as `00`.
#' @param int64 Determine how to convert Polars' Int64, UInt32, or UInt64 type values to R type.
#' One of the followings:
#' - `"double"` (default): Convert to the R's [double] type.
#'   Accuracy may be degraded.
#' - `"character"`: Convert to the R's [character] type.
#' - `"integer"`: Convert to the R's [integer] type.
#'   If the value is out of the range of R's integer type, export as [NA_integer_].
#' - `"integer64"`: Convert to the [bit64::integer64] class.
#'   The [bit64][bit64::bit64-package] package must be installed.
#'   If the value is out of the range of [bit64::integer64], export as [bit64::NA_integer64_].
#' @param date Determine how to convert Polars' Date type values to R class.
#' One of the followings:
#' - `"Date"` (default): Convert to the R's [Date] class.
#' - `"IDate"`: Convert to the [data.table::IDate][data.table::IDateTime] class.
#' @param time Determine how to convert Polars' Time type values to R class.
#' One of the followings:
#' - `"hms"` (default): Convert to the [hms::hms] class.
#'   If the [hms][hms::hms-package] package is not installed, a warning will be shown.
#' - `"ITime"`: Convert to the [data.table::ITime][data.table::IDateTime] class.
#'   The [data.table][data.table::data.table-package] package must be installed.
#' @param struct Determine how to convert Polars' Struct type values to R class.
#' One of the followings:
#' - `"dataframe"` (default): Convert to the R's [data.frame] class.
#' - `"tibble"`: Convert to the [tibble][tibble::tbl_df] class.
#'   If the [tibble][tibble::tibble-package] package is not installed, a warning will be shown.
#' @param decimal Determine how to convert Polars' Decimal type values to R type.
#' One of the followings:
#' - `"double"` (default): Convert to the R's [double] type.
#' - `"character"`: Convert to the R's [character] type.
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
#' Character vector or [expression] containing the followings:
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
#' # Struct values handling
#' series_struct <- as_polars_series(
#'   data.frame(
#'     a = 1:2,
#'     b = I(list(data.frame(c = "foo"), data.frame(c = "bar")))
#'   )
#' )
#' series_struct
#'
#' ## Export Struct as data.frame
#' series_struct$to_r_vector()
#'
#' ## Export Struct as data.frame,
#' ## but the top-level Struct is exported as a named list
#' series_struct$to_r_vector(ensure_vector = TRUE)
#'
#' ## Export Struct as tibble
#' series_struct$to_r_vector(struct = "tibble")
#'
#' ## Export Struct as tibble,
#' ## but the top-level Struct is exported as a named list
#' series_struct$to_r_vector(struct = "tibble", ensure_vector = TRUE)
#'
#' # UInt8 values handling
#' series_uint8 <- as_polars_series(c(NA, 0, 255))$cast(pl$UInt8)
#' series_uint8
#'
#' ## Export UInt8 as integer
#' series_uint8$to_r_vector(uint8 = "integer")
#'
#' ## Export UInt8 as raw (`null` is exported as `00`)
#' series_uint8$to_r_vector(uint8 = "raw")
#'
#' # Other Integer values handlings
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
  ensure_vector = FALSE,
  uint8 = c("integer", "raw"),
  int64 = c("double", "character", "integer", "integer64"),
  date = c("Date", "IDate"),
  time = c("hms", "ITime"),
  struct = c("dataframe", "tibble"),
  decimal = c("double", "character"),
  as_clock_class = FALSE,
  ambiguous = c("raise", "earliest", "latest", "null"),
  non_existent = c("raise", "null")
) {
  wrap({
    check_dots_empty0(...)

    option_name_prefix <- "polars.to_r_vector."
    uint8 <- use_option_if_missing(uint8, missing(uint8), "integer", option_name_prefix)
    int64 <- use_option_if_missing(int64, missing(int64), "double", option_name_prefix)
    date <- use_option_if_missing(date, missing(date), "Date", option_name_prefix)
    time <- use_option_if_missing(time, missing(time), "hms", option_name_prefix)
    struct <- use_option_if_missing(struct, missing(struct), "dataframe", option_name_prefix)
    as_clock_class <- use_option_if_missing(
      as_clock_class,
      missing(as_clock_class),
      FALSE,
      option_name_prefix
    )
    decimal <- use_option_if_missing(decimal, missing(decimal), "double", option_name_prefix)
    ambiguous <- use_option_if_missing(
      ambiguous,
      missing(ambiguous),
      "raise",
      option_name_prefix
    )
    non_existent <- use_option_if_missing(
      non_existent,
      missing(non_existent),
      "raise",
      option_name_prefix
    )

    uint8 <- arg_match0(uint8, c("integer", "raw"))
    int64 <- arg_match0(int64, c("double", "character", "integer", "integer64"))
    date <- arg_match0(date, c("Date", "IDate"))
    time <- arg_match0(time, c("hms", "ITime"))
    struct <- arg_match0(struct, c("dataframe", "tibble"))
    decimal <- arg_match0(decimal, c("double", "character"))

    non_existent <- arg_match0(non_existent, c("raise", "null"))
    if (!is_polars_expr(ambiguous)) {
      ambiguous <- arg_match0(ambiguous, c("raise", "earliest", "latest", "null")) |>
        as_polars_expr(as_lit = TRUE)
    }

    # The vctrs package should be loaded to print vctrs_list_of and vctrs_unspecified correctly.
    if (!is_vctrs_installed()) {
      inform(
        c(
          i = "The `vctrs` package is not installed.",
          i = "Return value may not be printed correctly."
        )
      )
    }

    # The blob package should be loaded to print blob correctly.
    if (!is_blob_installed()) {
      inform(
        c(
          i = "The `blob` package is not installed.",
          i = "The blob class vector will not be printed correctly."
        )
      )
    }

    # Ensure the bit64 package is loaded if int64 is set to 'integer64'
    if (identical(int64, "integer64")) {
      if (!is_bit64_installed()) {
        abort(
          c(
            "The `bit64` package is not installed.",
            `*` = 'If `int64 = "integer64"`, the `bit64` package must be installed.'
          )
        )
      }
    }
    if (identical(time, "ITime")) {
      if (!is_datatable_installed()) {
        abort(
          c(
            "The `data.table` package is not installed.",
            `*` = 'If `time = "ITime"`, the `data.table` package must be installed.'
          )
        )
      }
    } else {
      # The hms package should be loaded to print hms correctly.
      if (!is_hms_installed()) {
        warn(
          c(
            `!` = "The `hms` package is not installed.",
            i = "The hms class vector will be printed as difftime."
          )
        )
      }
    }
    if (identical(struct, "tibble")) {
      if (!is_tibble_installed()) {
        warn(
          c(
            `!` = "The `tibble` package is not installed.",
            i = 'If `struct = "tibble"`, the `tibble` package is recommended to be installed.'
          )
        )
      }
    }
    if (isTRUE(as_clock_class)) {
      if (!is_clock_installed()) {
        abort(
          c(
            "The `clock` package is not installed.",
            `*` = "If `as_clock_class = TRUE`, the `clock` package must be installed."
          )
        )
      }
    }

    ambiguous <- as_polars_expr(ambiguous, as_lit = TRUE)$`_rexpr`
    self$`_s`$to_r_vector(
      ensure_vector = ensure_vector,
      uint8 = uint8,
      int64 = int64,
      date = date,
      time = time,
      struct = struct,
      decimal = decimal,
      as_clock_class = as_clock_class,
      ambiguous = ambiguous,
      non_existent = non_existent,
      local_time_zone = Sys.timezone()
    )
  })
}

is_vctrs_installed <- function() {
  requireNamespace("vctrs", quietly = TRUE)
}

is_blob_installed <- function() {
  requireNamespace("blob", quietly = TRUE)
}

is_hms_installed <- function() {
  requireNamespace("hms", quietly = TRUE)
}

is_bit64_installed <- function() {
  requireNamespace("bit64", quietly = TRUE)
}

is_datatable_installed <- function() {
  requireNamespace("data.table", quietly = TRUE)
}

is_tibble_installed <- function() {
  requireNamespace("tibble", quietly = TRUE)
}

is_clock_installed <- function() {
  requireNamespace("clock", quietly = TRUE)
}
