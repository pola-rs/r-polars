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
#' @return a [DataFrame][DataFrame_class]
#' @examplesIf requireNamespace("arrow", quietly = TRUE)
#' # Convert the row names of a data frame to a column
#' as_polars_df(mtcars, rownames = "car")
#'
#' # Convert an arrow Table to a polars DataFrame
#' at = arrow::arrow_table(x = 1:5, y = 6:10)
#' as_polars_df(at)
#'
#' # Convert an arrow Table, with renaming all columns
#' as_polars_df(
#'   at,
#'   schema = c("a", "b")
#' )
#'
#' # Convert an arrow Table, with renaming and casting all columns
#' as_polars_df(
#'   at,
#'   schema = list(a = pl$Int64, b = pl$String)
#' )
#'
#' # Convert an arrow Table, with renaming and casting some columns
#' as_polars_df(
#'   at,
#'   schema_overrides = list(y = pl$String) # cast some columns
#' )
#'
#' # Create a polars DataFrame from a data.frame
#' lf = as_polars_df(mtcars)$lazy()
#'
#' # Collect all rows from the LazyFrame
#' as_polars_df(lf)
#'
#' # Fetch 5 rows from the LazyFrame
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
#' @param rownames How to treat existing row names of a data frame:
#'  - `NULL`: Remove row names. This is the default.
#'  - A string: The name of a new column, which will contain the row names.
#'    If `x` already has a column with that name, an error is thrown.
#' @param make_names_unique A logical flag to replace duplicated column names
#' with unique names. If `FALSE` and there are duplicated column names, an
#' error is thrown.
#' @export
as_polars_df.data.frame = function(x, ..., rownames = NULL, make_names_unique = TRUE) {
  if ((anyDuplicated(names(x)) > 0) && make_names_unique) {
    names(x) = make.unique(names(x), sep = "_")
  }

  if (is.null(rownames)) {
    pl$DataFrame(x, make_names_unique = FALSE)
  } else {
    uw = \(res) unwrap(res, "in as_polars_df():")

    if (length(rownames) != 1L || !is.character(rownames) || is.na(rownames)) {
      Err_plain("`rownames` must be a single string, or `NULL`") |>
        uw()
    }

    if (rownames %in% names(x)) {
      Err_plain(
        sprintf(
          "The column name '%s' is already used. Please choose a different name for the `rownames` argument.",
          rownames
        )
      ) |>
        uw()
    }

    old_rownames = raw_rownames(x)
    if (length(old_rownames) > 0 && is.na(old_rownames[1L])) {
      # if implicit rownames
      old_rownames = seq_len(abs(old_rownames[2L]))
    }
    old_rownames = as.character(old_rownames)

    pl$concat(
      pl$Series(old_rownames, name = rownames),
      pl$DataFrame(x, make_names_unique = FALSE),
      how = "horizontal"
    )
  }
}


#' @rdname as_polars_df
#' @export
as_polars_df.RPolarsDataFrame = function(x, ...) {
  x
}


#' @rdname as_polars_df
#' @export
as_polars_df.RPolarsGroupBy = function(x, ...) {
  x$ungroup()
}

#' @rdname as_polars_df
#' @export
as_polars_df.RPolarsRollingGroupBy = as_polars_df.RPolarsGroupBy

#' @rdname as_polars_df
#' @export
as_polars_df.RPolarsDynamicGroupBy = as_polars_df.RPolarsGroupBy

#' @rdname as_polars_df
#' @export
as_polars_df.RPolarsSeries = function(x, ...) {
  pl$DataFrame(x)
}


