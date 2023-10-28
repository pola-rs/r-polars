#' Concat polars objects
#' @name pl_concat
#' @param ... Either individual unpacked args or args wrapped in list(). Args can
#' be eager as DataFrame, Series and R vectors, or lazy as LazyFrame and Expr.
#' The first element determines the output of `$concat()`: if the first element
#' is lazy, a LazyFrame is returned; otherwise, a DataFrame is returned (note
#' that if the first element is eager, all other elements have to be eager to
#' avoid implicit collect).
#' @param rechunk Perform a rechunk at last.
#' @param how Bind direction. Can be "vertical" (like `rbind()`), "horizontal"
#' (like `cbind()`), or "diagonal".
#' @param parallel Only used for LazyFrames. If `TRUE` (default), lazy
#' computations may be executed in parallel.
#' @param to_supertypes If `TRUE` (default), cast columns shared super types, if
#' any. For example, if we try to vertically concatenate two columns of types `i32`
#' and `f64`, the column of type `i32` will be cast to `f64` beforehand. This
#' argument is equivalent to the "_relaxed" operations in Python polars.
#'
#' @details
#' Categorical columns/Series must have been constructed while global string
#' cache enabled. See [`pl$enable_string_cache()`][pl_enable_string_cache].
#'
#'
#' @return DataFrame, or Series, LazyFrame or Expr
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
#' # `to_supertypes = TRUE`:
#' test = pl$DataFrame(x = 1L) # i32
#' test2 = pl$DataFrame(x = 1.0) # f64
#'
#' pl$concat(test, test2, to_supertypes = TRUE)
pl$concat = function(
    ..., # list of DataFrames or Series or lazyFrames or expr
    rechunk = TRUE,
    how = c("vertical", "horizontal", "diagonal"),
    parallel = TRUE,
    to_supertypes = FALSE) {
  # unpack arg list
  l = unpack_list(..., skip_classes = "data.frame")

  # nothing becomes NULL
  if (length(l) == 0L) {
    return(NULL)
  }

  ## Check inputs
  how_args = c("vertical", "horizontal", "diagonal") # , "vertical_relaxed", "diangonal_relaxed")

  how = match.arg(how[1L], how_args) |>
    result() |>
    unwrap("in pl$concat()")

  first = l[[1L]]
  eager = !inherits(first, "LazyFrame")
  args_modified = names(as.list(sys.call()[-1L]))

  # check not using any mixing of types which could lead to implicit collect
  if (eager) {
    for (i in seq_along(l)) {
      if (inherits(l[[i]], c("LazyFrame", "Expr"))) {
        .pr$RPolarsErr$new()$
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
    how == "vertical" && (inherits(first, "Series") || is.vector(first)),
    {
      if (any(args_modified %in% c("parallel"))) {
        warning(
          "in pl$concat(): argument `parallel` is not used when concatenating Series",
          call. = FALSE
        )
      }
      concat_series(l, rechunk, to_supertypes)
    },
    how == "vertical",
    concat_lf(l, rechunk, parallel, to_supertypes),
    how == "diagonal",
    {
      if (any(args_modified %in% c("to_supertypes"))) {
        warning(
          "Argument `to_supertypes` is not used when how=='diagonal'",
          call. = FALSE
        )
      }
      concat_lf_diagonal(l, rechunk, parallel)
    },
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
      if (any(args_modified %in% c("parallel", "to_supertypes"))) {
        warning(
          "Arguments `parallel`, `rechunk`, `eager` and `to_supertypes` are not used when how=='horizontal'",
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
      inherits(x, "DataFrame") && !eager, Err_plain("internal logical error in pl$concat()"),

      # must collect as in rust side only lazy concat is implemented. Eager inputs are wrapped in
      # lazy and then collected again. This does not mean any user input is collected.
      inherits(x, "LazyFrame") && eager, Ok(x$collect()),
      or_else = Ok(x)
    )
  }) |>
    unwrap("in pl$concat()")
}


#' new date_range
#' @name pl_date_range
#' @param start POSIXt or Date preferably with time_zone or double or integer
#' @param end POSIXt or Date preferably with time_zone or double or integer. If end is and
#' interval are missing, then single datetime is constructed.
#' @param interval string pl_duration or R difftime. Can be missing if end is missing also.
#' @param eager  bool, if FALSE (default) return `Expr` else evaluate `Expr` to `Series`
#' @param closed option one of 'both'(default), 'left', 'none' or 'right'
#' @param name name of series
#' @param time_unit option string ("ns" "us" "ms") duration of one int64 value on polars side
#' @param time_zone optional string describing a timezone.
#' @param explode if TRUE (default) all created ranges will be "unlisted" into on column, if FALSE
#' output will be a list of ranges.
#'
#' @details
#' If param time_zone is not defined the Series will have no time zone.
#'
#' NOTICE: R POSIXt without defined timezones(tzone/tz), so called naive datetimes, are counter
#' intuitive in R. It is recommended to always set the timezone of start and end. If not output will
#' vary between local machine timezone, R and polars.
#'
#' In R/r-polars it is perfectly fine to mix timezones of params time_zone, start and end.
#'
#'
#' @return a datetime
#' @keywords functions ExprDT
#'
#' @examples
#'
#' # All in GMT, straight forward, no mental confusion
#' s_gmt = pl$date_range(
#'   as.POSIXct("2022-01-01", tz = "GMT"),
#'   as.POSIXct("2022-01-02", tz = "GMT"),
#'   interval = "6h", time_unit = "ms", time_zone = "GMT"
#' )
#' s_gmt
#' s_gmt$to_r() # printed same way in R and polars becuase tagged with a time_zone/tzone
#'
#' # polars assumes any input in GMT if time_zone = NULL, set GMT on start end to see same print
#' s_null = pl$date_range(
#'   as.POSIXct("2022-01-01", tz = "GMT"),
#'   as.POSIXct("2022-01-02", tz = "GMT"),
#'   interval = "6h", time_unit = "ms", time_zone = NULL
#' )
#' s_null$to_r() # back to R POSIXct. R prints non tzone tagged POSIXct in local timezone.
#'
#'
#' # use of ISOdate
#' t1 = ISOdate(2022, 1, 1, 0) # preset GMT
#' t2 = ISOdate(2022, 1, 2, 0) # preset GMT
#' pl$date_range(t1, t2, interval = "4h", time_unit = "ms", time_zone = "GMT")$to_r()
#'
pl$date_range = function(
    start, # : date | datetime |# for lazy  pli.Expr | str,
    end, # : date | datetime | pli.Expr | str,
    interval, # : str | timedelta,
    eager = FALSE, # : Literal[True],
    closed = "both", # : ClosedInterval = "both",
    name = NULL, # : str | None = None,
    time_unit = "us",
    time_zone = NULL, # : str | None = None
    explode = TRUE) {
  if (missing(end)) {
    end = start
    interval = "1h"
  }

  if (!is.null(name)) warning("arg name is deprecated use $alias() instead")
  name = name %||% ""

  f_eager_eval = \(lit) {
    if (isTRUE(eager)) {
      result(lit$lit_to_s())
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
    or_else = stopf("unknown conversion into pl_duration from: %s", str_string(x))
  )
}

# impl this converison
difftime_to_pl_duration = function(dft) {
  value = as.numeric(dft)
  u = attr(dft, "units")
  unit = pcase(
    !is_string(u), stopf("difftime units should be a string not a: %s", str_string(u)),
    u == "secs", "s",
    u == "mins", "m",
    u == "hours", "h",
    u == "days", "d",
    u == "weeks", "w",
    u == "years", "y",
    or_else = stopf("unknown difftime units: %s", u)
  )
  paste0(value, unit)
}



#' Polars raw list
#' @description
#' create an "rpolars_raw_list", which is an R list where all elements must be an R raw or NULL.
#' @name pl_raw_list
#' @param ... elements
#' @details
#' In R raw can contain a binary sequence of bytes, and the length is the number of bytes.
#' In polars a Series of DataType [Binary][pl_dtypes] is more like a vector of vectors of bytes and missings
#' 'Nulls' is allowed, similar to R NAs in vectors.
#'
#' To ensure correct round-trip conversion r-polars uses an R list where any elements must be
#' raw or NULL(encodes missing), and the S3 class is c("rpolars_raw_list","list").
#'
#' @return an R list where any elements must be raw, and the S3 class is
#' c("rpolars_raw_list","list").
#' @keywords functions
#'
#' @examples
#'
#' # craete a rpolars_raw_list
#' raw_list = pl$raw_list(raw(1), raw(3), charToRaw("alice"), NULL)
#'
#'
#' # pass it to Series or lit
#' pl$Series(raw_list)
#' pl$lit(raw_list)
#'
#' # convert polars bianry Series to rpolars_raw_list
#' pl$Series(raw_list)$to_r()
#'
#'
#' # NB a plain list of raws yield a polars Series of DateType [list[Binary]] which is not the same
#' pl$Series(list(raw(1), raw(2)))
#'
#' # to regular list, use as.list or unclass
#' as.list(raw_list)
#'
pl$raw_list = function(...) {
  l = list2(...)
  if ( any(!sapply(l, is.raw) & !sapply(l, is.null))) {
    Err_plain("some elements where not raw or NULL") |>
      unwrap("in pl$raw_list():")
  }
  class(l) = c("rpolars_raw_list", "list")
  l
}


#' subset polars raw list
#' @rdname pl_raw_list
#' @export
#' @param x rpolars_raw_list list
#' @param index elements to get subset
#' @examples
#' # subsetting preserves class
#' pl$raw_list(NULL, raw(2), raw(3))[1:2]
"[.rpolars_raw_list" = function(x, index) {
  x = unclass(x)[index]
  class(x) = c("rpolars_raw_list", "list")
  x
}

#' coerce polars raw list to list
#' @rdname pl_raw_list
#' @export
#' @details the same as unclass(x)
#' @param x rpolars_raw_list list
#' @examples
#' # to regular list, use as.list or unclass
#' pl$raw_list(NULL, raw(2), raw(3)) |> as.list()
"as.list.rpolars_raw_list" = function(x, ...) {
  unclass(x)
}
