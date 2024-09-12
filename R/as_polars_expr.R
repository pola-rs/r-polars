# Same as Python Polars' `parse_into_expression`
# TODO: link to Expr class page
# TODO: link to data type page
# TODO: link to `pl__lit`
# TODO: link to `expr__first`
# TODO: link to `pl__col`
#' Create a Polars Expression from an R object
#'
#' The [as_polars_expr()] function creates a polars Expression from various R objects.
#' This function is used internally by various polars functions that accept Expressions.
#'
#' Because R objects are typically mapped to [Series], this function often calls [as_polars_series()] internally.
#' However, unlike R, Polars has scalars of length 1, so if an R object is converted to a [Series] of length 1,
#' this function will use `<Expr>$first()` at the end to convert it to a scalar value.
#' If you want to implement your own conversion from an R class to a Polars object,
#' define an S3 method for [as_polars_series()] instead of this function.
#'
#' ## Default S3 method
#'
#' Create a [Series] by calling [as_polars_series()] and then convert that [Series] to an Expression.
#' If the length of the [Series] is `1`, it will be converted to a scalar value using `<Expr>$first()` at the end.
#'
#' ## S3 method for [character]
#'
#' If the `str_as_lit` argument is `FALSE`, this function will call `pl$col()` and
#' the character vector is treated as column names.
#'
#' @inheritParams as_polars_series
#' @param str_as_lit A logical value indicating whether to treat the character vector as literal values
#' or column names (default).
#' @return A polars Expression
#' @seealso
#' - [as_polars_series()]: R -> Polars type mapping is defined by this function.
#' @examples
#' # character
#' as_polars_expr("a")
#' as_polars_expr(c("a", "b"))
#' as_polars_expr("a", str_as_lit = TRUE)
#' as_polars_expr(c("a", "b"), str_as_lit = TRUE)
#'
#' # logical
#' as_polars_expr(TRUE)
#' as_polars_expr(c(TRUE, FALSE))
#'
#' # integer
#' as_polars_expr(1L)
#' as_polars_expr(c(1L, 2L))
#'
#' # double
#' as_polars_expr(1)
#' as_polars_expr(c(1, 2))
#'
#' # raw
#' as_polars_expr(charToRaw("foo"))
#'
#' # default method (for list)
#' as_polars_expr(list(1))
#' as_polars_expr(list(1, 2))
#'
#' # polars_series
#' ## Unlike the default method, this method does not call `$first()`
#' as_polars_series(1) |>
#'   as_polars_expr()
#' @export
as_polars_expr <- function(x, ...) {
  UseMethod("as_polars_expr")
}

#' @rdname as_polars_expr
#' @export
as_polars_expr.default <- function(x, ...) {
  wrap({
    series <- as_polars_series(x, name = "literal")

    if (series$len() == 1L) {
      # Treat as scalar
      lit_from_series(series$`_s`)$first()
    } else {
      lit_from_series(series$`_s`)
    }
  })
}

#' @rdname as_polars_expr
#' @export
as_polars_expr.polars_expr <- function(x, ...) {
  x
}

#' @rdname as_polars_expr
#' @export
as_polars_expr.polars_series <- function(x, ...) {
  lit_from_series(x$`_s`) |>
    wrap()
}

#' @rdname as_polars_expr
#' @export
as_polars_expr.character <- function(x, ..., str_as_lit = FALSE) {
  wrap({
    if (isFALSE(str_as_lit)) {
      pl$col(x)
    } else {
      if (length(x) == 1L) {
        if (is.na(x)) {
          lit_null()$cast(pl$String$`_dt`, strict = TRUE)
        } else {
          lit_from_str(x)
        }
      } else {
        as_polars_expr.default(x)
      }
    }
  })
}

#' @rdname as_polars_expr
#' @export
as_polars_expr.logical <- function(x, ...) {
  wrap({
    if (length(x) == 1L) {
      if (is.na(x)) {
        lit_null()$cast(pl$Boolean$`_dt`, strict = TRUE)
      } else {
        lit_from_bool(x)
      }
    } else {
      as_polars_expr.default(x)
    }
  })
}

#' @rdname as_polars_expr
#' @export
as_polars_expr.integer <- function(x, ...) {
  wrap({
    if (length(x) == 1L) {
      if (is.na(x)) {
        lit_null()$cast(pl$Int32$`_dt`, strict = TRUE)
      } else {
        lit_from_i32(x)
      }
    } else {
      as_polars_expr.default(x)
    }
  })
}

#' @rdname as_polars_expr
#' @export
as_polars_expr.double <- function(x, ...) {
  wrap({
    if (length(x) == 1L) {
      if (is.na(x)) {
        lit_null()$cast(pl$Float64$`_dt`, strict = TRUE)
      } else {
        lit_from_f64(x)
      }
    } else {
      as_polars_expr.default(x)
    }
  })
}

#' @rdname as_polars_expr
#' @export
as_polars_expr.raw <- function(x, ...) {
  lit_from_raw(x) |>
    wrap()
}

#' @rdname as_polars_expr
#' @export
as_polars_expr.NULL <- function(x, ...) {
  lit_null() |>
    wrap()
}
