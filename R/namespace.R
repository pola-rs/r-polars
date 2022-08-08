

#' Bind polars function to a namespace object pl
#'
#' @details polars has alot of function names conflicting with base R like sum and col.
#' To disambiguate, minipolars can be loaded as namesapce, syntactically very similar to
#' python's `import polars as pl`. The major syntactical difference between py-polars and minipolars
#' is that in R `$` is used as method operator instead of `.`.
#'
#' @return NULL
#' @export
#'
#' @examples import_polars_as_("pl")
#' pl::df(iris)$select(pl::col("Petal.Length")$sum()$over("Species"))
import_polars_as_ <- function(name = "pl") {
  minipolars:::fake_package(
    name,
    list(
      #map the following class constructors
      col = minipolars:::col, #Rexpr
      df  = minipolars:::new_pf,    #Rdataframe, low-level interface
      pf = function(data) minipolars:::polar_frame$new(data), ##deprecated
      polars_frame = function(data) minipolars:::polar_frame$new(data), ##deprecated

      #polar_Frame, R6 interface
      series = minipolars:::series, #Rseries
      datatype = datatype,

      #functions
      lazy_csv_reader = minipolars:::lazy_csv_reader,
      csv_reader = minipolars:::csv_reader,
      read_csv = minipolars:::read_csv_


      #methods do not need mapping, as they should be access directly from instances
    ),
    attach=FALSE
  )
  invisible(NULL)
}

col = function(...) {
  do.call(minipolars:::Rexpr$col,list(...))
}

series = function(...) {
  do.call(minipolars:::Rseries$new,list(...))
}

datatype = function(...) {
  do.call(minipolars:::Rdatatype$new,list(...))
}

#define print behaviour for minipolars classes


#' Print expr
#'
#' @param x Rexpr
#'
#' @return self
#' @export
#'
#' @examples pl::col("some_column")$sum()$over("some_other_column")
print.Rexpr = function(x) {
  cat("polars expr: ")
  x$print()
}


#' print dataframe
#'
#' @param x polar_frame
#'
#' @return self
#' @export
#'
#' @examples pl::pf(iris)
print.Rdataframe = function(x) {
  cat("polars dataframe: ")
  x$print()
}


#' Print rseries
#'
#' @param x Rseries

#'
#' @return self
#' @export
#'
#' @examples pl::series(letters,"lowercase_letters")
print.Rseries = function(x) {
  cat("polars series: ")
  x$print()
}

#' print a polars datatype
#'
#' @param x Rdatatype
#'
#' @return self
#' @export
#'
#' @examples minipolars:::Rdatatype$new("Boolean")
print.Rdatatype = function(x) {
  cat("polars datatype: ")
  x$print()
}

#' print polars polars_lazy_frame
#'
#' @param x Rlazyfrane
#'
#' @return self
#' @export
#'
#' @examples #TODO give example
print.Rlazyfrane = function(x) {
  cat("polars lazyframe: ")
  x$print()
}

