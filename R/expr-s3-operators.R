#' Arithmetic operators for Polars objects
#'
#' @name s3-arithmetic
#' @param e1,e2 Polars objects of numeric type or objects that can be coerced
#' to a polars object of numeric type. Only `+` can work with two string
#' inputs.
#'
#' @return A Polars object the same type as the input.
#' @seealso
#' - [`<Expr>$add()`][expr__add]
#' - [`<Expr>$sub()`][expr__sub]
#' - [`<Expr>$mul()`][expr__mul]
#' - [`<Expr>$true_div()`][expr__true_div]
#' - [`<Expr>$pow()`][expr__pow]
#' - [`<Expr>$mod()`][expr__mod]
#' - [`<Expr>$floor_div()`][expr__floor_div]
#'
#' @examples
#' pl$lit(5) + 10
#' 5 + pl$lit(10)
#' pl$lit(5) + pl$lit(10)
#' +pl$lit(1)
#'
#' # This will not raise an error as it is not actually evaluated.
#' expr = pl$lit(5) + "10"
#' expr
#'
#' # Will raise an error as it is evaluated.
#' tryCatch(
#'   pl$select(expr),
#'   error = function(e) e
#' )
#'
#' # `+` accepts two string inputs
#' pl$select(pl$lit("a") + "b")
#'
#' as_polars_series(5) + 10
#' +as_polars_series(5)
#' -as_polars_series(5)
NULL


#' @export
#' @rdname s3-arithmetic
`+.polars_expr` <- function(e1, e2) {
  if (missing(e2)) {
    e1
  } else {
    as_polars_expr(e1, as_lit = TRUE)$add(e2)
  }
}

#' @export
#' @rdname s3-arithmetic
`-.polars_expr` <- function(e1, e2) {
  if (missing(e2)) {
    e1$neg()
  } else {
    as_polars_expr(e1, as_lit = TRUE)$sub(e2)
  }
}

#' @export
#' @rdname s3-arithmetic
`*.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1, as_lit = TRUE)$mul(e2)
}

#' @export
#' @rdname s3-arithmetic
`/.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1, as_lit = TRUE)$true_div(e2)
}

#' @export
#' @rdname s3-arithmetic
`%%.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1, as_lit = TRUE)$mod(e2)
}

#' @export
#' @rdname s3-arithmetic
# nolint start: object_name_linter
`%/%.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1, as_lit = TRUE)$floor_div(e2)
}
# nolint end

#' @export
#' @rdname s3-arithmetic
`^.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1, as_lit = TRUE)$pow(e2)
}

#' @export
#' @rdname s3-arithmetic
`<.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1, as_lit = TRUE)$lt(e2)
}

#' @export
`>.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1, as_lit = TRUE)$gt(e2)
}

#' @export
`<=.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1, as_lit = TRUE)$le(e2)
}

#' @export
`>=.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1, as_lit = TRUE)$ge(e2)
}

#' @export
`==.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1, as_lit = TRUE)$eq(e2)
}

#' @export
`!=.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1, as_lit = TRUE)$ne(e2)
}

#' @export
`!.polars_expr` <- function(e1) {
  as_polars_expr(e1, as_lit = TRUE)$invert()
}

#' @export
`&.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1, as_lit = TRUE)$and(e2)
}

#' @export
`|.polars_expr` <- function(e1, e2) {
  as_polars_expr(e1, as_lit = TRUE)$or(e2)
}
