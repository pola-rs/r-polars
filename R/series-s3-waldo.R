# nolint start: object_name_linter

# exported in zzz.R
compare_proxy.polars_series <- function(x, path) {
  list(
    object = structure(
      x$to_r_vector(ensure_vector = FALSE, int64 = "character", decimal = "character"),
      name = x$name,
      dtype = x$dtype
    ),
    path = path
  )
}

# nolint end
