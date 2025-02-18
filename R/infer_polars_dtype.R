# TODO: link to the type mapping vignette
#' Infer Polars DataType corresponding to a given R object
#'
#' This function is a helper function used to quickly find the [DataType] corresponding to an R object.
#' In many cases, this function simply performs something like [`as_polars_series(x[0])`][as_polars_series].
#' It is much faster than actually constructing a [Series] using the entire object.
#' This function is similar to [nanoarrow::infer_nanoarrow_schema()].
#'
#' S3 objects based on atomic vectors or classes built on the vctrs package will work accurately
#' if the S3 method of the [as_polars_series] function is defined.
#' @inheritParams as_polars_series
#' @param x An R object.
#' @return A [polars DataType][DataType]
#' @seealso
#' - [as_polars_series()]
#' @examples
#' infer_polars_dtype(1:10)
#'
#' # The type inference is fast even if the object is huge
#' infer_polars_dtype(1:100000000)
#' @export
infer_polars_dtype <- function(x, ...) {
  UseMethod("infer_polars_dtype")
}

infer_polars_dtype_default_impl <- function(x, ...) {
  as_polars_series(x[0L]) |>
    infer_polars_dtype(...)
}

#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.default <- function(x, ...) {
  if (is.atomic(x)) {
    infer_polars_dtype_default_impl(x, ...)
  } else {
    abort(
      sprintf("Unsupported class for `infer_polars_dtype()`: %s", toString(class(x))),
      call = parent.frame()
    )
  }
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

#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.polars_lazy_frame <- infer_polars_dtype.polars_data_frame

#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.POSIXlt <- infer_polars_dtype_default_impl

#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.NULL <- function(x, ...) {
  if (missing(x)) {
    abort("The `x` argument of `infer_polars_dtype()` can't be missing")
  }
  pl$Null
}

#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.list <- function(x, ..., strict = FALSE) {
  lapply(x, \(child) {
    if (is.null(child)) {
      NULL
    } else {
      infer_polars_dtype(child, ..., strict = strict)$`_dt`
    }
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

# To avoid defining a dedicated method for inferring from classes built on vctrs_vctr,
# the processing is done in this method by if branching.
#' @rdname infer_polars_dtype
#' @export
infer_polars_dtype.vctrs_vctr <- function(x, ...) {
  dtype_from_sliced <- infer_polars_dtype_default_impl(x, ...)

  if (dtype_from_sliced$is_nested()) {
    # Nested type may multiple nested, so we can't infer type from the slice
    if (inherits(dtype_from_sliced, "polars_dtype_struct")) {
      # Struct
      infer_polars_dtype_vctrs_rcrd_impl(x, ...)
    } else {
      # List or Array
      infer_polars_dtype.list(x, ...)
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
