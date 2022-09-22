

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
#' pl$df(iris)$select(pl$col("Petal.Length")$sum()$over("Species"))
import_polars_as_ <- function(name = "pl") {
  minipolars:::fake_package(
    name,
    minipolars:::pl,
    attach=FALSE
  )
  invisible(NULL)
}



datatype = function(...) {
  do.call(minipolars:::DataType$new,list(...))
}
#' @export
"==.DataType" <- function(e1,e2) e1$eq(e2)
#' @export
"!=.DataType" <- function(e1,e2) e1$ne(e2)


#define print behaviour for minipolars classes


#' Print expr
#'
#' @param x Expr
#'
#' @return self
#' @export
#'
#' @examples pl$col("some_column")$sum()$over("some_other_column")
print.Expr = function(x) {
  cat("polars Expr: ")
  x$print()
}


#' print DataFrame
#'
#' @param x polar_frame
#'
#' @return self
#' @export
#'
#' @examples pl$DataFrame(iris)
print.DataFrame = function(x) {
  cat("polars DataFrame: ")
  x$print()
}




#' print a polars datatype
#'
#' @param x DataType
#'
#' @return self
#' @export
#'
#' @examples minipolars:::DataType$new("Boolean")
print.DataType = function(x) {
  cat("polars DataType: ")
  x$print()
}



#' @export
.DollarNames.Series = function(x, pattern = "") {
  paste0(ls(minipolars:::Series),"()")
}

#' @export
.DollarNames.Expr = function(x, pattern = "") {
  paste0(ls(minipolars:::Expr),"()")
}

#' @export
.DollarNames.DataFrame = function(x, pattern = "") {
  paste0(ls(minipolars:::DataFrame),"()")
}


