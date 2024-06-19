#' @export
as_polars_expr <- function(x, ...) {
  UseMethod("as_polars_expr")
}

#' @export
as_polars_expr.default <- function(x, ...) {
  classes <- class(x)
  stop("Unsupported class: ", paste(classes, collapse = ", "))
}

#' @export
as_polars_expr.polars_expr <- function(x, ...) {
  x
}
