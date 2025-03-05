# TODO: link to data type docs
# TODO: link to the type mapping vignette
#' Create a Polars Series from an R object
#'
#' The [as_polars_series()] function creates a [polars Series][Series] from various R objects.
#' The Data Type of the Series is determined by the class of the input object.
#'
#' The default method of [as_polars_series()] throws an error,
#' so we need to define S3 methods for the classes we want to support.
#'
#' ## S3 method for [list] and [list] based classes
#'
#' In R, a [list] can contain elements of different types, but in Polars (Apache Arrow),
#' all elements must have the same type.
#' So the [as_polars_series()] function automatically casts all elements to the same type
#' or throws an error, depending on the `strict` argument.
#' We can check the [data type][DataType] of the [Series] that will be created from the [list] by using the
#' [infer_polars_dtype()] function in advance.
#' If you want to create a list with all elements of the same type in R,
#' consider using the [vctrs::list_of()] function.
#'
#' Since a [list] can contain another [list], the `strict` argument is also used
#' when creating [Series] from the inner [list] in the case of classes constructed on top of a [list],
#' such as [data.frame] or [vctrs_rcrd][vctrs::new_rcrd].
#'
#' ## S3 method for [Date]
#'
#' Sub-day values will be ignored (floored to the day).
#'
#' ## S3 method for [POSIXct]
#'
#' Sub-millisecond values will be ignored (floored to the millisecond).
#'
#' If the `tzone` attribute is not present or an empty string (`""`),
#' the [Series]' [dtype][DataType] will be Datetime without timezone.
#'
#'  ## S3 method for [POSIXlt]
#'
#' Sub-nanosecond values will be ignored (floored to the nanosecond).
#'
#' ## S3 method for [difftime]
#'
#' Sub-millisecond values will be rounded to milliseconds.
#'
#' ## S3 method for [hms][hms::hms]
#'
#' Sub-nanosecond values will be ignored (floored to the nanosecond).
#'
#' If the [hms][hms::hms] vector contains values greater-equal to 24-oclock or less than 0-oclock,
#' an error will be thrown.
#'
#' ## S3 method for [clock_duration][clock::duration-helper]
#'
#' Calendrical durations (years, quarters, months) are treated as chronologically with
#' the internal representation of seconds.
#' Please check the [clock_duration][clock::duration-helper] documentation for more details.
#'
#' ## S3 methods for [polars_data_frame][DataFrame], [polars_lazy_frame][LazyFrame], and [data.frame]
#'
#' These methods are shortcuts for `as_polars_df(x, ...)$to_struct()`.
#' See [as_polars_df()] and [`<DataFrame>$to_struct()`][dataframe__to_struct] for more details.
#' @param x An R object.
#' @param name A single string or `NULL`. Name of the Series.
#' Will be used as a column name when used in a [polars DataFrame][DataFrame].
#' When not specified, name is set to an empty string.
#' @param ... Additional arguments passed to the methods.
#' @param strict A logical value to indicate whether throwing an error when
#' the input [list]'s elements have different data types.
#' If `FALSE` (default), all elements are automatically cast to the super type, or,
#' casting to the super type is failed, the value will be `null`.
#' If `TRUE`, the first non-`NULL` element's data type is used as the data type of the inner Series.
#' @return A [polars Series][Series]
#' @seealso
#' - [`<Series>$to_r_vector()`][series__to_r_vector]: Export the Series as an R vector.
#' - [as_polars_df()]: Create a Polars DataFrame from an R object.
#' - [infer_polars_dtype()]: Infer the Polars [DataType] corresponding to an R object.
#' @examples
#' # double
#' as_polars_series(c(NA, 1, 2))
#'
#' # integer
#' as_polars_series(c(NA, 1:2))
#'
#' # character
#' as_polars_series(c(NA, "foo", "bar"))
#'
#' # logical
#' as_polars_series(c(NA, TRUE, FALSE))
#'
#' # raw
#' as_polars_series(charToRaw("foo"))
#'
#' # factor
#' as_polars_series(factor(c(NA, "a", "b")))
#'
#' # Date
#' as_polars_series(as.Date(c(NA, "2021-01-01")))
#'
#' ## Sub-day precision will be ignored
#' as.Date(c(-0.5, 0, 0.5)) |>
#'   as_polars_series()
#'
#' # POSIXct with timezone
#' as_polars_series(as.POSIXct(c(NA, "2021-01-01 00:00:00.123456789"), "UTC"))
#'
#' # POSIXct without timezone
#' as_polars_series(as.POSIXct(c(NA, "2021-01-01 00:00:00.123456789")))
#'
#' # POSIXlt
#' as_polars_series(as.POSIXlt(c(NA, "2021-01-01 00:00:00.123456789"), "UTC"))
#'
#' # difftime
#' as_polars_series(as.difftime(c(NA, 1), units = "days"))
#'
#' ## Sub-millisecond values will be rounded to milliseconds
#' as.difftime(c(0.0005, 0.0010, 0.0015, 0.0020), units = "secs") |>
#'   as_polars_series()
#'
#' as.difftime(c(0.0005, 0.0010, 0.0015, 0.0020), units = "weeks") |>
#'   as_polars_series()
#'
#' # numeric_version
#' as_polars_series(getRversion())
#'
#' # NULL
#' as_polars_series(NULL)
#'
#' # list
#' as_polars_series(list(NA, NULL, list(), 1, "foo", TRUE))
#'
#' ## 1st element will be `null` due to the casting failure
#' as_polars_series(list(list("bar"), "foo"))
#'
#' # data.frame
#' as_polars_series(
#'   data.frame(x = 1:2, y = c("foo", "bar"), z = I(list(1, 2)))
#' )
#'
#' # vctrs_unspecified
#' if (requireNamespace("vctrs", quietly = TRUE)) {
#'   as_polars_series(vctrs::unspecified(3L))
#' }
#'
#' # hms
#' if (requireNamespace("hms", quietly = TRUE)) {
#'   as_polars_series(hms::as_hms(c(NA, "01:00:00")))
#' }
#'
#' # blob
#' if (requireNamespace("blob", quietly = TRUE)) {
#'   as_polars_series(blob::as_blob(c(NA, "foo", "bar")))
#' }
#'
#' # integer64
#' if (requireNamespace("bit64", quietly = TRUE)) {
#'   as_polars_series(bit64::as.integer64(c(NA, "9223372036854775807")))
#' }
#'
#' # clock_naive_time
#' if (requireNamespace("clock", quietly = TRUE)) {
#'   as_polars_series(clock::naive_time_parse(c(
#'     NA,
#'     "1900-01-01T12:34:56.123456789",
#'     "2020-01-01T12:34:56.123456789"
#'   ), precision = "nanosecond"))
#' }
#'
#' # clock_duration
#' if (requireNamespace("clock", quietly = TRUE)) {
#'   as_polars_series(clock::duration_nanoseconds(c(NA, 1)))
#' }
#'
#' ## Calendrical durations are treated as chronologically
#' if (requireNamespace("clock", quietly = TRUE)) {
#'   as_polars_series(clock::duration_years(c(NA, 1)))
#' }
#' @export
as_polars_series <- function(x, name = NULL, ...) {
  UseMethod("as_polars_series")
}

