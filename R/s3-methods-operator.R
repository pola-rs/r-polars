#' Arithmetic operators for RPolars objects
#'
#' @name S3_arithmetic
#' @param e1 Expr only
#' @param e2 Expr or anything that can be converted to a literal
#' @seealso
#' - [`<Expr>$add()`][Expr_add]
#' - [`<Expr>$div()`][Expr_div]
#' - [`<Expr>$floor_div()`][Expr_floor_div]
#' - [`<Expr>$mod()`][Expr_mod]
#' - [`<Expr>$sub()`][Expr_sub]
#' - [`<Expr>$mul()`][Expr_mul]
#' - [`<Expr>$pow()`][Expr_pow]
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
#'   expr$to_series(),
#'   error = function(e) e
#' )
NULL


#' @export
#' @rdname S3_arithmetic
`+.RPolarsExpr` = function(e1, e2) {
  if (missing(e2)) {
    return(e1)
  }
  result(wrap_e(e1)$add(e2)) |>
    unwrap("using the `+`-operator")
}

#' @export
`+.RPolarsThen` = `+.RPolarsExpr`

#' @export
`+.RPolarsChainedThen` = `+.RPolarsExpr`


#' @export
#' @rdname S3_arithmetic
`/.RPolarsExpr` = function(e1, e2) {
  result(wrap_e(e1)$div(e2)) |>
    unwrap("using the `/`-operator")
}

#' @export
`/.RPolarsThen` = `/.RPolarsExpr`

#' @export
`/.RPolarsChainedThen` = `/.RPolarsExpr`


#' @export
#' @rdname S3_arithmetic
`%/%.RPolarsExpr` = function(e1, e2) {
  result(wrap_e(e1)$floor_div(e2)) |>
    unwrap("using the `%/%`-operator")
}

#' @export
`%/%.RPolarsThen` = `%/%.RPolarsExpr`

#' @export
`%/%.RPolarsChainedThen` = `%/%.RPolarsExpr`


#' @export
#' @rdname S3_arithmetic
`%%.RPolarsExpr` = function(e1, e2) {
  result(wrap_e(e1)$mod(e2)) |>
    unwrap("using the `%%`-operator")
}

#' @export
`%%.RPolarsThen` = `%%.RPolarsExpr`

#' @export
`%%.RPolarsChainedThen` = `%%.RPolarsExpr`


#' @export
#' @rdname S3_arithmetic
`-.RPolarsExpr` = function(e1, e2) {
  result(
    if (missing(e2)) wrap_e(0L)$sub(e1) else wrap_e(e1)$sub(e2)
  ) |> unwrap("using the '-'-operator")
}

#' @export
`-.RPolarsThen` = `-.RPolarsExpr`

#' @export
`-.RPolarsChainedThen` = `-.RPolarsExpr`


#' @export
#' @rdname S3_arithmetic
`*.RPolarsExpr` = function(e1, e2) {
  result(wrap_e(e1)$mul(e2)) |>
    unwrap("using the `*`-operator")
}

#' @export
`*.RPolarsThen` = `*.RPolarsExpr`

#' @export
`*.RPolarsChainedThen` = `*.RPolarsExpr`


#' @export
#' @rdname S3_arithmetic
`^.RPolarsExpr` = function(e1, e2) {
  result(wrap_e(e1)$pow(e2)) |>
    unwrap("using `^`-operator")
}

#' @export
`^.RPolarsThen` = `^.RPolarsExpr`

#' @export
`^.RPolarsChainedThen` = `^.RPolarsExpr`
