# PTime vectors denote n time units since midnight.

# PTime is loosly inspirred by data.table ITime but also allow encoding in s, ms, us, ns
# for s and ms integer32 or float64 is optional. For us and ns flaot64 is mandatory.

# A PTime vector is nothing but either an integer or double vector with class PTime
# and a attribute "tu" setting time unit.


#conversion factor
time_unit_conv_factor = c(
  "s" = 1,
  "ms" = 1E3,
  "us" = 1E6,
  "ns" = 1E9
)


#' Store Time in R
#' @name pl_PTime
#' @include after-wrappers.R
#'
#' @param x an integer or double vector of n epochs since midnight OR a char vector of char times
#' passed to as.POSIXct converted to seconds.
#' @param tu timeunit either "s","ms","us","ns"
#' @param fmt a format string passed to as.POSIXct format via ...
#'
#' @details
#'
#' PTime should probably be replaced with package nanotime or similar.
#'
#' base R is missing encodinging of Time since midnight "s" "ms", "us" and "ns". The latter
#' "ns" is the standard for the polars Time type.
#'
#' Use PTime to convert R doubles and integers and use as input to polars functions which needs a
#' time.
#'
#' Loosely inspired by data.table::ITime which is i32 only. PTime must support polars native
#' timeunit is nanoseconds. The R double(float64) can imitate a i64 ns with full precision within
#' the full range of 24 hours.
#'
#' PTime does not have a time zone and always prints the time as is no matter local machine
#' time zone.
#'
#' An essential difference between R and polars is R prints POSIXct/lt without a timezone in local
#' time. Polars prints Datetime without a timezone label as is (GMT). For POSIXct/lt taged with a
#' timexone(tzone) and Datetime with a timezone(tz) the behavior is the same conversion is
#' intuitive.
#'
#' It appears behavior of R timezones is subject to change a bit in R 4.3.0, see rpolars unit test
#' test-expr_datetime.R/"pl$date_range Date lazy/eager".
#'
#' @return a PTime vector either double or integer, with class "PTime" and attribute "tu" being
#' either "s","ms","us" or "ns"
#' @aliases PTIME
#'
#'
#' @examples
#'
#' #make PTime in all time units
#' pl$PTime(runif(5)*3600*24*1E0, tu = "s")
#' pl$PTime(runif(5)*3600*24*1E3, tu = "ms")
#' pl$PTime(runif(5)*3600*24*1E6, tu = "us")
#' pl$PTime(runif(5)*3600*24*1E9, tu = "ns")
#' pl$PTime("23:59:59")
#'
#'
#' pl$Series(pl$PTime(runif(5)*3600*24*1E0, tu = "s"))
#' pl$lit(pl$PTime("23:59:59"))$lit_to_s()
#'
#' pl$lit(pl$PTime("23:59:59"))$to_r()
pl$PTime = function(x, tu = c("s","ms","us","ns"), fmt = "%H:%M:%S") {

  tu = tu[1]
  if(!is_string(tu) || !tu %in% c("s","ms","us","ns")) {
    stopf("tu must be either 's','ms','us' ,or 'ns', not [%s]",str_string(tu))
  }

  if( is.character(x)) {
    x = as.double(as.POSIXct(x, format = fmt)) - as.double(as.POSIXct("00:00:00", format = fmt))
    x = x * time_unit_conv_factor[tu]
  }



  #type specific conciderations
  type_ok = FALSE
  if(typeof(x)=="double") {
    x = as.double(x)
    type_ok = TRUE
  }
  if(typeof(x)=="integer") {
    if(!tu %in% c("s","ms")) {stopf(
      "only 's' and 'ms' tu is supported for integer, set input x as double to use tu: [%s]", tu
    )}
    x = as.integer(x)
    type_ok = TRUE
  }

  #check type
  if(!type_ok) {
    stopf("type of x is not double or integer, it was [%s]", typeof(x))
  }

  #check boundaries
  if(isTRUE(any(x<0))) {
    stopf("no element of x can be negative")
  }
  x = floor(x)
  limits = c(
    "s"  = 86400,
    "ms" = 86400000,
    "us" = 86400000000,
    "ns" = 86400000000000
  )
  if(isTRUE(any(x>limits[tu]))) {
    stopf("no elements can exceed 24 hours, the limit for tu '%s' is the value %s",tu,limits[tu])
  }

  attr(x,"tu") = tu
  class(x) = "PTime"
  x
}

#' print PTime
#' @param x a PTime vector
#' @param ... not used
#' @return invisible x
#' @exportS3Method
print.PTime = function(x, ...) {
  tu = attr(x,"tu")
  tu_exp = pcase(
    tu == "s", 0,
    tu == "ms", 3,
    tu == "us", 6,
    tu == "ns", 9,
    or_else = stopf("not recognized tu")
  )
  val = unclass(x) / 10^tu_exp
  origin = structure(0, tzone = "GMT", class = c("POSIXct", "POSIXt"))
  fmt = format(as.POSIXct(val,tz="GMT",origin=origin),format="%H:%M:%S")

  if(tu!="s") {
    dgt = formatC((val-floor(val))*10^tu_exp, width = tu_exp, flag=0,big.mark ="_",digits = tu_exp)
    fmt = paste0(fmt,":",dgt,tu)
  }
  cat("PTime [",typeof(x),"]: number of epochs [",tu,"] since midnight\n")
  print(paste0(
    fmt, " val: ",as.character(x)
  ))
  invisible(x)
}
