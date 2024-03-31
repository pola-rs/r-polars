#' Similar to `parse_as_expression` in Python Polars.
as_polars_expr = function(x, ...) {
  UseMethod("as_polars_expr")
}


as_polars_expr.default(x, ...) = function(x, ...) {
  pl$lit(x)
}


as_polars_expr.RPolarsExpr = function(x, ...) {
  x
}


as_polars_expr.character = function(x, ..., as_lit = FALSE) {
  if (as_lit) {
    pl$lit(x)
  } else {
    pl$col(x)
  }
}


as_polars_expr.RPolarsThen = function(x, ...) {
  x$otherwise(NULL)
}


as_polars_expr.RPolarsChainedThen = as_polars_expr.RPolarsThen
