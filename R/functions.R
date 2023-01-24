

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
#' #vertical
#' l_ver = lapply(1:10, function(i) {
#'   l_internal = list(
#'     a = 1:5,
#'     b = letters[1:5]
#'   )
#' pl$DataFrame(l_internal)
#' })
#' pl$concat(l_ver, how="vertical")
#'
#'
#' #horizontal
#' l_hor = lapply(1:10, function(i) {
#'   l_internal = list(
#'     1:5,
#'     letters[1:5]
#'   )
#'   names(l_internal) = paste0(c("a","b"),i)
#'   pl$DataFrame(l_internal)
#' })
#' pl$concat(l_hor, how = "horizontal")
#' #diagonal
#' pl$concat(l_hor, how = "diagonal")
pl$concat = function(
    l, #list of DataFrames or Series or lazyFrames or expr
    rechunk = TRUE,
    how  = c("vertical","horizontal","diagnoal"),
    parallel = TRUE #not used yet
) {

  ## Check inputs
  how = match.arg(how[1L], c("vertical","horizontal","diagonal"))

  # dispatch on item class and how
  first = l[[1L]]
  result = pcase(
    inherits(first,"DataFrame"), {
      vdf = l_to_vdf(l)
      pcase(
        how == "vertical",   concat_df(vdf),
        how == "diagonal",   diag_concat_df(vdf),
        how == "horizontal", hor_concat_df(vdf),
        or_else = stopf("Internal error")
      )
    },

    inherits(first,"Series"), {
      stopf("not implemented Series")
    },

    inherits(first,"Expr"), {
      stopf("not implemented Expr")
    },

    #TODO implement Series, Expr, Lazy etc
    or_else = stopf(paste0("type of first list element: '",class(first),"' is not supported"))
  )

  unwrap(result)
}




#' new date_range
#' @name pl_date_range
#' @param low string or
#' @param high string or
#' @param interval string parsed to duration like "1w" "1week" "2years" "10s"
#' @param ... not used
#' @param lazy  bool
#' @param closed option one of 'both'(default), 'left', 'none' or 'right'
#' @param name name of series
#' @param time_unit option "ns" "us" "ms"
#' @param time_zone optional string describing a timezone. If no time_zone is provided the
#' the tz of low/high input is ignored and the output Series will no have a tz predicate.
#' If time_zone is provided the low/high timezone will be corrected into that tz. If low/high
#' does not have a tz(tzone)-attribute, then local System time is assumed.
#'
#' @return a datetime
#' @keywords functions ExprDT
#'
#' @examples
#' pl$date_range(
#'   as.POSIXct("2022-01-01",tz = "GMT"),
#'   as.POSIXct("2022-01-02",tz = "GMT"),
#'   interval = "2h", time_unit = "ms", time_zone = "GMT"
#' )
pl$date_range = function(
    low,      #: date | datetime |# for lazy  pli.Expr | str,
    high,     #: date | datetime | pli.Expr | str,
    interval, #: str | timedelta,
    ...,      #*,
    lazy,     #: Literal[True],
    closed    = "both",   #: ClosedInterval = "both",
    name      = "",     #: str | None = None,
    time_unit = "us",
    time_zone = NULL #: str | None = None
) {

  local_timezone = time_zone #%||% attr(low,"tzone") %||% attr(high,"tzone") %||% Sys.timezone()

  #convert to value and unit pair, convert to GMT
  low = time_to_value_unit_tz(low, time_unit, local_timezone)
  high = time_to_value_unit_tz(high, time_unit, local_timezone)

  #eager date_range, create in ms precision and cast to desired precision
  dt_series = unwrap(rpolars:::r_date_range(
    start = convert_time_unit(low, "ms"),
    stop = convert_time_unit(high, "ms"),
    every = as_pl_duration(interval),
    closed = closed,
    name = name,
    tu = "ms",
    tz = time_zone
  ))

  if(time_unit != "ms") {
    dt_series = dt_series$to_lit()$cast(pl$Datetime(tu=time_unit, tz=time_zone))$lit_to_s()
  }

  dt_series
}

#date range support functions

# convert any R time unit into a value (float), time_unit (ns, us, ns) and
# time_zone string
time_to_value_unit_tz = function(x, time_unit, time_zone = NULL) {

  pcase(
    length(x) != 1L, stopf("a timeunit was not of length 1: '%s'",str_string(x)),
    inherits(x,"POSIXt"), {
      v = if (is.null(time_zone)) {
        as.numeric(x)
      } else {
        as.numeric(as.POSIXct(format(x, tz=time_zone),tz="GMT"))
      }
      list(
        v = v,
        u = "s",
        tz = attr(x,"tzone")
      )
    },
    inherits(x,"Date"), list(v = as.numeric(x), u = "d", tz = NULL),
    #TODO consider string as short hand for POSIXct in GMT tz, may conflict with lazy interface
    #add more types here
    or_else = stopf("cannot interpret following as a timepoint: %s",str_string(x))
  )
}

#convert a (time, value, optional-tz)-list to a new value by time_unit
convert_time_unit = function(x, time_unit) {
  if (isTRUE(x$u == time_unit)) {
    return(x$v)
  }
  get_time_factor(time_unit) / get_time_factor(x$u) * x$v
}

#inverse factor lookup table
get_time_factor = function(u) {
  pcase(
    u == "ns", 1000000000,
    u == "us", 1000000,
    u == "ms", 1000,
    u == "s" , 1,
    u == "m", 1/60,
    u == "h", 1/3600,
    u == "d", 1/3600/24,  # 1 day
    u == "w", 1/3600/24/7,
    u == "mo", stopf("cannot accurately use mo"),
    u == "y", stopf("cannot accurately use y"),
    or_else = stopf("failed to recognize timeunit: %s",u)
  )
}

#to pl_duration from other R types, add more if need
as_pl_duration = function(x) {
  pcase(
    is_string(x), x,
    inherits(x, "difftime"), difftime_to_pl_duration(x),
    #add more types here
    or_else = stopf("unknown conversion into pl_duration from: %s",str_string(x))
  )
}

#impl this converison
difftime_to_pl_duration = function(dft) {
  value = as.numeric(dft)
  u = attr(dft,"units")
  unit = pcase(
    !is_string(u), stopf("difftime units should be a string not a: %s",str_string(u)),
    u=="secs", "s",
    u=="mins", "m",
    u=="hours", "h",
    u=="days", "d",
    u=="weeks", "w",
    u=="years", "y",
    or_else = stopf("unknown difftime units: %s",u)
  )
  paste0(value,unit)
}


##this implementation is parked here, it does not seam to match py-polars
## which could be ok if very fancy, however this seem not to useful
#' #' Repeat a series
#' #' @description This expression emulates R rep()
#' #' @name pl_rep
#' #' @param value expr or any valid input to pl$lit (literal)
#' #' This value may be None to fill with nulls.
#' #' @param n  Numeric the number of times to repeat, must be non-negative and finite
#' #' @param rechunk bool default = TRUE, if true memory layout will be rewritten
#' #' @return  Expr
#' #' @aliases pl_rep
#' #' @format functino
#' #' @keywords Expr
#' #' @examples
#' #' pl$select(pl$rep(1:3, n = 5))
#' pl$rep = function(value, n, rechunk = TRUE) {
#'   wrap_e(value)$rep(n, rechunk)
#' }

