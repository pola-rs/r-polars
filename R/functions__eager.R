#' Concat polars objects
#' @name pl_concat
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
pl$concat = function(
    ...,
    how = c(
      "vertical", "vertical_relaxed", "horizontal",
      "diagonal", "diagonal_relaxed"
    ),
    rechunk = TRUE,
    parallel = TRUE) {
  l = unpack_list(..., skip_classes = "data.frame")

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


#' New date range
#' @name pl_date_range
#' @param start POSIXt or Date preferably with time_zone or double or integer
#' @param end POSIXt or Date preferably with time_zone or double or integer. If
#' `end` and `interval` are missing, then a single datetime is constructed.
#' @param interval String, a Polars `duration` or R [difftime()]. Can be missing
#' if `end` is missing also.
#' @param eager If `FALSE` (default), return an `Expr`. Otherwise, returns a
#' `Series`.
#' @param closed One of `"both"` (default), `"left"`, `"none"` or `"right"`.
#' @param time_unit String (`"ns"`, `"us"`, `"ms"`) or integer.
#' @param time_zone String describing a timezone. If `NULL` (default), `"GMT` is
#' used.
#' @param explode If `TRUE` (default), all created ranges will be "unlisted"
#' into a column. Otherwise, output will be a list of ranges.
#'
#' @details
#' If param `time_zone` is not defined the Series will have no time zone.
#'
#' Note that R POSIXt without defined timezones (tzone/tz), so-called naive
#' datetimes, are counter intuitive in R. It is recommended to always set the
#' timezone of start and end. If not output will vary between local machine
#' timezone, R and polars.
#'
#' In R/r-polars it is perfectly fine to mix timezones of params `time_zone`,
#' `start` and `end`.
#'
#' @return A datetime
#'
#' @examples
#' # All in GMT, straight forward, no mental confusion
#' s_gmt = pl$date_range(
#'   as.POSIXct("2022-01-01", tz = "GMT"),
#'   as.POSIXct("2022-01-02", tz = "GMT"),
#'   interval = "6h", time_unit = "ms", time_zone = "GMT"
#' )
#' s_gmt
#' s_gmt$to_r()
#'
#' # polars uses "GMT" if time_zone = NULL
#' s_null = pl$date_range(
#'   as.POSIXct("2022-01-01", tz = "GMT"),
#'   as.POSIXct("2022-01-02", tz = "GMT"),
#'   interval = "6h", time_unit = "ms", time_zone = NULL
#' )
#' # back to R POSIXct. R prints non tzone tagged POSIXct in local timezone
#' s_null$to_r()
#'
#' # use of ISOdate
#' t1 = ISOdate(2022, 1, 1, 0) # preset GMT
#' t2 = ISOdate(2022, 1, 2, 0) # preset GMT
#' pl$date_range(t1, t2, interval = "4h", time_unit = "ms", time_zone = "GMT")$to_r()
#'
pl$date_range = function(
    start,
    end,
    interval,
    eager = FALSE,
    closed = "both",
    time_unit = "us",
    time_zone = NULL,
    explode = TRUE) {
  if (missing(end)) {
    end = start
    interval = "1h"
  }

  f_eager_eval = \(lit) {
    if (isTRUE(eager)) {
      result(lit$to_series())
    } else {
      Ok(lit)
    }
  }

  start = cast_naive_value_to_datetime_expr(start)
  end = cast_naive_value_to_datetime_expr(end)

  r_date_range_lazy(start, end, interval, closed, time_unit, time_zone, explode) |>
    and_then(f_eager_eval) |>
    unwrap("in pl$date_range()")
}


# date range support functions
cast_naive_value_to_datetime_expr = function(x, time_unit = "ms", time_zone = NULL) {
  if (!inherits(x, c("numeric", "integer", "integer64"))) {
    x
  } else {
    pl$lit(x)$cast(pl$Datetime(time_unit, time_zone))
  }
}

# to pl_duration from other R types, add more if need
as_pl_duration = function(x) {
  pcase(
    is_string(x), x,
    inherits(x, "difftime"), difftime_to_pl_duration(x),
    # add more types here
    or_else = stop("unknown conversion into pl_duration from: ", x)
  )
}

# impl this converison
difftime_to_pl_duration = function(dft) {
  value = as.numeric(dft)
  u = attr(dft, "units")
  unit = pcase(
    !is_string(u), stop("difftime units should be a string not a: ", u),
    u == "secs", "s",
    u == "mins", "m",
    u == "hours", "h",
    u == "days", "d",
    u == "weeks", "w",
    u == "years", "y",
    or_else = stop("unknown difftime units: ", u)
  )
  paste0(value, unit)
}



#' Polars raw list
#' @description
#' Create an "rpolars_raw_list", which is an R list where all elements must be
#' an R raw or `NULL`.
#' @name pl_raw_list
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
#' pl$Series(raw_list)
#' pl$lit(raw_list)
#'
#' # convert polars bianry Series to rpolars_raw_list
#' pl$Series(raw_list)$to_r()
#'
#'
#' # NB: a plain list of raws yield a polars Series of DateType [list[Binary]]
#' # which is not the same
#' pl$Series(list(raw(1), raw(2)))
#'
#' # to regular list, use as.list or unclass
#' as.list(raw_list)
pl$raw_list = function(...) {
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
