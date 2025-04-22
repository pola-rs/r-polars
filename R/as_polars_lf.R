# TODO: link to dataframe__lazy
#' Create a Polars LazyFrame from an R object
#'
#' The [as_polars_lf()] function creates a [LazyFrame] from various R objects.
#' It is basically a shortcut for [as_polars_df(x, ...)][as_polars_df] with the
#' `$lazy()`method.
#'
#' ## Default S3 method
#'
#' Create a [DataFrame] by calling [as_polars_df()] and then create
#' a [LazyFrame] from the [DataFrame].
#' Additional arguments `...` are passed to [as_polars_df()].
#' @inherit pl__LazyFrame return
#' @inheritParams as_polars_df
#' @export
as_polars_lf <- function(x, ...) {
  UseMethod("as_polars_lf")
}

#' @rdname as_polars_lf
#' @export
as_polars_lf.default <- function(x, ...) {
  try_fetch(
    as_polars_df(x, ...)$lazy(),
    error = function(cnd) {
      abort(
        "Failed to create a polars LazyFrame.",
        parent = cnd
      )
    }
  )
}

#' @rdname as_polars_lf
#' @export
as_polars_lf.polars_lazy_frame <- function(x, ...) {
  x
}