#' @rdname as_polars_df
#' @param n_rows Number of rows to fetch. Defaults to `Inf`, meaning all rows.
#' @inheritParams LazyFrame_collect
#' @export
as_polars_df.RPolarsLazyFrame = function(
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
#' @export
as_polars_df.RPolarsLazyGroupBy = function(x, ...) {
  as_polars_df.RPolarsLazyFrame(x$ungroup(), ...)
}


# TODO: link to DataTypes documents
#' @rdname as_polars_df
#' @param rechunk A logical flag (default `TRUE`).
#' Make sure that all data of each column is in contiguous memory.
#' @param schema named list of DataTypes, or character vector of column names.
#' Should be the same length as the number of columns of `x`.
#' If schema names or types do not match `x`, the columns will be renamed/recast.
#' If `NULL` (default), convert columns as is.
#' @param schema_overrides named list of DataTypes. Cast some columns to the DataType.
#' @export
as_polars_df.ArrowTabular = function(
    x,
    ...,
    rechunk = TRUE,
    schema = NULL,
    schema_overrides = NULL) {
  arrow_to_rdf(
    x,
    rechunk = rechunk,
    schema = schema,
    schema_overrides = schema_overrides
  )
}


# TODO: as_polars_df.nanoarrow_array_stream


#' To polars LazyFrame
#'
#' [as_polars_lf()] is a generic function that converts an R object to a
#' polars LazyFrame. It is basically a shortcut for [as_polars_df(x, ...)][as_polars_df] with the
#' [$lazy()][DataFrame_lazy] method.
#' @rdname as_polars_lf
#' @inheritParams as_polars_df
#' @return a [LazyFrame][LazyFrame_class]
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
as_polars_lf.RPolarsLazyFrame = function(x, ...) {
  x
}


#' @rdname as_polars_lf
#' @export
as_polars_lf.RPolarsLazyGroupBy = function(x, ...) {
  x$ungroup()
}


#' To polars Series
#'
#' [as_polars_series()] is a generic function that converts an R object to a
#' polars Series. It is basically a wrapper for [pl$Series()][pl_Series].
#' @param x Object to convert into a polars Series
#' @param name A string to use as the name of the Series.
#' If `NULL` (default), the name of `x` is used or an unnamed Series is created.
#' @inheritParams as_polars_df
#' @return a [Series][Series_class]
#' @export
#' @examples
#' as_polars_series(1:4)
#'
#' as_polars_series(list(1:4))
#'
#' as_polars_series(data.frame(a = 1:4))
#'
#' as_polars_series(pl$Series(1:4, name = "foo"))
#'
#' as_polars_series(pl$lit(1:4))
as_polars_series = function(x, name = NULL, ...) {
  UseMethod("as_polars_series")
}


#' @rdname as_polars_series
#' @export
as_polars_series.default = function(x, name = NULL, ...) {
  pl$Series(x, name = name)
}


#' @rdname as_polars_series
#' @export
as_polars_series.RPolarsSeries = function(x, name = NULL, ...) {
  x$alias(name %||% x$name)
}


#' @rdname as_polars_series
#' @export
as_polars_series.RPolarsExpr = function(x, name = NULL, ...) {
  as_polars_series(pl$select(x)$to_series(0), name = name)
}


#' @rdname as_polars_series
#' @export
as_polars_series.POSIXlt = function(x, name = NULL, ...) {
  as_polars_series(as.POSIXct(x), name = name)
}


#' @rdname as_polars_series
#' @export
as_polars_series.data.frame = function(x, name = NULL, ...) {
  pl$DataFrame(unclass(x))$to_struct(name = name)
}


#' @rdname as_polars_series
#' @export
as_polars_series.vctrs_rcrd = as_polars_series.data.frame


#' @rdname as_polars_series
#' @param rechunk A logical flag (default `TRUE`). Make sure that all data is in contiguous memory.
#' @export
as_polars_series.Array = function(x, name = NULL, ..., rechunk = TRUE) {
  arrow_to_rseries_result(name = name %||% "", values = x, rechunk = rechunk) |>
    unwrap()
}


#' @rdname as_polars_series
#' @export
as_polars_series.ChunkedArray = as_polars_series.Array


#' @rdname as_polars_series
#' @export
as_polars_series.nanoarrow_array = function(x, name = NULL, ...) {
  # TODO: support 0-length array
  .pr$Series$from_arrow_array_robj(name %||% "", x) |>
    unwrap()
}


#' @rdname as_polars_series
#' @export
as_polars_series.nanoarrow_array_stream = function(x, name = NULL, ...) {
  on.exit(x$release())

  list_of_arrays = nanoarrow::collect_array_stream(x, validate = FALSE)

  if (length(list_of_arrays) < 1L) {
    # TODO: support 0-length array stream
    out = pl$Series(NULL, name = name)
  } else {
    out = as_polars_series.nanoarrow_array(list_of_arrays[[1L]], name = name)
    if (length(list_of_arrays) > 1L) {
      for (array in list_of_arrays[-1L]) {
        out = out$append_mut(as_polars_series.nanoarrow_array(array))
      }
    }
  }

  out
}
