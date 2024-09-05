# exported in zzz.R
# TODO: Categolical is not working ideally
compare_proxy.polars_data_type <- function(x, path) {
  list(
    object = utils::capture.output(print(x)),
    path = path
  )
}
