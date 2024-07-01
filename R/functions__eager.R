#' Concat polars objects
#' @param ... Either individual unpacked args or args wrapped in list(). Args can
#' be eager as DataFrame, Series and R vectors, or lazy as LazyFrame and Expr.
#' The first element determines the output of `$concat()`: if the first element
#' is lazy, a LazyFrame is returned; otherwise, a DataFrame is returned (note
#' that if the first element is eager, all other elements have to be eager to
#' avoid implicit collect).
#' @param how Bind direction. Can be "vertical" (like `rbind()`), "horizontal"
#' (like `cbind()`), or "diagonal". For `"vertical"` and `"diagonal"`, adding
#' the suffix `"_relaxed"` will cast columns to their shared supertypes. For
#' example, if we try to vertically concatenate two columns of types `i32` and
#' `f64`, using `how = "vertical_relaxed"` will cast the column of type `i32`
#' to `f64` beforehand.
#' @param rechunk Perform a rechunk at last.
#' @param parallel Only used for LazyFrames. If `TRUE` (default), lazy
#' computations may be executed in parallel.
#'
#' @details
#' Categorical columns/Series must have been constructed while global string
#' cache enabled. See [`pl$enable_string_cache()`][pl_enable_string_cache].
#'
#'
#' @return DataFrame, Series, LazyFrame or Expr
#'
#' @examples
#' # vertical
#' l_ver = lapply(1:10, function(i) {
#'   l_internal = list(
#'     a = 1:5,
#'     b = letters[1:5]
#'   )
#'   pl$DataFrame(l_internal)
#' })
#' pl$concat(l_ver, how = "vertical")
#'
#' # horizontal
#' l_hor = lapply(1:10, function(i) {
#'   l_internal = list(
#'     1:5,
#'     letters[1:5]
#'   )
#'   names(l_internal) = paste0(c("a", "b"), i)
#'   pl$DataFrame(l_internal)
#' })
#' pl$concat(l_hor, how = "horizontal")
#'
#' # diagonal
#' pl$concat(l_hor, how = "diagonal")
#'
#' # if two columns don't share the same type, concat() will error unless we use
#' # `how = "vertical_relaxed"`:
#' test = pl$DataFrame(x = 1L) # i32
#' test2 = pl$DataFrame(x = 1.0) # f64
#'
#' pl$concat(test, test2, how = "vertical_relaxed")
pl_concat = function(
    ...,
    how = c(
      "vertical", "vertical_relaxed", "horizontal",
      "diagonal", "diagonal_relaxed"
    ),
    rechunk = FALSE,
    parallel = TRUE) {
  l = unpack_list(..., skip_classes = "data.frame", .context = "in pl$concat")

  if (length(l) == 0L) {
    return(NULL)
  }
  how_args = c(
    "vertical", "vertical_relaxed", "horizontal",
    "diagonal", "diagonal_relaxed"
  )
  how = match.arg(how[1L], how_args) |>
    result() |>
    unwrap("in pl$concat()")

  first = l[[1L]]
  eager = !inherits(first, "RPolarsLazyFrame")
  args_modified = names(as.list(sys.call()[-1L]))

  # check not using any mixing of types which could lead to implicit collect
  if (eager) {
    for (i in seq_along(l)) {
      if (inherits(l[[i]], c("RPolarsLazyFrame", "RPolarsExpr"))) {
        .pr$Err$new()$
          plain("tip: explicitly collect lazy inputs first, e.g. pl$concat(dataframe, lazyframe$collect())")$
          plain("LazyFrame or Expr not allowed if first arg is a DataFrame, to avoid implicit collect")$
          bad_robj(l[[i]])$
          bad_arg(paste("of those to concatenate, number", i)) |>
          Err() |>
          unwrap("in pl$concat()")
      }
    }
  }

  # dispatch on item class and how
  Result_out = pcase(
    how == "vertical" && (inherits(first, "RPolarsSeries") || is.vector(first)),
    {
      if (any(args_modified %in% c("parallel"))) {
        warning(
          "in pl$concat(): argument `parallel` is not used when concatenating Series",
          call. = FALSE
        )
      }
      concat_series(l, rechunk, to_supertypes = FALSE)
    },
    how == "vertical_relaxed" && (inherits(first, "RPolarsSeries") || is.vector(first)),
    {
      if (any(args_modified %in% c("parallel"))) {
        warning(
          "in pl$concat(): argument `parallel` is not used when concatenating Series",
          call. = FALSE
        )
      }
      concat_series(l, rechunk, to_supertypes = TRUE)
    },
    how == "vertical",
    concat_lf(l, rechunk, parallel, to_supertypes = FALSE),
    how == "vertical_relaxed",
    concat_lf(l, rechunk, parallel, to_supertypes = TRUE),
    how == "diagonal",
    concat_lf_diagonal(l, rechunk, parallel, to_supertypes = FALSE),
    how == "diagonal_relaxed",
    concat_lf_diagonal(l, rechunk, parallel, to_supertypes = TRUE),
    how == "horizontal" && !eager,
    {
      Err_plain(
        "how=='horizontal' is not supported for lazy (first element is LazyFrame).",
        "Try e.g. <LazyFrame>$join() to get Lazy join or pl$concat(lf1$collect(), lf2, lf3).",
        "to get a eager horizontal concatenation"
      )
    },
    how == "horizontal",
    {
      if (any(args_modified %in% c("parallel"))) {
        warning(
          "Arguments `parallel`, `rechunk`, and `eager` are not used when how=='horizontal'",
          call. = FALSE
        )
      }
      concat_df_horizontal(l)
    },

    # TODO implement Series, Expr, Lazy etc
    or_else = Err_plain("internal error:", how, "not handled")
  )

  # convert back from lazy if eager
  and_then(Result_out, \(x) {
    pcase(
      # run-time assertion for future changes
      inherits(x, "RPolarsDataFrame") && !eager, Err_plain("internal logical error in pl$concat()"),

      # must collect as in rust side only lazy concat is implemented. Eager inputs are wrapped in
      # lazy and then collected again. This does not mean any user input is collected.
      inherits(x, "RPolarsLazyFrame") && eager, Ok(x$collect()),
      or_else = Ok(x)
    )
  }) |>
    unwrap("in pl$concat()")
}


