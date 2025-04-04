#' @export
print.polars_expr <- function(x, ...) {
  x$`_rexpr`$as_str() |>
    writeLines()
  invisible(x)
}

#' @export
`[.polars_namespace_expr_struct` <- function(x, i, ...) {
  if (is.numeric(i)) {
    x$field_by_index(i)
  } else if (is.character(i)) {
    x$field(i)
  } else {
    abort(sprintf("expected type numeric or character for `i`, got %s", typeof(i)))
  }
}
