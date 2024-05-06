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
    res = Ok(pl$lit(c())$cast(pl$Categorical())$to_series())
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


#' Internal function of `as_polars_df()` for `data.frame` class objects.
#'
#' This is a copy of Python Polars' `arrow_to_pydf` function.
#' @noRd
#' @return RPolarsDataFrame
df_to_rpldf = function(x, ..., schema = NULL, schema_overrides = NULL) {
  n_cols = ncol(x)

  new_schema = unpack_schema(
    schema = schema %||% names(x),
    schema_overrides = schema_overrides
  )
  col_names = names(new_schema)

  if (length(col_names) != n_cols) {
    Err_plain("schema length does not match column length") |>
      unwrap()
  }

  out = lapply(x, \(col) as_polars_series(unAsIs(col))) |>
    pl$select()

  out$columns = col_names

  cast_these_fields = mapply(
    new_schema,
    out$schema,
    FUN = \(new_field, df_field)  {
      if (is.null(new_field) || new_field == df_field) NULL else new_field
    },
    SIMPLIFY = FALSE
  ) |> (\(l) l[!sapply(l, is.null)])()

  if (length(cast_these_fields)) {
    out = out$with_columns(
      mapply(
        cast_these_fields,
        names(cast_these_fields),
        FUN = \(dtype, name) pl$col(name)$cast(dtype),
        SIMPLIFY = FALSE
      ) |> unname()
    )
  }

  out
}
