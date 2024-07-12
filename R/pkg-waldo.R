# exported in zzz.R
# TODO: Categolical is not working ideally
compare_proxy.polars_data_type <- function(x, path) {
  list(
    object = utils::capture.output(print(x)),
    path = path
  )
}

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

# exported in zzz.R
compare_proxy.polars_data_frame <- function(x, path) {
  list(
    object = structure(
      as.list(x),
      shape = x$shape,
      schema = x$schema
    ),
    path = path
  )
}
