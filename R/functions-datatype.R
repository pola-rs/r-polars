#' Get a lazily evaluated DataType of a column or expression
#'
#' `r lifecycle::badge("experimental")`
#' Get a lazily evaluated DataType of a column or expression
#' @param col_or_expr Either a string for the column_name or an expression.
#'
#' @return A polars datatype expression.
#'   This is not the same as a [polars expression][polars_expr].
pl__dtype_of <- function(col_or_expr) {
  wrap({
    if (is_string(col_or_expr)) {
      e <- pl$col(col_or_expr)
    } else if (is_polars_expr(col_or_expr)) {
      e <- col_or_expr
    } else {
      abort("`col_or_expr` must be a column name or a Polars expression.")
    }
    `PlRDataTypeExpr`$`of_expr`(e$`_rexpr`)
  })
}
