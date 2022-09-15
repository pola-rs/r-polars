# scan_parquet = function(
#   file,#: str | Path,
#   n_rows,#: int | None = None,
#   cache,#: bool = True,
#   parallel = c(
#     "None",
#     "Columns", #Parallelize over the row groups
#     "RowGroups",#Parallelize over the columns
#     "Auto"
#   ), # Automatically determine over which unit to parallelize, This will choose the most occurring unit.
#   rechunk,#: bool = True,
#   row_count_name = NULL,#: str | None = None,
#   row_count_offset = 0,#: int = 0,
#   #storage_options,#: dict[str, object] | None = None, #seems fsspec specific
#   low_memory,#: bool = False,
# ) {#-> LazyFrame
#
#   parallel = parallel[1]
#   if(!parallel %in% c("None","Columns","RowGroups","Auto"))
#
#   print("not implemented yet")
# }
#
# #
# # def _prepare_row_count_args(
# #   row_count_name: str | None = None,
# #   row_count_offset: int = 0,
# # ) -> tuple[str, int] | None:
# #   if row_count_name is not None:
# #   return (row_count_name, row_count_offset)
# # else:
# #   return None
