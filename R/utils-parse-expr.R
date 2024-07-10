#' Parse dynamic dots into a list of expressions (PlRExpr, not polars-expr)
#' @noRd
parse_into_list_of_expressions <- function(...) {
  list2(...) |>
    lapply(\(x) as_polars_expr(x)$`_rexpr`)
}

#' Parse dynamic dots into a single expression (PlRExpr, not polars-expr)
#' @noRd
parse_predicates_constraints_into_expression <- function(...) {
  check_dots_unnamed()

  expr <- list2(...) |>
    lapply(as_polars_expr) |>
    Reduce(`&`, x = _)

  expr$`_rexpr`
}
