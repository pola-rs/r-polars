# Same as Python Polars' `parse_into_expression`
# TODO: link to data type page
#' Create a Polars expression from an R object
#'
#' The [as_polars_expr()] function creates a polars [expression] from various R objects.
#' This function is used internally by various polars functions that accept [expressions][Expr].
#' In most cases, users should use [`pl$lit()`][pl__lit] instead of this function, which is
#' a shorthand for `as_polars_expr(x, as_lit = TRUE)`.
#' (In other words, this function can be considered as an internal implementation to realize
#' the `lit` function of the Polars API in other languages.)
#'
#' Because R objects are typically mapped to [Series], this function often calls [as_polars_series()] internally.
#' However, unlike R, Polars has scalars of length 1, so if an R object is converted to a [Series] of length 1,
#' this function get the first value of the Series and convert it to a scalar literal.
#' If you want to implement your own conversion from an R class to a Polars object,
#' define an S3 method for [as_polars_series()] instead of this function.
#'
#' ## Default S3 method
#'
#' Create a [Series] by calling [as_polars_series()] and then convert that [Series] to an [Expr].
#' If the length of the [Series] is `1`, it will be converted to a scalar value.
#'
#' Additional arguments `...` are passed to [as_polars_series()].
#'
#' ## S3 method for [character]
#'
#' If the `as_lit` argument is `FALSE` (default), this function will call [`pl$col()`][pl__col] and
#' the character vector is treated as column names.
#'
#' ## S3 method for [raw]
#'
#' If the `raw_as_binary` argument is `TRUE` (default), the raw vector is converted to
#' a [Binary][DataType] type scalar. Otherwise, the default method is called.
#'
#' ## S3 method for `NULL`
#'
#' `NULL` is converted to a Null type `null` literal.
#'
#' @inheritParams as_polars_series
#' @param as_lit A logical value indicating whether to treat vector as literal values or not.
#' This argument is always set to `TRUE` when calling this function from [`pl$lit()`][pl__lit],
#' and expects to return literal values. See examples for details.
#' @param raw_as_binary A logical value indicating whether to convert [raw] vector to
#' a [Binary][DataType] type scalar. If `TRUE` (default), the output is a [Binary][DataType] type scalar
#' instead of [UInt8][DataType] type literal.
#' @param structify A logical. If `TRUE`, convert multi-column expressions to a single struct expression
#' by calling [`pl$struct()`][pl__struct]. Otherwise (default), done nothing.
#' @return A polars [expression]
#' @seealso
#' - [as_polars_series()]: R -> Polars type mapping is mostly defined by this function.
#' @examples
#' # character
#' ## as_lit = FALSE (default)
#' as_polars_expr("a") # Same as `pl$col("a")`
#' as_polars_expr(c("a", "b")) # Same as `pl$col("a", "b")`
#'
#' ## as_lit = TRUE
#' as_polars_expr(character(0), as_lit = TRUE)
#' as_polars_expr("a", as_lit = TRUE)
#' as_polars_expr(NA_character_, as_lit = TRUE)
#' as_polars_expr(c("a", "b"), as_lit = TRUE)
#'
#' # logical
#' as_polars_expr(logical(0))
#' as_polars_expr(TRUE)
#' as_polars_expr(NA)
#' as_polars_expr(c(TRUE, FALSE))
#'
#' # integer
#' as_polars_expr(integer(0))
#' as_polars_expr(1L)
#' as_polars_expr(NA_integer_)
#' as_polars_expr(c(1L, 2L))
#'
#' # double
#' as_polars_expr(double(0))
#' as_polars_expr(1)
#' as_polars_expr(NA_real_)
#' as_polars_expr(c(1, 2))
#'
#' # raw
#' as_polars_expr(as.raw(1))
#' as_polars_expr(as.raw(1), raw_as_binary = FALSE)
#' as_polars_expr(charToRaw("foo"))
#' as_polars_expr(charToRaw("foo"), raw_as_binary = FALSE)
#'
#' # NULL
#' as_polars_expr(NULL)
#'
#' # default method (for list)
#' as_polars_expr(list())
#' as_polars_expr(list(1))
#' as_polars_expr(list(1, 2))
#'
#' # default method (for Date)
#' as_polars_expr(as.Date(integer(0)))
#' as_polars_expr(as.Date("2021-01-01"))
#' as_polars_expr(as.Date(c("2021-01-01", "2021-01-02")))
#'
#' # polars_series
#' ## Unlike the default method, this method does not extract the first value
#' as_polars_series(1) |>
#'   as_polars_expr()
#'
#' # polars_expr
#' as_polars_expr(pl$col("a", "b"))
#' as_polars_expr(pl$col("a", "b"), structify = TRUE)
#' @export
as_polars_expr <- function(x, ...) {
  UseMethod("as_polars_expr")
}

# TODO: replace wrap to try_fetch
#' @rdname as_polars_expr
#' @export
as_polars_expr.default <- function(x, ...) {
  wrap({
    series <- as_polars_series(x, name = "literal", ...)

    if (series$len() == 1L) {
      # Treat as scalar
      lit_from_series_first(series$`_s`)
    } else {
      lit_from_series(series$`_s`)
    }
  })
}

#' @rdname as_polars_expr
#' @export
as_polars_expr.polars_expr <- function(x, ..., structify = FALSE) {
  if (isTRUE(structify)) {
    .structify_expression(x)
  } else {
    x
  }
}

#' @rdname as_polars_expr
#' @export
as_polars_expr.polars_series <- function(x, ...) {
  lit_from_series(x$`_s`) |>
    wrap()
}

#' @rdname as_polars_expr
#' @export
as_polars_expr.character <- function(x, ..., as_lit = FALSE) {
  if (isFALSE(as_lit)) {
    pl$col(!!!x)
  } else {
    NextMethod()
  }
}

#' @rdname as_polars_expr
#' @export
as_polars_expr.raw <- function(x, ..., raw_as_binary = TRUE) {
  if (isTRUE(raw_as_binary)) {
    lit_bin_from_raw(x) |>
      wrap()
  } else {
    NextMethod()
  }
}

#' @rdname as_polars_expr
#' @export
as_polars_expr.NULL <- function(x, ...) {
  wrap({
    if (missing(x)) {
      abort("The `x` argument of `as_polars_expr()` can't be missing")
    }
    lit_null()
  })
}