# TODO: link to the Date type docs
#' Generate a date range
#'
#' If both `start` and `end` are passed as the Date types (not Datetime), and
#' the `interval` granularity is no finer than `"1d"`, the returned range is
#' also of type Date. All other permutations return a Datetime. Note that in a
#' future version of Polars, `pl$date_range()` will always return Date. Please
#' use [`pl$datetime_range()`][pl_datetime_range] if you want Datetime instead.
#'
#' @param start Lower bound of the date range. Something that can be coerced to
#' a Date or a [Datetime][DataType_Datetime] expression. See examples for details.
#' @param end Upper bound of the date range. Something that can be coerced to a
#' Date or a [Datetime][DataType_Datetime] expression. See examples for details.
#' @param interval Interval of the range periods, specified as a [difftime] object
#' or using the Polars duration string language.
#' See the `Polars duration string language` section for details.
#' @param ... Ignored.
#' @param closed Define which sides of the range are closed (inclusive).
#' One of the followings: `"both"` (default), `"left"`, `"right"`, `"none"`.
#' @return An [Expr][Expr_class] of data type Date or [Datetime][DataType_Datetime]
#'
#' @inheritSection polars_duration_string  Polars duration string language
#'
#' @seealso [`pl$date_ranges()`][pl_date_ranges] to create a simple Series of data
#' type list(Date) based on column values.
#'
#' @examples
#' # Using Polars duration string to specify the interval:
#' pl$date_range(as.Date("2022-01-01"), as.Date("2022-03-01"), "1mo") |>
#'   as_polars_series("date")
#'
#' # Using `difftime` object to specify the interval:
#' pl$date_range(
#'   as.Date("1985-01-01"),
#'   as.Date("1985-01-10"),
#'   as.difftime(2, units = "days")
#' ) |>
#'   as_polars_series("date")
pl_date_range = function(
    start,
    end,
    interval = "1d",
    ...,
    closed = "both") {
  interval = parse_as_polars_duration_string(interval)
  date_range(start, end, interval, closed) |>
    unwrap("in pl$date_range():")
}

