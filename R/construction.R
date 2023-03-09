


#' #' to_struct and unnest again
#' #' @name pl$from_arrow
#' #' @param name name of new Series
#' #' @return @to_struct() returns a Series
#' #' @aliases to_struct
#' #' @keywords conversion
#' #' @examples
#' #' #none so for
#' arrow_to_pydf = function(at, schema = NULL, schema_overrides = NULL, rechunk = TRUE) {
#'
#'   data_dict = new.env(parent = emptyenv())
#'   dictionary_cols = new.env(parent = emptyenv())
#'   struct_cols = new.env(parent = emptyenv())
#'   col_names = make.unique(gsub("^$","column",at$ColumnNames()),"_")
#'
#'
#'   i_col = 0
#'   lapply(at$columns, function(column) {
#'     i_col <<- icol + 1
#'     column = coerce_arrow(column)
#'     if(is_arrow_dictonary(column)) {
#'
#'     }
#'
#'
#'   })
#'
#' }
#' arr = at$column(0)
#'
#' is_arrow_dictonary = \(x) {
#'   inherits(x$type,c("DictionaryType","FixedWidthType","DataType","ArrowObject","R6"))
#' }
#'
#'
coerce_arrow = function(arr, rechunk = TRUE)  {
  if (!is.null(arr$num_chunks) && arr$num_chunks > 1L && rechunk && is_arrow_dictonary(arr)) {
      #recast non ideal index types
      non_ideal_idx_types = list(arrow::int8(), arrow::uint8(), arrow::int16(),
                                 arrow::uint16(), arrow::int32())
      if (arr$type$index_type %in_list%  non_ideal_idx_types) {
        arr = arr$cast(arrow::dictionary(arrow::uint32(),arrow::large_utf8()))
        arr = as_arrow_array(arr) #combine chunks
      }
  }
  arr
}




# # """Construct a PySeries from an Arrow array."""
# arrow_to_rseries = function(name, values, rechunk = TRUE) {
#
#     array = coerce_arrow(values)
#
#     # special handling of empty categorical arrays
#     if (
#         length(array) == 0
#         && is_arrow_dictonary(array)
#         && array$type$value_type %in_list%
#           list(arrow::utf8(), arrow::large_utf8())
#     ) {
#       r_series = pl$lit(c())$cast(pl$Categorical)$lit_to_s()
#     } else {
#       r_series = .pr$Series$from_arrow(name, values)
#     }
#
#     ):
#         pys = pli.Series(name, [], dtype=Categorical)._s
#
#     elif not hasattr(array, "num_chunks"):
#         pys = PySeries.from_arrow(name, array)
#     else:
#         if array.num_chunks > 1:
#             # somehow going through ffi with a structarray
#             # returns the first chunk everytime
#             if isinstance(array.type, pa.StructType):
#                 pys = PySeries.from_arrow(name, array.combine_chunks())
#             else:
#                 it = array.iterchunks()
#                 pys = PySeries.from_arrow(name, next(it))
#                 for a in it:
#                     pys.append(PySeries.from_arrow(name, a))
#         elif array.num_chunks == 0:
#             pys = PySeries.from_arrow(name, pa.array([], array.type))
#         else:
#             pys = PySeries.from_arrow(name, array.chunks[0])
#
#         if rechunk:
#             pys.rechunk(in_place=True)
#
#     return pys
