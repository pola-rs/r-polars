# TODO: export?
as_polars_lit <- function(x, ...) {
  UseMethod("as_polars_lit")
}

#' @export
as_polars_lit.default <- function(x, ...) {
  as_polars_series(x, name = "literal") |>
    as_polars_lit.polars_series()
}

#' @export
as_polars_lit.polars_expr <- as_polars_expr.polars_expr

#' @export
as_polars_lit.polars_series <- function(x, ...) {
  lit_from_series(x$`_s`) |>
    wrap()
}

#' @export
as_polars_lit.NULL <- function(x, ...) {
  lit_null() |>
    wrap()
}

#' @export
as_polars_lit.logical <- function(x, ...) {
  len <- length(x)

  if (len == 0L || len == 1L && is.na(x)) {
    as_polars_lit.NULL()$cast(pl$Boolean)
  } else if (len == 1L) {
    lit_from_bool(x) |>
      wrap()
  } else {
    as_polars_lit.default(x)
  }
}

#' @export
as_polars_lit.integer <- function(x, ...) {
  len <- length(x)

  if (len == 0L || len == 1L && is.na(x)) {
    as_polars_lit.NULL()$cast(pl$Int32)
  } else if (len == 1L) {
    lit_from_i32(x) |>
      wrap()
  } else {
    as_polars_lit.default(x)
  }
}

#' @export
as_polars_lit.double <- function(x, ...) {
  len <- length(x)

  if (len == 0L || len == 1L && is.na(x) && !is.nan(x)) {
    as_polars_lit.NULL()$cast(pl$Float64)
  } else if (len == 1L) {
    lit_from_f64(x) |>
      wrap()
  } else {
    as_polars_lit.default(x)
  }
}

#' @export
as_polars_lit.character <- function(x, ...) {
  len <- length(x)

  if (len == 0L || len == 1L && is.na(x)) {
    as_polars_lit.NULL()$cast(pl$String)
  } else if (len == 1L) {
    lit_from_str(x) |>
      wrap()
  } else {
    as_polars_lit.default(x)
  }
}

#' @export
as_polars_lit.raw <- function(x, ...) {
  lit_from_raw(x) |>
    wrap()
}

#' @export
as_polars_lit.blob <- function(x, ...) {
  len <- length(x)

  if (len == 0L || len == 1L && is.na(x)) {
    as_polars_lit.NULL()$cast(pl$Binary)
  } else if (len == 1L) {
    unlist(x) |>
      lit_from_raw() |>
      wrap()
  } else {
    as_polars_lit.default(x)
  }
}

# TODO: date, datetime, difftime support
pl__lit <- function(value, dtype = NULL) {
  if (is.null(dtype)) {
    as_polars_lit(value)
  } else {
    as_polars_lit(value)$cast(dtype)
  }
}