# TODO: link to the Date type docs
#' Generate a list containing a date range
#'
#' If both `start` and `end` are passed as the Date types (not Datetime), and
#' the `interval` granularity is no finer than `"1d"`, the returned range is
#' also of type Date. All other permutations return a Datetime. Note that in a
#' future version of Polars, `pl$date_ranges()` will always return Date. Please
#' use [`pl$datetime_ranges()`][pl_datetime_ranges] if you want Datetime instead.
#'
#' @inheritParams pl_date_range
#' @inheritSection polars_duration_string  Polars duration string language
#'
#' @return An [Expr][Expr_class] of data type List(Date) or
#' List([Datetime][DataType_Datetime])
#'
#' @seealso [`pl$date_range()`][pl_date_range] to create a simple Series of data
#' type Date.
#'
#' @examples
#' df = pl$DataFrame(
#'   start = as.Date(c("2022-01-01", "2022-01-02", NA)),
#'   end = as.Date("2022-01-03")
#' )
#'
#' df$with_columns(
#'   date_range = pl$date_ranges("start", "end"),
#'   date_range_cr = pl$date_ranges("start", "end", closed = "right")
#' )
#'
#' # provide a custom "end" value
#' df$with_columns(
#'   date_range_lit = pl$date_ranges("start", pl$lit(as.Date("2022-01-02")))
#' )
pl_date_ranges = function(
    start,
    end,
    interval = "1d",
    ...,
    closed = "both") {
  interval = parse_as_polars_duration_string(interval)
  date_ranges(start, end, interval, closed) |>
    unwrap("in pl$date_ranges():")
}


#' Generate a datetime range
#'
#' @inheritParams pl_date_range
#' @inheritSection polars_duration_string  Polars duration string language
#'
#' @param time_unit Time unit of the resulting the [Datetime][DataType_Datetime]
#' data type. One of `"ns"`, `"us"`, `"ms"` or `NULL`
#' @param time_zone Time zone of the resulting [Datetime][DataType_Datetime]
#' data type.
#'
#' @return An [Expr][Expr_class] of data type [Datetime][DataType_Datetime]
#'
#' @seealso [`pl$datetime_ranges()`][pl_datetime_ranges] to create a simple
#' Series of data type list(Datetime) based on column values.
#'
#' @examples
#' # Using Polars duration string to specify the interval:
#' pl$datetime_range(as.Date("2022-01-01"), as.Date("2022-03-01"), "1mo") |>
#'   as_polars_series("datetime")
#'
#' # Using `difftime` object to specify the interval:
#' pl$datetime_range(
#'   as.Date("1985-01-01"),
#'   as.Date("1985-01-10"),
#'   as.difftime(1, units = "days") + as.difftime(12, units = "hours")
#' ) |>
#'   as_polars_series("datetime")
#'
#' # Specifying a time zone:
#' pl$datetime_range(
#'   as.Date("2022-01-01"),
#'   as.Date("2022-03-01"),
#'   "1mo",
#'   time_zone = "America/New_York"
#' ) |>
#'   as_polars_series("datetime")
pl_datetime_range = function(
    start,
    end,
    interval = "1d",
    ...,
    closed = "both",
    time_unit = NULL,
    time_zone = NULL) {
  interval = parse_as_polars_duration_string(interval)
  datetime_range(start, end, interval, closed, time_unit, time_zone) |>
    unwrap("in pl$datetime_range():")
}


