# TODO: link to data frame docs
#' Create a Polars DataFrame from an R object
#'
#' The [as_polars_df()] function creates a Polars DataFrame from various R objects.
#' Polars DataFrame is based on a sequence of [Polars Series][polars_series],
#' so basically, the input object is converted to a [list] of
#' [Polars Series][polars_series] by [as_polars_series()],
#' then a Polars DataFrame is created from the list.
#'
#' The default method of [as_polars_df()] throws an error,
#' so we need to define methods for the classes we want to support.
#' @inheritParams as_polars_series
#' @return A Polars DataFrame
#' @seealso
#' - [`<DataFrame>$to_r_list()`][dataframe__to_r_list]: Export the DataFrame as an R list of R vectors.
#' @examples
#' # list
#' as_polars_df(list(a = 1:2, b = c("foo", "bar")))
#'
#' # data.frame
#' as_polars_df(data.frame(a = 1:2, b = c("foo", "bar")))
#' @export
as_polars_df <- function(x, ...) {
  UseMethod("as_polars_df")
}

#' @rdname as_polars_df
#' @export
as_polars_df.default <- function(x, ...) {
  abort(
    paste0("Unsupported class for `as_polars_df()`: ", toString(class(x))),
    call = parent.frame()
  )
}

#' @rdname as_polars_df
#' @export
as_polars_df.polars_data_frame <- function(x, ...) {
  x
}

#' @rdname as_polars_df
#' @export
as_polars_df.polars_group_by <- function(x, ...) {
  x$df
}

#' @rdname as_polars_df
#' @export
as_polars_df.polars_lazy_frame <- function(x, ...) {
  x$collect()
}

#' @rdname as_polars_df
#' @export
as_polars_df.list <- function(x, ...) {
  lapply(x, \(column) as_polars_series(column)$`_s`) |>
    PlRDataFrame$init() |>
    wrap()
}

#' @rdname as_polars_df
#' @export
as_polars_df.data.frame <- function(x, ...) {
  as.list(x) |>
    as_polars_df.list()
}
