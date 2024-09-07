#' Create a Polars DataFrame from an R object
#'
#' The [as_polars_df()] function creates a [polars DataFrame][DataFrame] from various R objects.
#' [Polars DataFrame][DataFrame] is based on a sequence of [Polars Series][Series],
#' so basically, the input object is converted to a [list] of
#' [Polars Series][Series] by [as_polars_series()],
#' then a [Polars DataFrame][DataFrame] is created from the list.
#'
#' The default method of [as_polars_df()] throws an error,
#' so we need to define methods for the classes we want to support.
#'
#' ## S3 method for [list]
#'
#' - The argument `...` (except `name`) is passed to [as_polars_series()] for each element of the list.
#' - All elements of the list must be converted to the same length of [Series] by [as_polars_series()].
#'
#' ## S3 method for [data.frame]
#'
#' - The argument `...` (except `name`) is passed to [as_polars_series()] for each column.
#' - All columns must be converted to the same length of [Series] by [as_polars_series()].
#'
#' ## S3 method for [polars_lazy_frame][LazyFrame]
#'
#' This is a shortcut for [`<LazyFrame>$collect()`][lazyframe__collect].
#' @inherit pl__DataFrame return
#' @inheritParams as_polars_series
#' @inheritParams lazyframe__collect
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
as_polars_df.polars_lazy_frame <- function(
    x, ..., type_coercion = TRUE,
    predicate_pushdown = TRUE,
    projection_pushdown = TRUE,
    simplify_expression = TRUE,
    slice_pushdown = TRUE,
    comm_subplan_elim = TRUE,
    comm_subexpr_elim = TRUE,
    cluster_with_columns = TRUE,
    no_optimization = FALSE,
    streaming = FALSE) {
  x$collect(
    type_coercion = type_coercion,
    predicate_pushdown = predicate_pushdown,
    projection_pushdown = projection_pushdown,
    simplify_expression = simplify_expression,
    slice_pushdown = slice_pushdown,
    comm_subplan_elim = comm_subplan_elim,
    comm_subexpr_elim = comm_subexpr_elim,
    cluster_with_columns = cluster_with_columns,
    streaming = streaming
  )
}

#' @rdname as_polars_df
#' @export
as_polars_df.list <- function(x, ...) {
  .args <- list2(...)
  # Should not pass the `name` argument
  .args$name <- NULL
  lapply(x, \(column) eval(call2("as_polars_series", column, !!!.args))$`_s`) |>
    PlRDataFrame$init() |>
    wrap()
}

#' @rdname as_polars_df
#' @export
as_polars_df.data.frame <- as_polars_df.list