#' @rdname as_polars_series
#' @export
as_polars_series.default <- function(x, name = NULL, ...) {
  abort(
    paste0("Unsupported class for `as_polars_series()`: ", toString(class(x))),
    call = parent.frame()
  )
}

#' @rdname as_polars_series
#' @export
as_polars_series.polars_series <- function(x, name = NULL, ...) {
  if (is.null(name)) {
    x
  } else {
    x$rename(name)
  }
}

#' @rdname as_polars_series
#' @export
as_polars_series.polars_data_frame <- function(x, name = NULL, ...) {
  as_polars_df(x, ...)$to_struct(name = name %||% "")
}

#' @rdname as_polars_series
#' @export
as_polars_series.polars_lazy_frame <- as_polars_series.polars_data_frame

# This is only used for showing the special error message.
# So, this method is not documented.
#' @export
as_polars_series.polars_expr <- function(x, name = NULL, ...) {
  abort(
    c(
      "passing polars expression objects to `as_polars_series()` is not supported.",
      i = "You can evaluating the expression with `pl$select()`."
    )
  )
}

#' @rdname as_polars_series
#' @export
as_polars_series.double <- function(x, name = NULL, ...) {
  PlRSeries$new_f64(name %||% "", x) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.integer <- function(x, name = NULL, ...) {
  PlRSeries$new_i32(name %||% "", x) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.character <- function(x, name = NULL, ...) {
  PlRSeries$new_str(name %||% "", x) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.logical <- function(x, name = NULL, ...) {
  PlRSeries$new_bool(name %||% "", x) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.raw <- function(x, name = NULL, ...) {
  PlRSeries$new_single_binary(name %||% "", x) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.factor <- function(x, name = NULL, ...) {
  PlRSeries$new_str(name %||% "", as.character(x))$cast(
    pl$Categorical()$`_dt`,
    strict = TRUE
  ) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.Date <- function(x, name = NULL, ...) {
  PlRSeries$new_i32_from_date(name %||% "", x)$cast(
    pl$Date$`_dt`,
    strict = TRUE
  ) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.POSIXct <- function(x, name = NULL, ...) {
  wrap({
    tzone <- attr(x, "tzone") %||% ""
    name <- name %||% ""

    int_series <- PlRSeries$new_i64_from_numeric_and_multiplier(
      name,
      x,
      1000L,
      "floor"
    )

    if (tzone == "") {
      # TODO: simplify to remove the need for the `wrap()` function
      wrap(int_series)$to_frame()$select(
        pl$col(name)$cast(
          pl$Datetime("ms", "UTC")
        )$dt$convert_time_zone(
          Sys.timezone()
        )$dt$replace_time_zone(
          NULL,
          ambiguous = "raise",
          non_existent = "raise"
        )
      )$to_series()
    } else {
      int_series$cast(
        pl$Datetime("ms", tzone)$`_dt`,
        strict = TRUE
      )
    }
  })
}

#' @rdname as_polars_series
#' @export
as_polars_series.POSIXlt <- function(x, name = NULL, ...) {
  time_zone <- attr(x, "tzone")[1] %||% "UTC"

  if (identical(time_zone, "")) {
    # The document says: `""` marks the current time zone
    time_zone <- Sys.timezone()
  }

  # POSIXlt allows '60s', but pl$datetime doesn't
  second_fixed <- x$sec %% 60
  minute_diff <- x$sec %/% 60

  pl$select(
    pl$datetime(
      year = x$year + 1900L,
      month = x$mon + 1L,
      day = x$mday,
      hour = x$hour,
      minute = x$min,
      second = second_fixed,
      time_zone = time_zone,
      time_unit = "ns",
      ambiguous = pl$when(x$isdst == 0)$then(pl$lit("latest"))$otherwise(pl$lit("earliest"))
    )$alias(name %||% "") +
      pl$duration(
        minutes = minute_diff,
        nanoseconds = (x$sec - floor(x$sec)) * 1e9
      )
  )$to_series()
}

#' @rdname as_polars_series
#' @export
as_polars_series.difftime <- function(x, name = NULL, ...) {
  # fmt: skip
  mul_value <- switch(attr(x, "units"),
    "secs" = 1000L,
    "mins" = 60000L,
    "hours" = 3600000L,
    "days" = 86400000L,
    "weeks" = 604800000L,
    abort("Unsupported `units` attribute of the difftime object.")
  )

  PlRSeries$new_i64_from_numeric_and_multiplier(
    name %||% "",
    x,
    mul_value,
    "round"
  )$cast(pl$Duration("ms")$`_dt`, strict = TRUE) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.numeric_version <- function(x, name = NULL, ...) {
  wrap({
    if (length(x) == 0L) {
      # Because if the length is 0, new_series_list will return a List(Null) type
      PlRSeries$new_null(name %||% "", 0L)$cast(pl$List(pl$Int32)$`_dt`, TRUE)
    } else {
      unclass(x) |>
        lapply(\(item) PlRSeries$new_i32("", item)) |>
        PlRSeries$new_series_list(name %||% "", values = _, strict = TRUE)
    }
  })
}

#' @rdname as_polars_series
#' @export
as_polars_series.hms <- function(x, name = NULL, ...) {
  wrap({
    if (suppressWarnings(max(x, na.rm = TRUE) >= 86400.0 || min(x, na.rm = TRUE) < 0.0)) {
      abort(c(
        "Conversion from `hms` vectors to polars series containing values greater than 24-oclocks or less than 0-oclocks is not supported.",
        i = "If you want to treat the vector as `difftime`, use `vctrs::vec_cast(x, difftime(0, 0))` before converting to a polars series."
      ))
    }

    PlRSeries$new_i64_from_numeric_and_multiplier(
      name %||% "",
      x,
      1000000000L,
      "floor"
    )$cast(pl$Time$`_dt`, strict = TRUE) |>
      wrap()
  })
}

#' @rdname as_polars_series
#' @export
as_polars_series.blob <- function(x, name = NULL, ...) {
  PlRSeries$new_binary(name %||% "", x) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.array <- function(x, name = NULL, ...) {
  dims <- dim(x) |>
    rev()
  NextMethod()$reshape(dims)
}

#' @rdname as_polars_series
#' @export
as_polars_series.NULL <- function(x, name = NULL, ...) {
  wrap({
    if (missing(x)) {
      abort("The `x` argument of `as_polars_series()` can't be missing")
    }
    PlRSeries$new_null(name %||% "", 0L)
  })
}

# TODO: move the infer supertype logic on the Rust side to `infer_polars_dtype()`
#' @rdname as_polars_series
#' @export
as_polars_series.list <- function(x, name = NULL, ..., strict = FALSE) {
  series_list <- lapply(x, \(child) {
    if (is.null(child)) {
      NULL
    } else {
      as_polars_series(child, ..., strict = strict)$`_s`
    }
  })

  PlRSeries$new_series_list(name %||% "", series_list, strict = strict) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.AsIs <- function(x, name = NULL, ...) {
  class(x) <- setdiff(class(x), "AsIs")
  as_polars_series(x, name = name, ...)
}

#' @rdname as_polars_series
#' @export
as_polars_series.data.frame <- as_polars_series.polars_data_frame

#' @rdname as_polars_series
#' @export
as_polars_series.nanoarrow_array_stream <- function(x, name = NULL, ...) {
  wrap({
    plrseries <- PlRSeries$from_arrow_c_stream(x)
    if (is.null(name)) {
      plrseries
    } else {
      plrseries$rename(name)
    }
  })
}

#' @rdname as_polars_series
#' @export
as_polars_series.nanoarrow_array <- function(x, name = NULL, ...) {
  nanoarrow::as_nanoarrow_array_stream(x) |>
    as_polars_series(name = name, ...)
}

#' @rdname as_polars_series
#' @export
as_polars_series.integer64 <- function(x, name = NULL, ...) {
  PlRSeries$new_i64(name %||% "", x) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.ITime <- function(x, name = NULL, ...) {
  PlRSeries$new_i64_from_numeric_and_multiplier(
    name %||% "",
    x,
    1000000000L,
    "floor"
  )$cast(pl$Time$`_dt`, strict = TRUE) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.vctrs_unspecified <- function(x, name = NULL, ...) {
  PlRSeries$new_null(name %||% "", length(x)) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.vctrs_rcrd <- function(x, name = NULL, ...) {
  internal_data <- vctrs::fields(x) |>
    lapply(\(field_name) {
      vctrs::field(x, field_name) |>
        as_polars_series(name = field_name, ...)
    })

  as_polars_df(internal_data)$to_struct(name = name %||% "")
}

#' @rdname as_polars_series
#' @export
as_polars_series.clock_time_point <- function(x, name = NULL, ...) {
  precision <- clock::time_point_precision(x)

  # fmt: skip
  time_unit <- switch(precision,
    nanosecond = "ns",
    microsecond = "us",
    "ms"
  )

  PlRSeries$new_i64_from_clock_pair(
    name %||% "",
    vctrs::field(x, "lower"),
    vctrs::field(x, "upper"),
    precision
  )$cast(
    PlRDataType$new_datetime(time_unit, NULL),
    strict = TRUE
  ) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.clock_sys_time <- function(x, name = NULL, ...) {
  as_polars_series.clock_time_point(x, name = name, ...)$dt$convert_time_zone("UTC")
}

#' @rdname as_polars_series
#' @export
as_polars_series.clock_zoned_time <- function(x, name = NULL, ...) {
  time_zone <- clock::zoned_time_zone(x)
  precision <- clock::zoned_time_precision(x)

  if (isTRUE(time_zone == "")) {
    # https://github.com/r-lib/clock/issues/366
    time_zone <- Sys.timezone()
  }

  # fmt: skip
  time_unit <- switch(precision,
    nanosecond = "ns",
    microsecond = "us",
    "ms"
  )

  PlRSeries$new_i64_from_clock_pair(
    name %||% "",
    vctrs::field(x, "lower"),
    vctrs::field(x, "upper"),
    precision
  )$cast(
    PlRDataType$new_datetime(time_unit, time_zone),
    strict = TRUE
  ) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.clock_duration <- function(x, name = NULL, ...) {
  precision <- clock::duration_precision(x)

  # fmt: skip
  time_unit <- switch(precision,
    nanosecond = "ns",
    microsecond = "us",
    "ms"
  )

  PlRSeries$new_i64_from_clock_pair(
    name %||% "",
    vctrs::field(x, "lower"),
    vctrs::field(x, "upper"),
    precision
  )$cast(
    PlRDataType$new_duration(time_unit),
    strict = TRUE
  ) |>
    wrap()
}
