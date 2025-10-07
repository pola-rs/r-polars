# nolint start: object_name_linter

# exported in zzz.R
compare_proxy.polars_dtype <- function(x, path) {
  formatted <- format(x, abbreviated = FALSE)

  list(object = formatted, path = path)
}

# nolint end
