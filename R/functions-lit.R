pl__lit <- function(value, dtype = NULL) {
  if (is.null(dtype)) {
    as_polars_expr(value, str_as_lit = TRUE)
  } else {
    as_polars_expr(value, str_as_lit = TRUE)$cast(dtype)
  }
}
