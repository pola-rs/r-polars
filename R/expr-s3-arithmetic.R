#' @export
`+.polars_expr` <- function(e1, e2) {
  if (missing(e2)) {
    e1
  } else {
    as_polars_expr(e1)$add(e2)
  }
}

#' @export
`-.polars_expr` <- function(e1, e2) {
  if (missing(e2)) {
    e2$neg()
  } else {
    as_polars_expr(e1)$sub(e2)
  }
}

#' @export
`*.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1)$mul(e2)
}

#' @export
`/.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1)$true_div(e2)
}

#' @export
`%%.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1)$mod(e2)
}

#' @export
`%/%.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1)$floor_div(e2)
}
