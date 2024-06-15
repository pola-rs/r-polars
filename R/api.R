# TODO: prevent overwriting existing namespaces
#' @export
polars_register_series_namespace <- function(name, ns_env) {
  assign(name, ns_env, envir = polars_namespaces_series)
}
