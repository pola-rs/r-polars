# nolint start: object_name_linter

# exported in zzz.R
compare_proxy.polars_data_frame <- function(x, path) {
  list_of_series <- as.list(x, as_series = TRUE)
  shape <- x$shape
  schema <- x$schema

  list(
    object = structure(list_of_series, shape = shape, schema = schema),
    path = path
  )
}

# nolint end
