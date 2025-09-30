as_polars_dtype_expr <- function(x, ...) {
  UseMethod("as_polars_dtype_expr")
}

#' @export
as_polars_dtype_expr.polars_datatype_expr <- function(x, ...) {
  x
}

#' @export
as_polars_dtype_expr.character <- function(x, ...) {
  if (!is_string(x)) {
    abort(
      c(
        format_error(sprintf(
          "%s must be a single string.",
          format_arg("x")
        ))
      )
    )
  }
  col(x) |>
    PlRDataTypeExpr$of_expr() |>
    wrap()
}

#' @export
as_polars_dtype_expr.polars_expr <- function(x, ...) {
  PlRDataTypeExpr$of_expr(x$`_rexpr`) |>
    wrap()
}
