# nolint start: object_name_linter

# exported in zzz.R
#' @rdname s3-as_nanoarrow_array_stream
as_nanoarrow_array_stream.polars_data_frame <- function(
  x,
  ...,
  schema = NULL,
  polars_compat_level = c("newest", "oldest")
) {
  # Allow override by option at the downstream function
  if (missing(polars_compat_level)) {
    polars_compat_level <- missing_arg()
  }

  as_polars_series(x) |>
    as_nanoarrow_array_stream.polars_series(
      ...,
      schema = schema,
      polars_compat_level = polars_compat_level
    )
}

# nolint end
