as_polars_dtype_expr <- function(x, ...) {
  UseMethod("as_polars_dtype_expr")
}

#' @export
as_polars_dtype_expr.default <- function(x, ...) {
  abort(sprintf("%s can't be converted to a polars datatype expression.", obj_type_friendly(x)))
}

#' @export
as_polars_dtype_expr.polars_datatype_expr <- function(x, ...) {
  x
}

#' @export
as_polars_dtype_expr.character <- function(x, ...) {
  if (!is_string(x)) {
    abort(
      "Non-single string character vectors can't be converted to a polars datatype expression."
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