#' Generate a list containing a datetime range
#'
#' @inheritParams pl_datetime_range
#' @inheritSection polars_duration_string  Polars duration string language
#'
#' @return An [Expr][Expr_class] of data type list([Datetime][DataType_Datetime])
#'
#' @seealso [`pl$datetime_range()`][pl_datetime_range] to create a simple Series
#' of data type Datetime.
#'
#' @examples
#' df = pl$DataFrame(
#'   start = as.POSIXct(c("2022-01-01 10:00", "2022-01-01 11:00", NA)),
#'   end = as.POSIXct("2022-01-01 12:00")
#' )
#'
#' df$with_columns(
#'   dt_range = pl$datetime_ranges("start", "end", interval = "1h"),
#'   dt_range_cr = pl$datetime_ranges("start", "end", closed = "right", interval = "1h")
#' )
#'
#' # provide a custom "end" value
#' df$with_columns(
#'   dt_range_lit = pl$datetime_ranges(
#'     "start", pl$lit(as.POSIXct("2022-01-01 11:00")),
#'     interval = "1h"
#'   )
#' )
pl_datetime_ranges = function(
    start,
    end,
    interval = "1d",
    ...,
    closed = "both",
    time_unit = NULL,
    time_zone = NULL) {
  interval = parse_as_polars_duration_string(interval)
  datetime_ranges(start, end, interval, closed, time_unit, time_zone) |>
    unwrap("in pl$datetimes_ranges():")
}



#' Polars raw list
#' @description
#' Create an "rpolars_raw_list", which is an R list where all elements must be
#' an R raw or `NULL`.
#' @param ... Elements
#' @details
#' In R, raw can contain a binary sequence of bytes, and the length is the number
#' of bytes. In polars a Series of DataType [Binary][pl_dtypes] is more like a
#' vector of vectors of bytes where missing values are allowed, similar to how
#' `NA`s can be present in vectors.
#'
#' To ensure correct round-trip conversion, r-polars uses an R list where any
#' elements must be raw or `NULL` (encoded as missing), and the S3 class is
#' `c("rpolars_raw_list","list")`.
#'
#' @return An R list where any elements must be raw, and the S3 class is
#' `c("rpolars_raw_list","list")`.
#' @keywords functions
#'
#' @examples
#' # create a rpolars_raw_list
#' raw_list = pl$raw_list(raw(1), raw(3), charToRaw("alice"), NULL)
#'
#' # pass it to Series or lit
#' pl$Series(values = raw_list)
#' pl$lit(raw_list)
#'
#' # convert polars bianry Series to rpolars_raw_list
#' pl$Series(values = raw_list)$to_r()
#'
#'
#' # NB: a plain list of raws yield a polars Series of DateType [list[Binary]]
#' # which is not the same
#' pl$Series(values = list(raw(1), raw(2)))
#'
#' # to regular list, use as.list or unclass
#' as.list(raw_list)
pl_raw_list = function(...) {
  l = list2(...)
  if (any(!sapply(l, is.raw) & !sapply(l, is.null))) {
    Err_plain("some elements where not raw or NULL") |>
      unwrap("in pl$raw_list():")
  }
  class(l) = c("rpolars_raw_list", "list")
  l
}


#' Subset polars raw list
#' @rdname pl_raw_list
#' @param x A `rpolars_raw_list` object created with `pl$raw_list()`
#' @param index Elements to select
#' @export
#' @examples
#' # subsetting preserves class
#' pl$raw_list(NULL, raw(2), raw(3))[1:2]
"[.rpolars_raw_list" = function(x, index) {
  x = unclass(x)[index]
  class(x) = c("rpolars_raw_list", "list")
  x
}

#' Coerce polars raw list to R list
#' @rdname pl_raw_list
#' @param x A `rpolars_raw_list` object created with `pl$raw_list()`
#' @export
#' @examples
#' # to regular list, use as.list or unclass
#' pl$raw_list(NULL, raw(2), raw(3)) |> as.list()
"as.list.rpolars_raw_list" = function(x, ...) {
  unclass(x)
}
