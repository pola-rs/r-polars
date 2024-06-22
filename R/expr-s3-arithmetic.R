#' @export
`+.polars_expr` <- function(e1, e2) {
  if (missing(e2)) {
    e1
  } else {
    as_polars_expr(e1)$add(as_polars_expr(e2))
  }
}

#' @export
`-.polars_expr` <- function(e1, e2) {
  if (missing(e2)) {
    e2$neg()
  } else {
    as_polars_expr(e1)$sub(as_polars_expr(e2))
  }
}

#' @export
`*.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1)$mul(as_polars_expr(e2))
}

#' @export
`/.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1)$true_div(as_polars_expr(e2))
}

#' @export
`%%.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1)$mod(as_polars_expr(e2))
}

#' @export
`%/%.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1)$floor_div(as_polars_expr(e2))
}
