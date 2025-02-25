# TODO: `$meta$serialize` does not support all literal values https://github.com/pola-rs/polars/pull/17679
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
