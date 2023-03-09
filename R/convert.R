
#' to_struct and unnest again
#' @name pl$from_arrow
#' @param name name of new Series
#' @return @to_struct() returns a Series
#' @aliases to_struct
#' @keywords conversion
#' @examples
#' #none so for
pl$from_arrow = function(data, rechunk, schema, schema_overrides) {

  if(!requireNamespace("arrow", quietly = TRUE)) {
    stopf("in pl$from_arrow: cannot import from arrow without R package arrow installed")
  }

  #import as DataFrame
  if(inherits(data,c("Table", "ArrowTabular", "ArrowObject", "R6"))) {
     record_batces = arrow::as_record_batch_reader(data)$batches()
     unwrap(.pr$DataFrame$from_arrow_record_batches(record_batces))
  }

}
