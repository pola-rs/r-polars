# Copied from rlang or lifecycle
# https://github.com/r-lib/lifecycle/blob/2a852fee7c4f873b865ffe9553150fefc1f1becf/R/arg.R
deprecated <- function() missing_arg()

# Copied from lifecycle
# https://github.com/r-lib/lifecycle/blob/2a852fee7c4f873b865ffe9553150fefc1f1becf/R/arg.R
is_present <- function(arg) {
  !is_missing(maybe_missing(arg))
}

# The `rechunk` argument of the `read_*()` and `scan_*()` functions was
# deprecated in Python Polars 1.44.0.
# The default of `user_env` is evaluated in this function's frame, so
# `caller_env(2)` is the caller of the `read_*()`/`scan_*()` function.
warn_deprecated_rechunk <- function(user_env = caller_env(2)) {
  deprecate_warn(
    c(
      `!` = sprintf(
        "The %s argument is deprecated as of %s 1.15.0.",
        format_arg("rechunk"),
        format_pkg("polars")
      ),
      i = sprintf(
        "Call %s on the output instead.",
        format_code("$rechunk()")
      )
    ),
    user_env = user_env
  )
}

# The file cache was removed upstream and has no replacement in Polars 2.0.
# Keep accepting this argument in the 1.x migration release, but do not pass it
# on as a storage option.
warn_deprecated_file_cache_ttl <- function(user_env = caller_env(2)) {
  deprecate_warn(
    c(
      `!` = sprintf(
        "The %s argument is deprecated as of %s 1.9.0.",
        format_arg("file_cache_ttl"),
        format_pkg("polars")
      ),
      i = "The file cache is no longer supported and has no direct replacement in polars 2.0."
    ),
    user_env = user_env
  )
}

warn_arrow_compression_default <- function(user_env = caller_env(2)) {
  deprecate_warn(
    c(
      `!` = sprintf(
        "The default value of %s is deprecated as of %s 1.16.0.",
        format_arg("compression"),
        format_pkg("polars")
      ),
      i = sprintf(
        paste0(
          "The default will change from %s to %s in Polars 2.0. ",
          "Use %s to keep the current behavior or %s to opt into the new default."
        ),
        format_code('"zstd"'),
        format_code('"uncompressed"'),
        format_code('compression = "zstd"'),
        format_code('compression = "uncompressed"')
      )
    ),
    user_env = user_env
  )
}

warn_deprecated_hash_seeds <- function(fn, user_env = caller_env(2)) {
  deprecate_warn(
    c(
      `!` = sprintf(
        "The `seed_1`, `seed_2`, and `seed_3` arguments of %s are deprecated as of %s 1.16.0.",
        format_fn(fn),
        format_pkg("polars")
      ),
      i = sprintf("Use the %s argument instead.", format_arg("seed"))
    ),
    user_env = user_env
  )
}

warn_deprecated_selector_dots <- function(
  fn,
  argument,
  empty = FALSE,
  user_env = caller_env(2)
) {
  message <- if (empty) {
    sprintf(
      "Calling %s without an argument is deprecated as of %s 1.16.0.",
      format_fn(fn),
      format_pkg("polars")
    )
  } else {
    sprintf(
      "Using `...` to supply values to %s is deprecated as of %s 1.16.0.",
      format_fn(fn),
      format_pkg("polars")
    )
  }

  deprecate_warn(
    c(
      `!` = message,
      i = sprintf(
        if (empty) {
          "Pass an explicit empty %s instead."
        } else {
          "Pass the values as a single %s argument instead."
        },
        format_code(argument)
      )
    ),
    user_env = user_env
  )
}

warn_deprecated_selector_column_operation <- function(
  operator,
  user_env = caller_env(2)
) {
  deprecate_warn(
    c(
      `!` = sprintf(
        "Using %s as the right-hand operand of %s on a selector is deprecated as of %s 1.16.0.",
        format_code("pl$col(...)"),
        format_code(operator),
        format_pkg("polars")
      ),
      i = sprintf(
        "Use %s for set operations or %s for element-wise operations.",
        format_code("cs$by_name(...)"),
        format_code("<selector>$as_expr()")
      )
    ),
    user_env = user_env
  )
}
