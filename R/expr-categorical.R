# The env for storing all expr cat methods
polars_expr_cat_methods <- new.env(parent = emptyenv())

namespace_expr_cat <- function(x) {
  self <- new.env(parent = emptyenv())
  self$`_rexpr` <- x$`_rexpr`

  class(self) <- c(
    "polars_namespace_expr_cat",
    "polars_namespace_expr",
    "polars_object"
  )
  self
}

#' Get the categories stored in this data type
#'
#' @inherit as_polars_expr return
#' @examples
#' df <- pl$DataFrame(
#'   cats = factor(c("z", "z", "k", "a", "b")),
#'   vals = factor(c(3, 1, 2, 2, 3))
#' )
#' df
#'
#' df$select(
#'   pl$col("cats")$cat$get_categories()
#' )
#' df$select(
#'   pl$col("vals")$cat$get_categories()
#' )
expr_cat_get_categories <- function() {
  self$`_rexpr`$cat_get_categories() |>
    wrap()
}
