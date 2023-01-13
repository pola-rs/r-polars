

#' @title concat polars objects
#'
#' @param l list of DataFrame, or Series, LazyFrame or Expr
#' @param rechunk perform a rechunk at last
#' @param how choice of bind direction "vertical"(rbind) "horizontal"(cbind) "diagnoal" diagonally
#' @param parallel BOOL default TRUE, only used for LazyFrames
#'
#' @return DataFrame, or Series, LazyFrame or Expr
#' @export
#'
#' @examples
#' #vertical
#'  l_ver = lapply(1:10, function(i) {
#'l_internal = list(
#'  a = 1:5,
#'  b = letters[1:5]
#')
#'pl$DataFrame(l_internal)
#'})
#'pl$concat(l_ver, how="vertical")
#'
#'
#'#horizontal
#'l_hor = lapply(1:10, function(i) {
#'  l_internal = list(
#'    1:5,
#'    letters[1:5]
#'  )
#'  names(l_internal) = paste0(c("a","b"),i)
#'  pl$DataFrame(l_internal)
#'})
#'pl$concat(l_hor, how = "horizontal")
#'
#'
#'#diagonal
#'pl$concat(l_hor, how = "diagonal")
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
        how == "vertical",   rpolars:::concat_df(vdf),
        how == "diagonal",    rpolars:::diag_concat_df(vdf),
        how == "horizontal", rpolars:::hor_concat_df(vdf),
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
#'
#' @param low string or
#' @param high string or
#' @param interval string parsed to duration like "1w" "1week" "2years" "10s"
#' @param ... not used
#' @param lazy  bool
#' @param closed option one of 'both'(default), 'left', 'none' or 'right'
#' @param name name of series
#' @param time_unit option "ns" "us" "ms"
#' @param time_zone
#'
#' @return a datetime
#'
#' @examples
#' t_ms = unclass(as.POSIXct("2022-01-01",tz = "GMT",origin="GMT")) * 1000
#' pl$date_range(t_ms,t_ms+7500, interval = "2s", time_unit = "ms", time_zone = "GMT")
pl$date_range = function(
    low,      #: date | datetime | pli.Expr | str,
    high,     #: date | datetime | pli.Expr | str,
    interval, #: str | timedelta,
    ...,      #*,
    lazy,     #: Literal[True],
    closed    = "both",   #: ClosedInterval = "both",
    name      = "",     #: str | None = None,
    time_unit = "us",#: TimeUnit | None = None,
    time_zone = NULL#: str | None = None
) {
  unwrap(rpolars:::r_date_range(low, high, interval, closed, name, time_unit, time_zone))
}


