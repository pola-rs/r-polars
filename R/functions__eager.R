#' Concat polars objects
#' @name pl_concat
#' @param l list of DataFrame, or Series, LazyFrame or Expr
#' @param rechunk perform a rechunk at last
#' @param how choice of bind direction "vertical"(rbind) "horizontal"(cbind) "diagonal" diagonally
#' @param parallel Boolean default TRUE, only used for LazyFrames
#' @param to_supertypes Boolean default TRUE, cast columns shared super types, if any.
#'
#' @details
#' Categorical columns/Series must have been constructed while global string cache enabled
#' [`pl$enable_string_cache()`][pl_enable_string_cache]
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
#' # diagonal
#' pl$concat(l_hor, how = "diagonal")
pl$concat = function(
    ..., # list of DataFrames or Series or lazyFrames or expr
    rechunk = TRUE,
    how = c("vertical", "horizontal", "diagonal"), # , "vertical_relaxed","diangonal_relaxed"),
    parallel = TRUE,
    # eager = FALSE,
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
      diag_concat_lf(l, rechunk, parallel)
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
      hor_concat_df(l)
    },

    # TODO implement Series, Expr, Lazy etc
    or_else = Err_plain("internal error:", how, "not handled")
  )

  # convert back from lazy if eager
  and_then(Result_out, \(x) {
    pcase(
      inherits(x, "DataFrame") && !eager, Err_plain("internal logical error in pl$concat()"),
      inherits(x, "LazyFrame") && eager, Ok(x$collect()),
      or_else = Ok(x)
    )
  }) |> unwrap(
    "in pl$concat()"
  )
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
