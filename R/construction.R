#' Internal function of `as_polars_df()` for `arrow::Table` class objects.
#'
#' This is a copy of Python Polars' `arrow_to_pydf` function.
#' @param at arrow::ArrowTabular (arrow::Table and arrow::RecordBatch)
#' @param rechunk A logical flag (default `TRUE`).
#' Make sure that all data of each column is in contiguous memory.
#' @param schema named list of DataTypes, or character vector of column names.
#' Should be the same length as the number of columns of `x`.
#' If schema names or types do not match `x`, the columns will be renamed/recast.
#' If `NULL` (default), convert columns as is.
#' @param schema_overrides named list of DataTypes. Cast some columns to the DataType.
#' @noRd
#' @return RPolarsDataFrame
arrow_to_rpldf = function(at, schema = NULL, schema_overrides = NULL, rechunk = TRUE) {
  # new column names by schema, #todo get names if schema not NULL
  n_cols = at$num_columns

  new_schema = unpack_schema(
    schema = schema %||% names(at),
    schema_overrides = schema_overrides
  )
  col_names = names(new_schema)

  if (length(col_names) != n_cols) stop("schema length does not match column length")

  data_cols = list()
  # dictionaries cannot be built in different batches (categorical does not allow
  # that) so we rechunk them and create them separately.
  # struct columns don't work properly if they contain multiple chunks.
  special_cols = list()

  ## iter over columns, possibly do special conversion
  for (i in seq_len(n_cols)) {
    column = at$column(i - 1L)
    col_name = col_names[i]

    if (is_arrow_dictionary(column)) {
      column = coerce_arrow(column)
      special_cols[[col_name]] = as_polars_series.ChunkedArray(column, col_name, rechunk = rechunk)
    } else if (is_arrow_struct(column) && column$num_chunks > 1L) {
      special_cols[[col_name]] = as_polars_series.ChunkedArray(column, col_name, rechunk = rechunk)
    } else {
      data_cols[[col_name]] = column
    }
  }

  if (length(data_cols)) {
    tbl = do.call(arrow::arrow_table, data_cols)

    if (tbl$num_rows == 0L) {
      rdf = pl$DataFrame() # TODO: support creating 0-row DataFrame
    } else {
      rdf = unwrap(
        .pr$DataFrame$from_arrow_record_batches(arrow::as_record_batch_reader(tbl)$batches())
      )
    }
  } else {
    rdf = pl$DataFrame()
  }

  if (rechunk) {
    rdf = rdf$select(pl$all()$rechunk())
  }

  if (length(special_cols)) {
    rdf = rdf$with_columns(
      unname(lapply(special_cols, \(s) pl$lit(s)$alias(s$name)))
    )$select(
      pl$col(col_names)
    )
  }

  # cast any imported arrow fields not matching schema
  cast_these_fields = mapply(
    new_schema,
    rdf$schema,
    FUN = \(new_field, df_field)  {
      if (is.null(new_field) || new_field == df_field) NULL else new_field
    },
    SIMPLIFY = FALSE
  ) |> (\(l) l[!sapply(l, is.null)])()

  if (length(cast_these_fields)) {
    rdf = rdf$with_columns(
      mapply(
        cast_these_fields,
        names(cast_these_fields),
        FUN = \(dtype, name) pl$col(name)$cast(dtype),
        SIMPLIFY = FALSE
      ) |> unname()
    )
  }

  rdf
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
    stop("schema_overrides cannot override missing unknown column(s): %s", str_string(unknowns))
  }

  # inject overriding definitions
  schema[names(schema_overides)] = schema_overides

  schema
}

#' @param x An [arrow::Array], [arrow::ChunkedArray]
#' @noRd
is_arrow_dictionary = function(x) {
  all(inherits(x, c("ArrowObject", "R6"), which = TRUE) > 0) &&
    identical(class(x$type), c("DictionaryType", "FixedWidthType", "DataType", "ArrowObject", "R6"))
}

#' @param x An [arrow::Array], [arrow::ChunkedArray]
#' @noRd
is_arrow_struct = function(x) {
  all(inherits(x, c("ArrowObject", "R6"), which = TRUE) > 0) &&
    identical(class(x$type), c("StructType", "NestedType", "DataType", "ArrowObject", "R6"))
}

#' @param arr Array, ChunkedArray
#' @noRd
coerce_arrow = function(arr, rechunk = TRUE) {
  if (!is.null(arr$num_chunks) && is_arrow_dictionary(arr) && rechunk) {
    # recast non ideal index types
    non_ideal_idx_types = c("int8", "uint8", "int16", "uint16", "int32")
    if (arr$type$index_type$ToString() %in% non_ideal_idx_types) {
      arr = arr$cast(
        arrow::dictionary(index_type = arrow::uint32(), value_type = arrow::large_utf8())
      ) |>
        arrow::as_arrow_array()
    }
  }
  arr
}

#' Internal function of `as_polars_series()` for `arrow::Array` and `arrow::ChunkedArray` class objects.
#'
#' This is a copy of Python Polars' `arrow_to_pyseries` function.
#' @param values An [arrow::Array], [arrow::ChunkedArray]
#' @noRd
#' @return A result inclueds RPolarsSeries
arrow_to_rseries_result = function(name, values, rechunk = TRUE) {
  ## must rechunk
  array = coerce_arrow(values)

  # special handling of empty categorical arrays
  if (
    (length(array) == 0L) &&
      is_arrow_dictionary(array) &&
      array$type$value_type$ToString() %in% c("string", "large_string")
  ) {
    res = Ok(pl$lit(c())$cast(pl$Categorical)$to_series())
  } else if (is.null(array$num_chunks)) {
    res = .pr$Series$from_arrow_array_robj(name, array)
  } else {
    if (array$num_chunks > 1) {
      if (is_arrow_dictionary(array)) {
        res = .pr$Series$from_arrow_array_robj(name, arrow::as_arrow_array(array))
      } else {
        chunks = array$chunks
        res = .pr$Series$from_arrow_array_robj(name, chunks[[1]])
        for (chunk in chunks[-1L]) {
          res = and_then(res, \(s) {
            .pr$Series$append_mut(s, unwrap(.pr$Series$from_arrow_array_robj(name, chunk))) |> map(\(x) s)
          })
        }
        res
      }
    } else if (array$num_chunks == 0L) {
      res = .pr$Series$from_arrow_array_robj(name, arrow::Array$create(NULL)$cast(array$type))
    } else {
      res = .pr$Series$from_arrow_array_robj(name, array$chunk(0L))
    }
  }

  if (rechunk) {
    res = res |> map(\(s) {
      wrap_e(s)$rechunk()$to_series()
    })
  }

  res
}
