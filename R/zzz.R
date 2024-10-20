#' Polars top-level function namespace
#'
#' `pl` is an [environment class][environment-class] object
#' that stores all the top-level functions of the R Polars API
#' which mimics the Python Polars API.
#' It is intended to work the same way in Python as if you had imported
#' Python Polars with `import polars as pl`.
#' @examples
#' pl
#'
#' # How many members are in the `pl` environment?
#' length(pl)
#'
#' # Create a polars DataFrame
#' # In Python:
#' # ```python
#' # >>> import polars as pl
#' # >>> df = pl.DataFrame({"a": [1, 2, 3], "b": [4, 5, 6]})
#' # ```
#' # In R:
#' df <- pl$DataFrame(a = c(1, 2, 3), b = c(4, 5, 6))
#' df
#' @export
pl <- new.env(parent = emptyenv())

#' @export
print.polars_object <- function(x, ...) {
  cat("<polars_object>\n")
  invisible(x)
}

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
  "expr_arr_" = polars_expr_arr_methods,
  "expr_bin_" = polars_expr_bin_methods,
  "expr_cat_" = polars_expr_cat_methods,
  "expr_dt_" = polars_expr_dt_methods,
  "expr_meta_" = polars_expr_meta_methods,
  "expr_list_" = polars_expr_list_methods,
  "expr_name_" = polars_expr_name_methods,
  "expr_str_" = polars_expr_str_methods,
  "expr_struct_" = polars_expr_struct_methods,
  "then__" = polars_then__methods,
  "chainedthen__" = polars_chainedthen__methods,
  "selector__" = polars_selector__methods,
  "namespace_series_" = polars_namespaces_series,
  "series__" = polars_series__methods,
  "series_bin_" = polars_series_bin_methods,
  "series_cat_" = polars_series_cat_methods,
  "series_dt_" = polars_series_dt_methods,
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

# Avoid R CMD check's 'no visible binding for global variable' note
utils::globalVariables("self")

# Use cli to format error messages
# TODO: can we use `inline = TRUE` without cli?
on_load(local_use_cli())

.onLoad <- function(libname, pkgname) {
  run_on_load()

  # Register S3 methods for optional packages
  s3_register("tibble::as_tibble", "polars_data_frame")
  s3_register("tibble::as_tibble", "polars_lazy_frame")
  s3_register("waldo::compare_proxy", "polars_expr")
  s3_register("waldo::compare_proxy", "polars_data_frame")
  s3_register("waldo::compare_proxy", "polars_data_type")
  s3_register("waldo::compare_proxy", "polars_series")
}
