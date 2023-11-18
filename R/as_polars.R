#' To polars DataFrame
#'
#' [as_polars_df()] is a generic function that converts an R object to a
#' polars DataFrame. It is basically a wrapper for [pl$DataFrame()][pl_DataFrame],
#' but has special implementations for Apache Arrow-based objects such as
#' polars [LazyFrame][LazyFrame_class] and [arrow::Table].
#'
#' For [LazyFrame][LazyFrame_class] objects, this function is a shortcut for
#' [$collect()][LazyFrame_collect] or [$fetch()][LazyFrame_fetch], depending on
#' whether the number of rows to fetch is infinite or not.
#' @rdname as_polars_df
#' @param x Object to convert to a polars DataFrame.
#' @param ... Additional arguments passed to methods.
#' @examplesIf requireNamespace("arrow", quietly = TRUE)
#' at = arrow::as_arrow_table(mtcars)
#'
#' # Convert an arrow Table to a polars LazyFrame
#' lf = as_polars_df(at)$lazy()
#'
#' # Collect all rows
#' as_polars_df(lf)
#'
#' # Fetch 5 rows
#' as_polars_df(lf, 5)
#' @export
as_polars_df = function(x, ...) {
  UseMethod("as_polars_df")
}


#' @rdname as_polars_df
#' @export
as_polars_df.default = function(x, ...) {
  as_polars_df(as.data.frame(x, stringsAsFactors = FALSE), ...)
}


#' @rdname as_polars_df
#' @export
as_polars_df.data.frame = function(x, ...) {
  pl$DataFrame(x)
}


#' @rdname as_polars_df
#' @export
as_polars_df.DataFrame = function(x, ...) {
  x
}


#' @rdname as_polars_df
#' @export
as_polars_df.GroupBy = function(x, ...) {
  x$to_data_frame()
}


#' @rdname as_polars_df
#' @export
as_polars_df.Series = function(x, ...) {
  pl$DataFrame(x)
}


#' @rdname as_polars_df
#' @param n_rows Number of rows to fetch. Defaults to `Inf`, meaning all rows.
#' @inheritParams LazyFrame_collect
#' @export
as_polars_df.LazyFrame = function(
    x,
    n_rows = Inf,
    ...,
    type_coercion = TRUE,
    predicate_pushdown = TRUE,
    projection_pushdown = TRUE,
    simplify_expression = TRUE,
    slice_pushdown = TRUE,
    comm_subplan_elim = TRUE,
    comm_subexpr_elim = TRUE,
    streaming = FALSE,
    no_optimization = FALSE,
    inherit_optimization = FALSE,
    collect_in_background = FALSE) {
  # capture all args and modify some to match lower level function
  args = as.list(environment())
  args$... = list(...)

  if (is.infinite(args$n_rows)) {
    args$n_rows = NULL
    .fn = x$collect
  } else {
    args$collect_in_background = NULL
    .fn = x$fetch
  }

  args$x = NULL
  check_no_missing_args(.fn, args)
  do.call(.fn, args)
}


#' @rdname as_polars_df
#' @inheritParams pl_from_arrow
#' @export
as_polars_df.ArrowTabular = function(
    x,
    ...,
    rechunk = TRUE,
    schema = NULL,
    schema_overrides = NULL) {
  pl$from_arrow(
    x,
    ...,
    rechunk = rechunk,
    schema = schema,
    schema_overrides = schema_overrides
  )
}


#' @rdname as_polars_df
#' @export
as_polars_df.RecordBatchReader = as_polars_df.ArrowTabular


# TODO: as_polars_df.nanoarrow_array_stream


#' To polars LazyFrame
#'
#' [as_polars_lf()] is a generic function that converts an R object to a
#' polars LazyFrame. It is basically a shortcut for [as_polars_df(x, ...)][as_polars_df] with the
#' [$lazy()][DataFrame_lazy] method.
#' @rdname as_polars_lf
#' @inheritParams as_polars_df
#' @examples
#' as_polars_lf(mtcars)
#' @export
as_polars_lf = function(x, ...) {
  UseMethod("as_polars_lf")
}


#' @rdname as_polars_lf
#' @export
as_polars_lf.default = function(x, ...) {
  as_polars_df(x, ...)$lazy()
}


#' @rdname as_polars_lf
#' @export
as_polars_lf.LazyFrame = function(x, ...) {
  x
}
