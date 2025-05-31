# Taken from the glue package's knitr integration
# https://github.com/tidyverse/glue/blob/a3f80d678274ef634c10c2cb094c939b1543222a/R/zzz.R#L4-L11

register_mirai_serial <- function() {
  # If the mirai package is not installed, `asNamespace("mirai")` will throw an error,
  # so this function should only be called when the mirai package is loaded.
  if (exists("register_serial", envir = asNamespace("mirai"), mode = "function")) {
    mirai::register_serial(
      c("polars_data_frame", "polars_lazy_frame", "polars_series"),
      sfunc = list(\(x) x$serialize(), \(x) x$serialize(), \(x) x$serialize()),
      ufunc = list(pl$deserialize_df, pl$deserialize_lf, pl$deserialize_series)
    )
  }
}

on_load({
  if (isNamespaceLoaded("mirai")) {
    register_mirai_serial()
  } else {
    setHook(packageEvent("mirai", "onLoad"), function(...) register_mirai_serial())
  }
})
