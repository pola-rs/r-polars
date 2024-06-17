# The env to store polars top-level functions
#' @export
pl <- new.env(parent = emptyenv())

assign_functions_to_env(pl, "^polars_functions_")

assign_functions_to_env(polars_functions_api, "^function_api_")

assign_functions_to_env(polars_namespaces_series, "^namespace_series_")

assign_functions_to_env(polars_series__methods, "^series__")

assign_functions_to_env(polars_series_struct_methods, "^series_struct_")

assign_functions_to_env(polars_dataframe__methods, "^dataframe__")
