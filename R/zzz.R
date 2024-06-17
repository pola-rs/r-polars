# The env to store polars top-level functions
#' @export
pl <- new.env(parent = emptyenv())

# A function to collect objects to be assigned to the environment
# These environments are used inside the wrap function etc.
assign_objects_to_env <- function(env, fn_name_pattern, ..., search_env = parent.frame()) {
  fn_names <- ls(search_env, pattern = fn_name_pattern)
  new_names <- sub(fn_name_pattern, "", fn_names)

  lapply(seq_along(fn_names), function(i) {
    fn <- get(fn_names[i], envir = search_env)
    assign(new_names[i], fn, envir = env)
  })
}

POLARS_OBJECTS <- list(
  "^polars_functions_" = pl,
  "^function_api_" = polars_functions_api,
  "^namespace_series_" = polars_namespaces_series,
  "^series__" = polars_series__methods,
  "^series_struct_" = polars_series_struct_methods,
  "^dataframe__" = polars_dataframe__methods
)

lapply(names(POLARS_OBJECTS), function(name) {
  assign_objects_to_env(POLARS_OBJECTS[[name]], name, search_env = parent.frame(2L))
})
