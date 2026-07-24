#' Register a plugin function
#'
#' Register a Polars expression plugin from a compiled dynamic library. See the
#' [plugin user guide](https://docs.pola.rs/user-guide/plugins/expr_plugins) for
#' more information about plugins.
#'
#' @param plugin_path Path to the dynamic library file, or the directory
#' containing it.
#' @param function_name Name of the Rust function to register.
#' @param args Expressions passed to the plugin (or values convertible to
#' expressions).
#' @param kwargs_raw Raw bytes passed to the plugin as its keyword-argument
#' payload. The encoding is defined by the plugin. Unlike Python Polars'
#' `kwargs`, this does not serialize an R list; package authors should normally
#' wrap it in a typed function rather than exposing `kwargs_raw` directly.
#' @param is_elementwise Indicate that the function operates on scalars only.
#' @param changes_length Indicate that the function changes the length of the
#' expression.
#' @param returns_scalar Automatically explode on unit length when the function
#' runs as a final aggregation.
#' @param cast_to_supertype Cast the input expressions to their supertype.
#' @param input_wildcard_expansion Expand wildcard expressions before executing
#' the function.
#' @param pass_name_to_apply Ensure the column name is set on the `Series`
#' passed to the plugin in a group-by.
#' @inherit as_polars_expr return
#'
#' @examples
#' # `plugin_path` points at a compiled plugin library exporting `function_name`.
#' expr <- pl$register_plugin_function(
#'   plugin_path = "libmyplugin.so",
#'   function_name = "my_function",
#'   args = pl$col("a")
#' )
pl__register_plugin_function <- function(
  plugin_path,
  function_name,
  args,
  kwargs_raw = NULL,
  is_elementwise = FALSE,
  changes_length = FALSE,
  returns_scalar = FALSE,
  cast_to_supertype = FALSE,
  input_wildcard_expansion = FALSE,
  pass_name_to_apply = FALSE
) {
  check_string(plugin_path)
  check_string(function_name)
  check_bool(is_elementwise)
  check_bool(changes_length)
  check_bool(returns_scalar)
  check_bool(cast_to_supertype)
  check_bool(input_wildcard_expansion)
  check_bool(pass_name_to_apply)
  if (is.null(kwargs_raw)) {
    kwargs_raw <- raw(0)
  } else if (!is.raw(kwargs_raw)) {
    abort("`kwargs_raw` must be a raw vector or `NULL`.")
  }
  if (!is.list(args)) {
    args <- list(args)
  }

  exprs <- do.call(parse_into_list_of_expressions, unname(args))

  register_plugin_function(
    plugin_path = plugin_path,
    function_name = function_name,
    args = exprs,
    kwargs_raw = kwargs_raw,
    is_elementwise = is_elementwise,
    input_wildcard_expansion = input_wildcard_expansion,
    returns_scalar = returns_scalar,
    cast_to_supertype = cast_to_supertype,
    pass_name_to_apply = pass_name_to_apply,
    changes_length = changes_length
  ) |>
    wrap()
}
