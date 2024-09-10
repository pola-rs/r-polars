# exported in zzz.R
compare_proxy.polars_data_type <- function(x, path) {
  list(
    object = utils::capture.output(print(x)),
    path = path
  )
}
