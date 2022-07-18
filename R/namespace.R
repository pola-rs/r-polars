

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
      pf = function(data) minipolars:::polar_frame$new(data),
      #polar_Frame, R6 interface
      series = minipolars:::series, #Rseries
      datatype = datatype


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


#' Title
#'
#' @param x
#' @S3method
#'
#' @return
#' @export
#'
#' @examples
print.Rexpr = function(x) {
  cat("polars_expr: ")
  x$print()
}


#' Title
#'
#' @param x
#' @S3method
#'
#' @return
#' @export
#'
#' @examples
print.Rdataframe = function(x) {
  cat("polars_dataframe: ")
  x$print()
}


#' Title
#'
#' @param x
#' @S3method
#'
#' @return
#' @export
#'
#' @examples
print.Rseries = function(x) {
  cat("polars_series: ")
  x$print()
}

#' Title
#'
#' @param x
#' @S3method
#'
#' @return
#' @export
#'
#' @examples
print.Rdatatype = function(x) {
  cat("polars_datatype: ")
  x$print()
}

# print_Rdatatype = function(x) {
#   cat("polars_datatype_vector: ")
#   x$print()
# }

# .S3method("print", "Rexpr", print_Rexpr)
# .S3method("print", "Rdataframe", print_Rdataframe)
# .S3method("print", "Rseries", print_Rseries)
# .S3method("print", "Rdatatype", print_Rseries)
# .S3method("print", "Rdatatype_vector", print_Rseries)
