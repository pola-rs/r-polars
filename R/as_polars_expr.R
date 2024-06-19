# Same as Python Polars' `parse_into_expression`
#' @export
as_polars_expr <- function(x, ...) {
  UseMethod("as_polars_expr")
}

#' @export
as_polars_expr.default <- function(x, ...) {
  as_polars_lit(x)
}

#' @export
as_polars_expr.polars_expr <- function(x, ...) {
  x
}

#' @export
as_polars_expr.character <- function(x, ..., str_as_lit = FALSE) {
  if (isFALSE(str_as_lit)) {
    pl$col(x)
  } else {
    as_polars_lit(x)
  }
}
