#' Arithmetic operators for RPolars objects
#'
#' @name S3_arithmetic
#' @param x,y numeric type of RPolars objects or objects that can be coerced such.
#' Only `+` can take strings.
#' @return A Polars object the same type as the input.
#' @seealso
#' - [`<Expr>$add()`][Expr_add]
#' - [`<Expr>$sub()`][Expr_sub]
#' - [`<Expr>$mul()`][Expr_mul]
#' - [`<Expr>$div()`][Expr_div]
#' - [`<Expr>$pow()`][Expr_pow]
#' - [`<Expr>$mod()`][Expr_mod]
#' - [`<Expr>$floor_div()`][Expr_floor_div]
#' - [`<Series>$add()`][Series_add]
#' - [`<Series>$sub()`][Series_sub]
#' - [`<Series>$mul()`][Series_mul]
#' - [`<Series>$div()`][Series_div]
#' - [`<Series>$pow()`][Series_pow]
#' - [`<Series>$mod()`][Series_mod]
#' - [`<Series>$floor_div()`][Series_floor_div]
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
#'
#' pl$Series(5) + 10
#' +pl$Series(5)
#' -pl$Series(5)
NULL


#' @export
#' @rdname S3_arithmetic
`+.RPolarsExpr` = function(x, y) {
  if (missing(y)) {
    return(x)
  }
  result(wrap_e(x)$add(y)) |>
    unwrap("using the `+`-operator")
}

#' @export
`+.RPolarsThen` = `+.RPolarsExpr`

#' @export
`+.RPolarsChainedThen` = `+.RPolarsExpr`


#' @export
#' @rdname S3_arithmetic
`-.RPolarsExpr` = function(x, y) {
  result(
    if (missing(y)) wrap_e(0L)$sub(x) else wrap_e(x)$sub(y)
  ) |> unwrap("using the '-'-operator")
}

#' @export
`-.RPolarsThen` = `-.RPolarsExpr`

#' @export
`-.RPolarsChainedThen` = `-.RPolarsExpr`


#' @export
#' @rdname S3_arithmetic
`*.RPolarsExpr` = function(x, y) {
  result(wrap_e(x)$mul(y)) |>
    unwrap("using the `*`-operator")
}

#' @export
`*.RPolarsThen` = `*.RPolarsExpr`

#' @export
`*.RPolarsChainedThen` = `*.RPolarsExpr`


#' @export
#' @rdname S3_arithmetic
`/.RPolarsExpr` = function(x, y) {
  result(wrap_e(x)$div(y)) |>
    unwrap("using the `/`-operator")
}

#' @export
`/.RPolarsThen` = `/.RPolarsExpr`

#' @export
`/.RPolarsChainedThen` = `/.RPolarsExpr`


#' @export
#' @rdname S3_arithmetic
`^.RPolarsExpr` = function(x, y) {
  result(wrap_e(x)$pow(y)) |>
    unwrap("using `^`-operator")
}

#' @export
`^.RPolarsThen` = `^.RPolarsExpr`

#' @export
`^.RPolarsChainedThen` = `^.RPolarsExpr`


#' @export
#' @rdname S3_arithmetic
`%%.RPolarsExpr` = function(x, y) {
  result(wrap_e(x)$mod(y)) |>
    unwrap("using the `%%`-operator")
}

#' @export
`%%.RPolarsThen` = `%%.RPolarsExpr`

#' @export
`%%.RPolarsChainedThen` = `%%.RPolarsExpr`


#' @export
#' @rdname S3_arithmetic
`%/%.RPolarsExpr` = function(x, y) {
  result(wrap_e(x)$floor_div(y)) |>
    unwrap("using the `%/%`-operator")
}

#' @export
`%/%.RPolarsThen` = `%/%.RPolarsExpr`

#' @export
`%/%.RPolarsChainedThen` = `%/%.RPolarsExpr`


#' @export
#' @rdname S3_arithmetic
`+.RPolarsSeries` = function(x, y) {
  if (missing(y)) {
    return(x)
  }
  result(as_polars_series(x)$add(y)) |>
    unwrap("using the `+`-operator")
}


#' @export
#' @rdname S3_arithmetic
`-.RPolarsSeries` = function(x, y) {
  result(if (missing(y)) {
    pl$Series(0L)$sub(as_polars_series(x))
  } else {
    as_polars_series(x)$sub(y)
  }) |>
    unwrap("using the `-`-operator")
}


#' @export
#' @rdname S3_arithmetic
`*.RPolarsSeries` = function(x, y) {
  result(as_polars_series(x)$mul(y)) |>
    unwrap("using the `*`-operator")
}


#' @export
#' @rdname S3_arithmetic
`/.RPolarsSeries` = function(x, y) {
  result(as_polars_series(x)$div(y)) |>
    unwrap("using the `/`-operator")
}


#' @export
#' @rdname S3_arithmetic
`^.RPolarsSeries` = function(x, y) {
  result(as_polars_series(x)$pow(y)) |>
    unwrap("using the `^`-operator")
}


#' @export
#' @rdname S3_arithmetic
`%%.RPolarsSeries` = function(x, y) {
  result(as_polars_series(x)$mod(y)) |>
    unwrap("using the `%%`-operator")
}


#' @export
#' @rdname S3_arithmetic
`%/%.RPolarsSeries` = function(x, y) {
  result(as_polars_series(x)$floor_div(y)) |>
    unwrap("using the `%/%`-operator")
}
