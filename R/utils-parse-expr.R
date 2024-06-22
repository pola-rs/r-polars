#' Parse dynamic dots into a list of expressions (PlRExpr, not polars-expr)
parse_into_list_of_expressions <- function(...) {
  list2(...) |>
    lapply(\(x) as_polars_expr(x)$`_rexpr`)
}
