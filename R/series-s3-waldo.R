# exported in zzz.R
compare_proxy.polars_series <- function(x, path) {
  list(
    object = structure(
      as.vector(x),
      name = x$name,
      dtype = x$dtype
    ),
    path = path
  )
}
