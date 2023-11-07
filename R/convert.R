#' from_arrow
#' @description import Arrow Table or Array
#' @name pl_from_arrow
#' @param data arrow Table or Array or ChunkedArray
#' @param rechunk bool rewrite in one array per column, Implemented for ChunkedArray
#' Array is already contiguous. Not implemented for Table. C
#' @param schema named list of DataTypes or char vec of names. Same length as arrow table.
#' If schema names or types do not match arrow table, the columns will be renamed/recast.
#' NULL default is to import columns as is. Takes no effect for Array or ChunkedArray
#' @param schema_overrides named list of DataTypes. Name some columns to recast by the DataType.
#' Takes not effect for Array or ChunkedArray
#' @return DataFrame or Series
#' @aliases from_arrow
#' @keywords pl
#' @examples
#' pl$from_arrow(
#'   data = arrow::arrow_table(iris),
#'   schema_overrides = list(Sepal.Length = pl$Float32, Species = pl$Utf8)
#' )
#'
#' char_schema = names(iris)
#' char_schema[1] = "Alice"
#' pl$from_arrow(
#'   data = arrow::arrow_table(iris),
#'   schema = char_schema
#' )
pl$from_arrow = function(data, rechunk = TRUE, schema = NULL, schema_overrides = NULL) {
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
      df = arrow_to_rdf(
        data,
        rechunk = rechunk, schema = schema, schema_overrides = schema_overrides
      )
      return(df)
    }

    # 2 both Array and ChunkedArray
    if (identical(class(data)[-1L], c("ArrowDatum", "ArrowObject", "R6"))) {
      return(unwrap(arrow_to_rseries_result("", data, rechunk = rechunk)))
    }

    # 0 no suitable method found, raise error
    stop("arg [data] given class is not yet supported: %s", str_string(class(data)))
  })

  # add context to any errors
  unwrap(result(f()), "in pl$from_arrow:")
}
