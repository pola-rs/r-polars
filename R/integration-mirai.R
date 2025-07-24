# Taken from the glue package's knitr integration
# https://github.com/tidyverse/glue/blob/a3f80d678274ef634c10c2cb094c939b1543222a/R/zzz.R#L4-L11

register_mirai_serial <- function() {
  # If the mirai package is not installed, `asNamespace("mirai")` will throw an error,
  # so this function should only be called when the mirai package is loaded.
  if (exists("register_serial", envir = asNamespace("mirai"), mode = "function")) {
    # If the daemons are already set, registering serialization configs
    # will not affect existing daemons. So warn to the user.
    # Safety: mirai::daemons_set is added in mirai 2.3.0,
    # the same version that introduced the `register_serial` function.
    if (mirai::daemons_set()) {
      inform(
        format_message(
          c(
            i = sprintf(
              "The %s package was loaded after %s daemons were already created.",
              format_pkg("polars"),
              format_pkg("mirai")
            ),
            i = sprintf(
              "To apply the serialization configs registered by %s, recreate daemons.",
              format_pkg("polars")
            ),
            `*` = sprintf(
              "Run %s to reset daemon connections, then recreate daemons with %s.",
              format_code("mirai::daemons(0)"),
              format_fn("mirai::daemons")
            )
          )
        )
      )
    }

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
