#' Concat polars objects
#' @name pl_concat
#' @param l list of DataFrame, or Series, LazyFrame or Expr
#' @param rechunk perform a rechunk at last
#' @param how choice of bind direction "vertical"(rbind) "horizontal"(cbind) "diagnoal" diagonally
#' @param parallel BOOL default TRUE, only used for LazyFrames
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
    l, # list of DataFrames or Series or lazyFrames or expr
    rechunk = TRUE,
    how = c("vertical", "horizontal", "diagnoal"),
    parallel = TRUE # not used yet
    ) {
  ## Check inputs
  how = match.arg(how[1L], c("vertical", "horizontal", "diagonal"))

  # dispatch on item class and how
  first = l[[1L]]
  result = pcase(
    inherits(first, "DataFrame"),
    {
      vdf = l_to_vdf(l)
      pcase(
        how == "vertical",   concat_df(vdf),
        how == "diagonal",   diag_concat_df(vdf),
        how == "horizontal", hor_concat_df(vdf),
        or_else = stopf("Internal error")
      )
    },
    inherits(first, "Series"),
    {
      stopf("not implemented Series")
    },
    inherits(first, "Expr"),
    {
      stopf("not implemented Expr")
    },

    # TODO implement Series, Expr, Lazy etc
    or_else = stopf(paste0("type of first list element: '", class(first), "' is not supported"))
  )

  unwrap(result)
}




#' new date_range
#' @name pl_date_range
#' @param low POSIXt or Date preferably with time_zone or double or integer
#' @param high POSIXt or Date preferably with time_zone or double or integer. If high is and
#' interval are missing, then single datetime is constructed.
#' @param interval string pl_duration or R difftime. Can be missing if high is missing also.
#' @param lazy  bool, if TRUE return expression
#' @param closed option one of 'both'(default), 'left', 'none' or 'right'
#' @param name name of series
#' @param time_unit option string ("ns" "us" "ms") duration of one int64 value on polars side
#' @param time_zone optional string describing a timezone.
#'
#' @details
#' If param time_zone is not defined the Series will have no time zone.
#'
#' NOTICE: R POSIXt without defined timezones(tzone/tz), so called naive datetimes, are counter
#' intuitive in R. It is recommended to always set the timezone of low and high. If not output will
#' vary between local machine timezone, R and polars.
#'
#' In R/r-polars it is perfectly fine to mix timezones of params time_zone, low and high.
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
#' # polars assumes any input in GMT if time_zone = NULL, set GMT on low high to see same print
#' s_null = pl$date_range(
#'   as.POSIXct("2022-01-01", tz = "GMT"),
#'   as.POSIXct("2022-01-02", tz = "GMT"),
#'   interval = "6h", time_unit = "ms", time_zone = NULL
#' )
#' s_null$to_r() # back to R POSIXct. R prints non tzone tagged POSIXct in local timezone.
#'
#'
#' # Any mixing of timezones is fine, just set them all, and it works as expected.
#' t1 = as.POSIXct("2022-01-01", tz = "Etc/GMT+2")
#' t2 = as.POSIXct("2022-01-01 08:00:00", tz = "Etc/GMT-2")
#' s_mix = pl$date_range(low = t1, high = t2, interval = "1h", time_unit = "ms", time_zone = "CET")
#' s_mix
#' s_mix$to_r()
#'
#'
#' # use of ISOdate
#' t1 = ISOdate(2022, 1, 1, 0) # preset GMT
#' t2 = ISOdate(2022, 1, 2, 0) # preset GMT
#' pl$date_range(t1, t2, interval = "4h", time_unit = "ms", time_zone = "GMT")
#'
pl$date_range = function(
    low, # : date | datetime |# for lazy  pli.Expr | str,
    high, # : date | datetime | pli.Expr | str,
    interval, # : str | timedelta,
    lazy = TRUE, # : Literal[True],
    closed = "both", # : ClosedInterval = "both",
    name = NULL, # : str | None = None,
    time_unit = "us",
    time_zone = NULL # : str | None = None
    ) {
  if (missing(high)) {
    high = low
    interval = "1h"
  }

  name = name %||% ""
  interval = as_pl_duration(interval)

  ## TODO if possible let all go through r_date_range_lazy. Seems asking for trouble
  ## input arg low and high can change if lazy or not
  if (
    inherits(low, c("Expr", "character")) ||
      inherits(high, c("Expr", "character")) || isTRUE(lazy)
  ) {
    low = convert_time_unit_for_lazy(low, time_unit, time_zone)
    high = convert_time_unit_for_lazy(high, time_unit, time_zone)
    result = r_date_range_lazy(low, high, interval, closed, time_zone)
    return(unwrap(result, "in pl$date_range():"))
  }

  # convert to list(v, u, tz) pair
  low = time_to_value_unit_tz(low, time_unit, time_zone)
  high = time_to_value_unit_tz(high, time_unit, time_zone)

  # eager date_range, create in ms precision and cast to desired precision
  dt_series = unwrap(polars:::r_date_range(
    start = convert_time_unit(low, "ms"),
    stop = convert_time_unit(high, "ms"),
    every = interval,
    closed = closed,
    name = name,
    tu = "ms",
    tz = time_zone
  ), "in pl$date_range():")

  if (time_unit != "ms") {
    dt_series = dt_series$to_lit()$cast(pl$Datetime(tu = time_unit, tz = time_zone))$lit_to_s()
  }

  dt_series
}


