

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




