#' Register a plugin function
#'
#' Register a Polars expression plugin from a compiled dynamic library. See the
#' [plugin user guide](https://docs.pola.rs/user-guide/plugins/expr_plugins) for
#' more information about plugins.
#'
#' This function is unsafe: it loads and runs native code. The library must be
#' compiled against a compatible Polars plugin ABI, and incorrect flags (such as
#' `is_elementwise`) can cause undefined behavior.
#'
#' @param plugin_path Path to the compiled dynamic library file, or a directory
#' containing exactly one.
#' @param function_name Name of the Rust function to register.
#' @param args Expressions passed to the plugin (or values convertible to
#' expressions).
#' @param kwargs Named list of non-expression arguments to the plugin, encoded
#' as the pickle-compatible bytes the standard plugin toolchain expects (as
#' Python Polars does). Values must be JSON-like: scalars, raw vectors, or
#' nested lists of these; names must be present and unique at the top level.
#' @param kwargs_raw Escape hatch for plugins with a custom payload format: raw
#' bytes used directly, without encoding. Supply either `kwargs` or
#' `kwargs_raw`, not both.
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
#' \dontrun{
#' pl$register_plugin_function(
#'   plugin_path = "libmyplugin.so",
#'   function_name = "my_function",
#'   args = pl$col("a"),
#'   kwargs = list(scale = 2L, wrap = TRUE)
#' )
#' }
pl__register_plugin_function <- function(
  plugin_path,
  function_name,
  args,
  kwargs = list(),
  kwargs_raw = NULL,
  is_elementwise = FALSE,
  changes_length = FALSE,
  returns_scalar = FALSE,
  cast_to_supertype = FALSE,
  input_wildcard_expansion = FALSE,
  pass_name_to_apply = FALSE
) {
  check_string(function_name)
  check_bool(is_elementwise)
  check_bool(changes_length)
  check_bool(returns_scalar)
  check_bool(cast_to_supertype)
  check_bool(input_wildcard_expansion)
  check_bool(pass_name_to_apply)

  payload <- .resolve_plugin_kwargs(kwargs, kwargs_raw)

  if (!is.list(args)) {
    args <- list(args)
  }
  exprs <- do.call(parse_into_list_of_expressions, unname(args))
  plugin_path <- .resolve_plugin_path(plugin_path)

  register_plugin_function(
    plugin_path = plugin_path,
    function_name = function_name,
    args = exprs,
    kwargs_raw = payload,
    is_elementwise = is_elementwise,
    input_wildcard_expansion = input_wildcard_expansion,
    returns_scalar = returns_scalar,
    cast_to_supertype = cast_to_supertype,
    pass_name_to_apply = pass_name_to_apply,
    changes_length = changes_length
  ) |>
    wrap()
}

# Resolve a plugin path to a dynamic library file, mirroring Python Polars:
# a directory is searched for exactly one library.
.resolve_plugin_path <- function(path) {
  check_string(path)
  if (file.exists(path) && !dir.exists(path)) {
    return(normalizePath(path, mustWork = TRUE))
  }
  if (!dir.exists(path)) {
    abort(sprintf("No plugin file or directory found at `%s`.", path))
  }
  candidates <- list.files(
    path,
    pattern = "\\.(so|dll|dylib|pyd)$",
    full.names = TRUE
  )
  if (length(candidates) == 0L) {
    abort(sprintf("No dynamic library found in `%s`.", path))
  }
  if (length(candidates) > 1L) {
    abort(sprintf(
      "Multiple dynamic libraries found in `%s`; supply the library file directly.",
      path
    ))
  }
  normalizePath(candidates, mustWork = TRUE)
}

# Resolve `kwargs` (a named list, pickle-encoded) and `kwargs_raw` (raw bytes)
# into the byte payload. Only one may be supplied.
.resolve_plugin_kwargs <- function(kwargs, kwargs_raw) {
  if (!is.null(kwargs) && (!is.list(kwargs) || is.data.frame(kwargs))) {
    abort("`kwargs` must be a named list or `NULL`.")
  }
  has_kwargs <- !is.null(kwargs) && length(kwargs) > 0L
  if (has_kwargs && !is.null(kwargs_raw)) {
    abort("Supply either `kwargs` or `kwargs_raw`, not both.")
  }
  if (!is.null(kwargs_raw)) {
    if (!is.raw(kwargs_raw)) {
      abort("`kwargs_raw` must be a raw vector or `NULL`.")
    }
    return(kwargs_raw)
  }
  if (!has_kwargs) {
    return(raw())
  }
  .check_plugin_kwargs(kwargs)
  pickle_kwargs(kwargs)
}

.check_plugin_kwargs <- function(kwargs) {
  nms <- names(kwargs)
  if (is.null(nms) || !all(nzchar(nms))) {
    abort("`kwargs` must be a fully named list.")
  }
  if (anyDuplicated(nms)) {
    abort("`kwargs` must have unique names.")
  }
  for (i in seq_along(kwargs)) {
    .check_plugin_kwargs_value(kwargs[[i]], sprintf("kwargs$%s", nms[i]))
  }
}

.check_plugin_kwargs_value <- function(x, arg) {
  if (is.null(x) || is.raw(x)) {
    return(invisible())
  }
  # Plain (unclassed) list -> pickle dict/list.
  if (is.list(x) && !is.object(x)) {
    nms <- names(x)
    named <- if (is.null(nms)) rep(FALSE, length(x)) else nzchar(nms)
    if (any(named) && !all(named)) {
      abort(sprintf("`%s` is a partially named list.", arg))
    }
    if (length(x) > 0L && all(named) && anyDuplicated(nms)) {
      abort(sprintf("`%s` must have unique names.", arg))
    }
    for (i in seq_along(x)) {
      child <- if (any(named)) sprintf("%s$%s", arg, nms[i]) else sprintf("%s[[%d]]", arg, i)
      .check_plugin_kwargs_value(x[[i]], child)
    }
    return(invisible())
  }
  # Classed atomics (factor, Date, POSIXct, integer64, ...) would serialize by
  # their underlying storage rather than their meaning.
  if (is.object(x)) {
    abort(sprintf("`%s` has an unsupported class for kwargs.", arg))
  }
  if (is.logical(x) || is.integer(x) || is.double(x) || is.character(x)) {
    if (length(x) != 1L) {
      abort(sprintf("`%s` must be a scalar; vectors are not supported.", arg))
    }
    if (is.na(x)) {
      abort(sprintf("`%s` is `NA`.", arg))
    }
    if (is.double(x) && !is.finite(x)) {
      abort(sprintf("`%s` must be finite.", arg))
    }
    return(invisible())
  }
  abort(sprintf("`%s` has an unsupported type for kwargs.", arg))
}
