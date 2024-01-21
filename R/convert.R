#' from_arrow
#'
#' Import Arrow Table or Array.
#' Deprecated in favor of [as_polars_df] and [as_polars_series].
#' Will be removed in 0.14.0.
#' @param data arrow Table or Array or ChunkedArray
#' @param ... Ignored.
#' @param rechunk bool rewrite in one array per column, Implemented for ChunkedArray
#' Array is already contiguous. Not implemented for Table. C
#' @param schema named list of DataTypes or char vec of names. Same length as arrow table.
#' If schema names or types do not match arrow table, the columns will be renamed/recast.
#' NULL default is to import columns as is. Takes no effect for Array or ChunkedArray
#' @param schema_overrides named list of DataTypes. Name some columns to recast by the DataType.
#' Takes not effect for Array or ChunkedArray
#' @return DataFrame or Series
#' @aliases from_arrow
#' @examples
#' pl$from_arrow(
#'   data = arrow::arrow_table(iris),
#'   schema_overrides = list(Sepal.Length = pl$Float32, Species = pl$String)
#' )
#'
#' char_schema = names(iris)
#' char_schema[1] = "Alice"
#' pl$from_arrow(
#'   data = arrow::arrow_table(iris),
#'   schema = char_schema
#' )
pl_from_arrow = function(
    data,
    ...,
    rechunk = TRUE,
    schema = NULL,
    schema_overrides = NULL) {
  warning("`pl$from_arrow()` is deprecated and will be removed in 0.14.0. Use `as_polars_df()` or `as_polars_series` insead.")

  if (!requireNamespace("arrow", quietly = TRUE)) {
    stop("in pl$from_arrow: cannot import from arrow without R package arrow installed")
  }

  ## dispatch conversion on data class
  f = (\() {
    # 1 import as DataFrame
    if (
      identical(class(data), c("Table", "ArrowTabular", "ArrowObject", "R6")) ||
        identical(class(data), c("RecordBatchReader", "ArrowObject", "R6"))
    ) {
      return(as_polars_df(data, rechunk = rechunk, schema = schema, schema_overrides = schema_overrides))
    }

    # 2 both Array and ChunkedArray
    if (identical(class(data)[-1L], c("ArrowDatum", "ArrowObject", "R6"))) {
      return(as_polars_series(data, rechunk = rechunk))
    }

    # 0 no suitable method found, raise error
    stop("arg [data] given class is not yet supported: %s", str_string(class(data)))
  })

  # add context to any errors
  unwrap(result(f()), "in pl$from_arrow:")
}
