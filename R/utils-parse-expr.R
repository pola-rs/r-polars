#' Parse dynamic dots into a list of expressions (PlRExpr, not polars-expr)
#' @noRd
parse_into_list_of_expressions <- function(..., `__structify` = FALSE) {
  list2(...) |>
    lapply(\(x) as_polars_expr(x, structify = `__structify`)$`_rexpr`)
}

.structify_expression <- function(expr) {
  unaliased_expr <- expr$meta$undo_aliases()
  if (unaliased_expr$meta$has_multiple_outputs()) {
    expr_name <- expr$meta$output_name(raise_if_undetermined = FALSE)
    if (is_na(expr_name)) {
      pl$struct(expr)
    } else {
      pl$struct(unaliased_expr)$alias(expr_name)
    }
  } else {
    expr
  }
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
