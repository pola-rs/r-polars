

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
concat = function(
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



