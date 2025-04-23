# nolint start: object_name_linter

# exported in zzz.R
compare_proxy.polars_expr <- function(x, path) {
  list(
    object = tryCatch(
      x$meta$serialize(format = "json"),
      error = function(e) {
        x$`_rexpr`$as_str()
      }
    ),
    path = path
  )
}

# nolint end
