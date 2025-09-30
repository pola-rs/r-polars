#' Get a lazily evaluated DataType of a column or expression
#'
#' `r lifecycle::badge("experimental")`
#' Get a lazily evaluated DataType of a column or expression
#' @param col_or_expr Either a string for the column_name or an expression.
#'
#' @return A polars datatype expression.
#'   This is not the same as a [polars expression][polars_expr].
pl__dtype_of <- function(col_or_expr) {
  as_polars_dtype_expr(col_or_expr) |>
    wrap()
}
