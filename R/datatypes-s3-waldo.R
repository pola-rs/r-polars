# exported in zzz.R
compare_proxy.polars_dtype <- function(x, path) {
  list(
    object = x$`_dt`$as_str(abbreviated = FALSE),
    path = path
  )
}
