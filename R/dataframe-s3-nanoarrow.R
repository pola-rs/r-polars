# nolint start: object_name_linter

# exported in zzz.R
#' @rdname s3-as_nanoarrow_array_stream
as_nanoarrow_array_stream.polars_data_frame <- function(
  x,
  ...,
  schema = NULL,
  polars_compat_level = c("newest", "oldest")
) {
  as_polars_series(x) |>
    as_nanoarrow_array_stream.polars_series(
      ...,
      schema = schema,
      polars_compat_level = polars_compat_level
    )
}

# nolint end
