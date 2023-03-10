
# arrow_to_pydf = function(at, schema = NULL, schema_overrides = NULL, rechunk = TRUE) {
#
#   data_dict = new.env(parent = emptyenv())
#   dictionary_cols = new.env(parent = emptyenv())
#   struct_cols = new.env(parent = emptyenv())
#   col_names = make.unique(gsub("^$","column",at$ColumnNames()),"_")
#
#
#   i_col = 0
#   lapply(at$columns, function(column) {
#     i_col <<- i_col + 1
#     column = coerce_arrow(column)
#     if(is_arrow_dictonary(column)) {
#
#     }
#
#
#   })
#
# }


is_arrow_dictonary = \(x) {
  inherits(x$type,c("DictionaryType","FixedWidthType","DataType","ArrowObject","R6"))
}

coerce_arrow = function(arr, rechunk = TRUE)  {
  if (!is.null(arr$num_chunks) && arr$num_chunks > 1L && rechunk && is_arrow_dictonary(arr)) {
      #recast non ideal index types
      non_ideal_idx_types = list(arrow::int8(), arrow::uint8(), arrow::int16(),
                                 arrow::uint16(), arrow::int32())
      if (arr$type$index_type %in_list%  non_ideal_idx_types) {
        arr = arr$cast(arrow::dictionary(arrow::uint32(),arrow::large_utf8()))
        arr = arrow::as_arrow_array(arr) #combine chunks
      }
  }
  arr
}




arrow_to_rseries_result = function(name, values, rechunk = TRUE) {

    ##must rechunk
    array = coerce_arrow(values)

    # special handling of empty categorical arrays
    if (
        length(array) == 0 &&
        is_arrow_dictonary(array) &&
        array$type$value_type %in_list% list(arrow::utf8(), arrow::large_utf8())
    ) {
      return(Ok(pl$lit(c())$cast(pl$Categorical)$lit_to_s()))
    }

    # rechunk immediately before import
    rseries_result = if((array$num_chunks %||% 1L ) <= 1L) {
      .pr$Series$from_arrow(name, array)
    } else {
      chunks = array$chunks
      s_res = .pr$Series$from_arrow(name,chunks[[1]])
      for(i in chunks[-1L]) {
        s_res = and_then(s_res, \(s) {
          .pr$Series$append_mut(s,pl$from_arrow(i)) |> map(\(x) s)
        })
      }
      s_res
    }

    rseries_result |> map(\(s) {
      if(rechunk) wrap_e(s)$rechunk()$lit_to_s() else s
    })
}
