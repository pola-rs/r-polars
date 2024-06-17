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

assign_objects_to_env(pl, "^polars_functions_")

assign_objects_to_env(polars_functions_api, "^function_api_")

assign_objects_to_env(polars_namespaces_series, "^namespace_series_")

assign_objects_to_env(polars_series__methods, "^series__")

assign_objects_to_env(polars_series_struct_methods, "^series_struct_")

assign_objects_to_env(polars_dataframe__methods, "^dataframe__")
