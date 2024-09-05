# exported in zzz.R
compare_proxy.polars_expr <- function(x, path) {
  list(
    object = x$meta$serialize(format = "json"),
    path = path
  )
}