# date range support functions
convert_time_unit_for_lazy = function(x, time_unit, time_zone) {
  # already expr or str referring to column name
  if (inherits(x, c("Expr", "character"))) {
    return(wrap_e(x, str_to_lit = FALSE))
  }

  # interpret as a support R time type, split in to float value, tu and tz
  v_tu_tz = time_to_value_unit_tz(x, time_unit, time_zone)
  v = convert_time_unit(v_tu_tz, "ms")

  # encode first as 'ms' as POSIXct is 's' and i32 can lack range for ns or perhaps us
  expr = pl$lit(v)$cast(pl$Datetime(tu = "ms", tz = time_zone))

  # encode to chosen time_units
  if (time_unit != "ms") expr <- expr$cast(pl$Datetime(tu = time_unit, time_zone))

  expr
}


# convert any R time unit into a value (float), time_unit (ns, us, ns) and
# time_zone string
time_to_value_unit_tz = function(x, time_unit, time_zone = NULL) {
  pcase(
    length(x) != 1L, stopf("a timeunit was not of length 1: '%s'", str_string(x)),
    inherits(x, "POSIXt"), list(
      v = as.numeric(as.POSIXct(format(x, tz = time_zone %||% "GMT"), tz = "GMT")),
      u = "s",
      tz = attr(x, "tzone")
    ),
    inherits(x, "Date"), list(v = as.numeric(x), u = "d", tz = NULL),
    is.numeric(x), list(v = x, u = time_unit, tz = time_zone),

    # TODO consider string as short hand for POSIXct in GMT tz, may conflict with lazy interface
    # add more types here
    or_else = stopf("cannot interpret following type as a timepoint: %s", str_string(x))
  )
}

# convert a (time, value, optional-tz)-list to a new value by time_unit
convert_time_unit = function(x, time_unit) {
  if (isTRUE(x$u == time_unit)) {
    return(x$v)
  }
  get_time_factor(time_unit) / get_time_factor(x$u) * x$v
}

# inverse factor lookup table
get_time_factor = function(u) {
  pcase(
    u == "ms", 1000, # most used
    u == "us", 1000000,
    u == "ns", 1000000000,
    u == "s", 1,
    u == "m", 1 / 60,
    u == "h", 1 / 3600,
    u == "d", 1 / 3600 / 24, # 1 day
    u == "w", 1 / 3600 / 24 / 7,
    u == "mo", stopf("cannot accurately use mo"),
    u == "y", stopf("cannot accurately use y"),
    or_else = stopf("failed to recognize timeunit: %s", u)
  )
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
