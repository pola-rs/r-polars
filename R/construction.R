arrow_to_rdf = function(at, schema = NULL, schema_overrides = NULL, rechunk = TRUE) {
  # new column names by schema, #todo get names if schema not NULL
  original_schema = schema
  new_schema = unpack_schema(
    schema = schema %||% at$ColumnNames(),
    schema_overrides = schema_overrides
  )
  col_names = names(new_schema)

  if (length(col_names) != at$num_columns) stopf("schema length does not match arrow table")


  # store special translated columns here
  special_cols = new.env(parent = emptyenv())

  ## iter over columns, possibly do special conversion
  i_col = 0
  for (column in at$columns) {
    i_col = i_col + 1
    name = col_names[i_col]
    if (is_arrow_dictonary(column)) {
      column = coerce_arrow(column)
      special_cols[[name]] = unwrap(arrow_to_rseries_result(name, column, rechunk))
    } else if (is_arrow_struct(column) && has_multiple_chunks(column)) {
      special_cols[[name]] = unwrap(arrow_to_rseries_result(name, column, rechunk))
    } # else do nothing
  }

  # drop already converted columns
  at_new = at$SelectColumns(which(!names(at) %in% names(special_cols)) - 1L)

  # convert remaining to polars DataFrame and rechunk
  record_batches = arrow::as_record_batch_reader(at_new)$batches()
  df = unwrap(.pr$DataFrame$from_arrow_record_batches(record_batches))
  if (rechunk) {
    df = df$select(pl$all()$rechunk())
  }
  df$columns = setdiff(col_names, names(special_cols))

  # add back in special coversions and reorder by col_names
  if (length(names(special_cols))) {
    df = df$with_columns(
      unname(lapply(special_cols, \(s) pl$lit(s)$alias(s$name)))
    )$select(
      pl$col(col_names)
    )
  }

  # update column names
  df$columns = col_names

  # cast any imported arrow fields not matching schema
  cast_these_fields = mapply(
    new_schema,
    df$schema,
    FUN = \(new_field, df_field)  {
      if (is.null(new_field) || new_field == df_field) NULL else new_field
    },
    SIMPLIFY = FALSE
  ) |> (\(l) l[!sapply(l, is.null)])()

  if (length(cast_these_fields)) {
    df = df$with_columns(
      mapply(
        cast_these_fields,
        names(cast_these_fields),
        FUN = \(dtype, name) pl$col(name)$cast(dtype),
        SIMPLIFY = FALSE
      ) |> unname()
    )
  }

  df
}

unpack_schema = function(
    schema = NULL, # char vector of names or 'schema' a named list of DataTypes
    schema_overrides = NULL # named list of DataTypes
    # n_expected = NULL,
    # lookup_names = NULL,
    # include_overrides_in_columns = FALSE,
    ) { # -> list(char_vec_names, new_schema)


  schema = wrap_proto_schema(schema)
  if (is.null(schema_overrides)) {
    return(schema)
  }
  schema_overides = wrap_proto_schema(schema_overrides)

  # check for unknown columns
  if (!all(names(schema_overides) %in% names(schema))) {
    unknowns = names(schema_overides)[!names(schema_overides) %in% schema]
    stopf("schema_overrides cannot override missing unknown column(s): %s", str_string(unknowns))
  }

  # inject overriding definitions
  schema[names(schema_overides)] = schema_overides

  schema
}



is_arrow_dictonary = \(x) {
  identical(class(x$type), c("DictionaryType", "FixedWidthType", "DataType", "ArrowObject", "R6"))
}

is_arrow_struct = \(x) {
  identical(class(x$type), c("StructType", "NestedType", "DataType", "ArrowObject", "R6"))
}

has_multiple_chunks = \(x) {
  (x$num_chunks %||% -1L) > 1L
}




coerce_arrow = function(arr, rechunk = TRUE) {
  if (!is.null(arr$num_chunks) && is_arrow_dictonary(arr)) {
    # recast non ideal index types
    non_ideal_idx_types = list(
      arrow::int8(), arrow::uint8(), arrow::int16(),
      arrow::uint16(), arrow::int32()
    )
    if (arr$type$index_type %in_list% non_ideal_idx_types) {
      arr = arr$cast(arrow::dictionary(arrow::uint32(), arrow::large_utf8()))
      arr = arrow::as_arrow_array(arr) # combine chunks
    }
  }
  arr
}



arrow_to_rseries_result = function(name, values, rechunk = TRUE) {
  ## must rechunk
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
  rseries_result = if ((array$num_chunks %||% 1L) <= 1L) {
    .pr$Series$from_arrow(name, array)
  } else {
    chunks = array$chunks
    s_res = .pr$Series$from_arrow(name, chunks[[1]])
    for (i in chunks[-1L]) {
      s_res = and_then(s_res, \(s) {
        .pr$Series$append_mut(s, pl$from_arrow(i)) |> map(\(x) s)
      })
    }
    s_res
  }

  rseries_result |> map(\(s) {
    if (rechunk) wrap_e(s)$rechunk()$lit_to_s() else s
  })
}
