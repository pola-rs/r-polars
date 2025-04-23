# nolint start: object_name_linter

# exported in zzz.R
compare_proxy.polars_data_frame <- function(x, path) {
  list(
    object = structure(
      as.list(x, as_series = TRUE),
      shape = x$shape,
      schema = x$schema
    ),
    path = path
  )
}

# nolint end
