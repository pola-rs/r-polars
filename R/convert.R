
#' pl$from_arrow
#' @description import Arrow Table or Array
#' @name pl$from_arrow
#' @param data arrow Table or Array or ChunkedArray
#' @param rechunk bool rewrite in one array per column, Implemented for ChunkedArray
#' Array is already contiguous. Not implemented for Table. C
#' @param schema not used yet
#' @param schema_overrides not used yet
#' @return DataFrame or Series
#' @aliases from_arrow
#' @keywords conversion
#' @examples
#' #none so for
pl$from_arrow = function(data, rechunk= TRUE, schema = NULL, schema_overrides = NULL) {

  if(!requireNamespace("arrow", quietly = TRUE)) {
    stopf("in pl$from_arrow: cannot import from arrow without R package arrow installed")
  }

  ##dispatch conversion on data class
  f = (\() {
    #import as DataFrame
    if(
      identical(class(data),c("Table", "ArrowTabular", "ArrowObject", "R6")) ||
      identical(class(data),c("RecordBatchReader",     "ArrowObject", "R6" ))
    ) {
      #capture any error from arrow with result()
      record_batches = arrow::as_record_batch_reader(data)$batches()

      #convert
      df = unwrap(.pr$DataFrame$from_arrow_record_batches(record_batches))

      #rechunk via expr because not impl yet directly on DataFrame
      if(rechunk) df = df$select(pl$all()$rechunk())

      return(df)
    }

    #both Array and ChunkedArray
    if(identical(class(data)[-1L],c("ArrowDatum","ArrowObject","R6"))) {
       return(unwrap(arrow_to_rseries_result("", data, rechunk = rechunk)))
    }

    #no suitable method found, raise error
    stopf("arg [data] given class is not yet supported: %s", str_string(class(data)))
  })

  #add context to any errors
  unwrap(result(f()),"in pl$from_arrow:")
}
