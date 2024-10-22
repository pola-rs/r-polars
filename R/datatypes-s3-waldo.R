# exported in zzz.R
compare_proxy.polars_dtype <- function(x, path) {
  list(
    object = utils::capture.output(print(x)),
    path = path
  )
}
