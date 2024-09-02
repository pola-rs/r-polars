# TODO: link to data type docs
# TODO: link to the type mapping vignette
#' Create a Polars Series from an R object
#'
#' The [as_polars_series()] function creates a [polars Series][Series] from various R objects.
#' The Data Type of the Series is determined by the class of the input object.
#'
#' The default method of [as_polars_series()] throws an error,
#' so we need to define methods for the classes we want to support.
#' @param x An R object.
#' @param name A single string or `NULL`. Name of the Series.
#' Will be used as a column name when used in a [polars DataFrame][DataFrame].
#' When not specified, name is set to an empty string.
#' @param ... Additional arguments passed to the methods.
#' @return A [polars Series][Series]
#' @seealso
#' - [`<Series>$to_r_vector()`][series__to_r_vector]: Export the Series as an R vector.
#' @examples
#' # double
#' as_polars_series(c(1, 2))
#'
#' # integer
#' as_polars_series(1:2)
#'
#' # character
#' as_polars_series(c("foo", "bar"))
#'
#' # logical
#' as_polars_series(c(TRUE, FALSE))
#'
#' # raw
#' as_polars_series(charToRaw("foo"))
#'
#' # factor
#' as_polars_series(factor(c("a", "b")))
#'
#' # Date
#' as_polars_series(as.Date("2021-01-01"))
#'
#' # POSIXct with timezone
#' as_polars_series(as.POSIXct("2021-01-01 00:00:00", "UTC"))
#'
#' # POSIXct without timezone
#' as_polars_series(as.POSIXct("2021-01-01 00:00:00"))
#'
#' # difftime
#' as_polars_series(as.difftime(1, units = "days"))
#'
#' # NULL
#' as_polars_series(NULL)
#'
#' # list
#' as_polars_series(list(1, "foo", TRUE))
#'
#' # data.frame
#' as_polars_series(data.frame(x = 1:2, y = c("foo", "bar")))
#'
#' # hms
#' if (requireNamespace("hms", quietly = TRUE)) {
#'   as_polars_series(hms::as_hms("01:00:00"))
#' }
#'
#' # blob
#' if (requireNamespace("blob", quietly = TRUE)) {
#'   as_polars_series(blob::as_blob(c("foo", "bar")))
#' }
#'
#' # integer64
#' if (requireNamespace("bit64", quietly = TRUE)) {
#'   as_polars_series(bit64::as.integer64(c(NA, "9223372036854775807")))
#' }
#'
#' # clock naive time
#' if (requireNamespace("clock", quietly = TRUE)) {
#'   as_polars_series(clock::naive_time_parse(c(
#'     NA,
#'     "1900-01-01T12:34:56.123456789",
#'     "2020-01-01T12:34:56.123456789"
#'   ), precision = "nanosecond"))
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
  PlRSeries$new_f64(name %||% "", x)$cast(
    pl$Date$`_dt`,
    strict = TRUE
  ) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.POSIXct <- function(x, name = NULL, ...) {
  tzone <- attr(x, "tzone")
  name <- name %||% ""

  int_series <- PlRSeries$new_f64(name, x)$mul(
    PlRSeries$new_f64("", 1000)
  )$cast(pl$Int64$`_dt`, strict = TRUE)

  if (tzone == "") {
    # TODO: simplify to remove the need for the `wrap()` function
    wrap(int_series)$to_frame()$select(
      pl$col(name)$cast(
        pl$Datetime("ms", "UTC")
      )$dt$convert_time_zone(
        Sys.timezone()
      )$dt$replace_time_zone(
        NULL,
        ambiguous = "raise", non_existent = "raise"
      )
    )$to_series() |>
      wrap()
  } else {
    int_series$cast(
      pl$Datetime("ms", tzone)$`_dt`,
      strict = TRUE
    ) |>
      wrap()
  }
}

#' @rdname as_polars_series
#' @export
as_polars_series.difftime <- function(x, name = NULL, ...) {
  mul_value <- switch(attr(x, "units"),
    "secs" = 1000L,
    "mins" = 60L * 1000L,
    "hours" = 60L * 60L * 1000L,
    "days" = 24L * 60L * 60L * 1000L,
    "weeks" = 7L * 24L * 60L * 60L * 1000L,
    abort("Unsupported `units` attribute of the difftime object.")
  )

  PlRSeries$new_f64(name %||% "", x)$mul(
    PlRSeries$new_i32("", mul_value)
  )$cast(
    pl$Duration("ms")$`_dt`,
    strict = TRUE
  ) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.hms <- function(x, name = NULL, ...) {
  PlRSeries$new_f64(name %||% "", x)$mul(
    PlRSeries$new_i32("", 1000000000L)
  )$cast(
    pl$Time$`_dt`,
    strict = TRUE
  ) |>
    wrap()
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
  PlRSeries$new_empty(name %||% "") |>
    wrap()
}

# TODO: strict option to raise error if all elements are not the same class
#' @rdname as_polars_series
#' @export
as_polars_series.list <- function(x, name = NULL, ...) {
  series_list <- lapply(x, \(child) {
    if (is.null(child)) {
      NULL
    } else {
      as_polars_series(child)$`_s`
    }
  })

  PlRSeries$new_series_list(name %||% "", series_list) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.AsIs <- function(x, name = NULL, ...) {
  class(x) <- setdiff(class(x), "AsIs")
  as_polars_series(x, name = name)
}

#' @rdname as_polars_series
#' @export
as_polars_series.data.frame <- function(x, name = NULL, ...) {
  as_polars_df(x)$to_struct(name = name %||% "")
}

#' @rdname as_polars_series
#' @export
as_polars_series.integer64 <- function(x, name = NULL, ...) {
  PlRSeries$new_i64(name %||% "", x) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.vctrs_rcrd <- function(x, name = NULL, ...) {
  field_names <- vctrs::fields(x)
  internal_data <- field_names |>
    lapply(\(field_name) {
      vctrs::field(x, field_name) |>
        as_polars_series(name = field_name)
    })

  as_polars_df(internal_data)$to_struct(name = name %||% "")
}

#' @rdname as_polars_series
#' @export
as_polars_series.clock_time_point <- function(x, name = NULL, ...) {
  precision <- clock::time_point_precision(x)

  # https://github.com/r-lib/clock/blob/7bc03674f56bf1d4f850b0b1ab8d7d924a85e34a/src/time-point.cpp#L25-L40
  time_unit <- switch(precision,
    nanosecond = "ns",
    microsecond = "us",
    "ms" # millisecond, second, minute, hour, day
  )

  left <- vctrs::field(x, "lower")
  right <- vctrs::field(x, "upper")

  PlRSeries$new_i64_from_clock_pair(
    name %||% "",
    left,
    right,
    precision
  )$cast(
    pl$Datetime(time_unit)$`_dt`,
    strict = TRUE
  ) |>
    wrap()
}

#' @rdname as_polars_series
#' @export
as_polars_series.clock_sys_time = function(x, name = NULL, ...) {
  as_polars_series.clock_time_point(x, name = name, ...)$dt$replace_time_zone("UTC")
}

#' @rdname as_polars_series
#' @export
as_polars_series.clock_zoned_time <- function(x, name = NULL, ...) {
  time_zone <- clock::zoned_time_zone(x)

  if (isTRUE(time_zone == "")) {
    # https://github.com/r-lib/clock/issues/366
    time_zone <- Sys.timezone()
  }

  as_polars_series.clock_time_point(
    clock::as_naive_time(x),
    name = name,
    ...
  )$dt$replace_time_zone(time_zone)
}
