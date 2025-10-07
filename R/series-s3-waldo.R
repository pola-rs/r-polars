# nolint start: object_name_linter

# exported in zzz.R
compare_proxy.polars_series <- function(x, path) {
  exported_vec <- x$to_r_vector(int64 = "character", decimal = "character")
  s_name <- x$name
  s_dtype <- x$dtype

  list(
    object = structure(exported_vec, name = s_name, dtype = s_dtype),
    path = path
  )
}

# nolint end
