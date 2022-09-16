scan_parquet = function(
  file,#: str | Path,
  n_rows = NULL,#: int | None = None,
  cache = TRUE,#: bool = True,
  parallel = c(
    "Auto", #default
    "None",
    "Columns", #Parallelize over the row groups
    "RowGroups"#Parallelize over the columns
  ), # Automatically determine over which unit to parallelize, This will choose the most occurring unit.
  rechunk = TRUE,#: bool = True,
  row_count_name = NULL,#: str | None = None,
  row_count_offset = 0L,#: int = 0,
  #storage_options,#: dict[str, object] | None = None, #seems fsspec specific
  low_memory = FALSE#: bool = False,
) {#-> LazyFrame

  parallel = parallel[1]
  if(!parallel %in% c("None","Columns","RowGroups","Auto")) {
    abort("unknown parallel strategy")
  }

  result_lf = minipolars:::new_from_parquet(
    path = file,
    n_rows = n_rows,
    cache = cache,
    parallel = parallel,
    rechunk = rechunk,
    row_name = row_count_name,
    row_count = row_count_offset,
    low_memory = low_memory
  )

  unwrap(result_lf)

}

#
# def _prepare_row_count_args(
#   row_count_name: str | None = None,
#   row_count_offset: int = 0,
# ) -> tuple[str, int] | None:
#   if row_count_name is not None:
#   return (row_count_name, row_count_offset)
# else:
#   return None
