# TODO: link to the type mapping vignette
#' Infer Polars DataType corresponding to a given R object
#'
#' @description
#' [infer_polars_dtype()] is a helper function used to quickly find the [DataType] corresponding to an R object,
#' in order words, it infers the type of the Polars [Series] that would be constructed from the object.
#' In many cases, this function simply performs something like `head(x, 0) |> as_polars_series()`.
#' It is much faster than actually constructing a [Series] using the entire object.
#' This function is similar to [nanoarrow::infer_nanoarrow_schema()].
#'
#' [is_convertible_to_polars_series()] and [is_convertible_to_polars_expr()] are helper functions
#' that check if the object can be converted to a [Series] or [Expr] respectively.
#' These functions call [infer_polars_dtype()] internally and return `TRUE` if the type can be inferred without error.
#' (Or, that object is already a Polars [Expr] for [is_convertible_to_polars_expr()].)
#' @details
#' S3 objects based on atomic vectors or classes built on [the vctrs package][vctrs::vctrs-package]
#' will work accurately if the S3 method of the [as_polars_series()] function is defined.
#' @inheritParams as_polars_series
#' @param x An R object.
#' @return A [polars DataType][DataType]
#' @seealso
#' - [as_polars_series()]
#' - [check_polars]: Functions to check if the object is a polars object.
#' @examples
#' infer_polars_dtype(1:10)
#'
#' # The type inference is also fast for objects
#' # that would take a long time to construct a Series.
#' infer_polars_dtype(1:100000000)
#'
#' # For lists, it is not possible to infer the type
#' # without inspecting all elements.
#' # However, this function can be configured to inspect only a few elements
#' # via the `infer_dtype_length` argument.
#' # If a sufficient length is specified, the correct type can be inferred.
#' # (By default, the length is set to 10.)
#' mixed_list <- list(1, NULL, "foo")
#' infer_polars_dtype(mixed_list)
#' infer_polars_dtype(mixed_list, infer_dtype_length = 2)
#'
#' # But if the length is too short, an incorrect type may be inferred.
#' infer_polars_dtype(mixed_list, infer_dtype_length = 1)
#'
#' # is_convertible_to_polars_* functions are useful for checking if
#' # the object can be converted to a Series or Expr quickly.
#' try(infer_polars_dtype(1i))
#' is_convertible_to_polars_series(1i)
#' is_convertible_to_polars_expr(1i)
#'
#' # For polars Expr objects, infer_polars_dtype() will raise an error
#' # because Expr can't be converted to a Series by `as_polars_series()`.
#' try(infer_polars_dtype(pl$lit(1)))
#' is_convertible_to_polars_series(pl$lit(1))
#' is_convertible_to_polars_expr(pl$lit(1))
#' @export
infer_polars_dtype <- function(x, ...) {
  UseMethod("infer_polars_dtype")
}

#' @rdname infer_polars_dtype
#' @export
is_convertible_to_polars_series <- function(x, ...) {
  tryCatch(
    {
      infer_polars_dtype(x, ...)
      TRUE
    },
    error = function(e) FALSE
  )
}

#' @rdname infer_polars_dtype
#' @export
is_convertible_to_polars_expr <- function(x, ...) {
  is_polars_expr(x) || is_convertible_to_polars_series(x, ...)
}

infer_polars_dtype_default_impl <- function(x, ...) {
  as_polars_series(x[0L]) |>
    infer_polars_dtype(...)
}

#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.default <- function(x, ...) {
  try_fetch(
    infer_polars_dtype_default_impl(x, ...),
    error = function(cnd) {
      abort(
        sprintf("Unsupported class for `infer_polars_dtype()`: %s", toString(class(x))),
        call = parent.frame(),
        parent = cnd
      )
    }
  )
}

#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.polars_series <- function(x, ...) {
  x$dtype
}

#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.polars_data_frame <- function(x, ...) {
  pl$Struct(!!!x$collect_schema())
}

# This is only used for showing the special error message.
# So, this method is not documented.
#' @export
infer_polars_dtype.polars_expr <- function(x, name = NULL, ...) {
  abort(
    c(
      "passing polars expression objects to `infer_polars_dtype()` is not supported.",
      i = "You may want to eval the expression with `pl$select()` first."
    )
  )
}

#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.polars_lazy_frame <- infer_polars_dtype.polars_data_frame

#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.NULL <- function(x, ...) {
  if (missing(x)) {
    abort("The `x` argument of `infer_polars_dtype()` can't be missing")
  }
  pl$Null
}

#' @rdname infer_polars_dtype
#' @param infer_dtype_length The number of non-`NULL` elements to use for type inference.
#' Must be a single positive integer-ish value. The default is `10`.
#' If you want to infer the type of the entire list, set this to `Inf`,
#' but be aware that it may be slow.
#' @export
infer_polars_dtype.list <- function(x, ..., strict = FALSE, infer_dtype_length = 10L) {
  if (!(is_scalar_integerish(infer_dtype_length) && isTRUE(infer_dtype_length > 0L))) {
    abort("`infer_dtype_length` must be a single positive integer-ish value")
  }

  Filter(Negate(is.null), x) |>
    head(infer_dtype_length) |>
    lapply(\(child) {
      infer_polars_dtype(
        child,
        ...,
        strict = strict,
        infer_dtype_length = infer_dtype_length
      )$`_dt`
    }) |>
    PlRDataType$infer_supertype(strict = strict) |>
    PlRDataType$new_list() |>
    wrap()
}

#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.AsIs <- function(x, ...) {
  class(x) <- setdiff(class(x), "AsIs")
  infer_polars_dtype(x, ...)
}

#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.data.frame <- function(x, ...) {
  pl$Struct(!!!lapply(x, \(col) infer_polars_dtype(col, ...)))
}

#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.nanoarrow_array_stream <- function(x, ...) {
  wrap({
    na_schema <- nanoarrow::infer_nanoarrow_schema(x)
    empty_stream <- nanoarrow::basic_array_stream(list(), na_schema)
    as_polars_series(empty_stream)$dtype
  })
}

#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.nanoarrow_array <- infer_polars_dtype.nanoarrow_array_stream

# To avoid defining a dedicated method for inferring types from classes built on vctrs_vctr,
# the processing is handled within this method using conditional branching.
#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.vctrs_vctr <- function(x, ...) {
  dtype_from_sliced <- infer_polars_dtype_default_impl(x, ...)

  if (dtype_from_sliced$is_nested()) {
    # Nested type may be nested multiple times,
    # so we can't infer type from the slice
    if (inherits(x, "vctrs_rcrd")) {
      # vctrs_rcrd
      infer_polars_dtype_vctrs_rcrd_impl(x, ...)
    } else {
      # list_of
      child_type <- infer_polars_dtype(attr(x, "ptype"), ...)
      if (child_type$is_nested()) {
        NextMethod()
      } else {
        # If not nested `list_of()`, recursive solution is not needed
        pl$List(child_type)
      }
    }
  } else {
    dtype_from_sliced
  }
}

infer_polars_dtype_vctrs_rcrd_impl <- function(x, ...) {
  field_names <- vctrs::fields(x)
  inner_dtypes <- field_names |>
    lapply(\(field_name) {
      vctrs::field(x, field_name) |>
        infer_polars_dtype(...)
    })

  pl$Struct(!!!structure(inner_dtypes, names = field_names))
}
