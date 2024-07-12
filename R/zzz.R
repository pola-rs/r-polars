# The env to store polars top-level functions
#' @export
pl <- new.env(parent = emptyenv())

# A function to collect objects to be assigned to the environment
# These environments are used inside the wrap function etc.
assign_objects_to_env <- function(env, obj_name_pattern, ..., search_env = parent.frame()) {
  fn_names <- ls(search_env, pattern = obj_name_pattern)
  new_names <- sub(obj_name_pattern, "", fn_names)

  lapply(seq_along(fn_names), function(i) {
    fn <- get(fn_names[i], envir = search_env)
    assign(new_names[i], fn, envir = env)
  })
}

POLARS_STORE_ENVS <- list(
  "pl__" = pl,
  "cs__" = cs,
  "pl_api_" = pl__api,
  "datatype__" = polars_datatype__methods,
  "namespace_expr_" = polars_namespaces_expr,
  "expr__" = polars_expr__methods,
  "expr_dt_" = polars_expr_dt_methods,
  "expr_meta_" = polars_expr_meta_methods,
  "expr_name_" = polars_expr_name_methods,
  "expr_struct_" = polars_expr_struct_methods,
  "then__" = polars_then__methods,
  "chainedthen__" = polars_chainedthen__methods,
  "selector__" = polars_selector__methods,
  "namespace_series_" = polars_namespaces_series,
  "series__" = polars_series__methods,
  "series_struct_" = polars_series_struct_methods,
  "lazyframe__" = polars_lazyframe__methods,
  "lazygroupby__" = polars_lazygroupby__methods,
  "dataframe__" = polars_dataframe__methods,
  "groupby__" = polars_groupby__methods
)

lapply(names(POLARS_STORE_ENVS), function(name) {
  target_env <- POLARS_STORE_ENVS[[name]]
  class(target_env) <- c("polars_object")
  assign_objects_to_env(POLARS_STORE_ENVS[[name]], sprintf("^%s", name), search_env = parent.frame(2L))
})

.onLoad <- function(libname, pkgname) {
  # Register data types without arguments as active bindings
  c(
    "Int8",
    "Int16",
    "Int32",
    "Int64",
    "UInt8",
    "UInt16",
    "UInt32",
    "UInt64",
    "Float32",
    "Float64",
    "Boolean",
    "String",
    "Binary",
    "Date",
    "Time",
    "Null"
  ) |>
    lapply(function(name) {
      makeActiveBinding(name, function() PlRDataType$new_from_name(name) |> wrap(), pl)
    })
}
