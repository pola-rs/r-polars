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

# Polars 2.0 streaming readers do not use the file cache, and this argument
# has no direct replacement.
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
      i = paste0(
        "The Polars 2.0 streaming readers do not use the file cache, ",
        "and this argument has no direct replacement."
      )
    ),
    user_env = user_env
  )
}

# Polars 2.0 streaming readers do not use the file cache, and this argument
# has no direct replacement.
# Keep accepting this argument in the 1.x migration release, but do not pass it
# on to the Rust API as a storage option.
warn_deprecated_file_cache <- function(user_env = caller_env(2)) {
  deprecate_warn(
    c(
      `!` = sprintf(
        "The %s argument is deprecated as of %s 1.16.0.",
        format_arg("cache"),
        format_pkg("polars")
      ),
      i = paste0(
        "The Polars 2.0 streaming readers do not use the file cache, ",
        "and this argument has no direct replacement."
      )
    ),
    user_env = user_env
  )
}

warn_csv_infer_schema_files <- function(user_env = caller_env(2)) {
  deprecate_warn(
    c(
      `!` = sprintf(
        "The default value of %s will change in %s 2.0.",
        format_arg("infer_schema_files"),
        format_pkg("polars")
      ),
      i = paste0(
        "The default will change from using all files to 10 files in Polars 2.0. ",
        "Use `infer_schema_files = 10` to opt into the new default or ",
        "`infer_schema_files = NULL` to keep using all files."
      )
    ),
    user_env = user_env
  )
}

warn_csv_raise_if_empty <- function(user_env = caller_env(2)) {
  deprecate_warn(
    c(
      `!` = sprintf(
        "The default value of %s will change in %s 2.0.",
        format_arg("raise_if_empty"),
        format_pkg("polars")
      ),
      i = paste0(
        "When `has_header = FALSE` and `schema` is supplied, the default will ",
        "change from `TRUE` to `FALSE` in Polars 2.0. Use ",
        "`raise_if_empty = TRUE` to keep the current behavior."
      )
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
      i = paste0(
        "The `seed_1`, `seed_2`, and `seed_3` arguments will be removed in ",
        "Polars 2.0; only `seed` will remain. Hash values may change."
      )
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

warn_deprecated_selector_col <- function(
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

warn_deprecated_to_struct <- function(method, user_env = caller_env(2)) {
  deprecate_warn(
    c(
      `!` = sprintf(
        "Legacy arguments of %s are deprecated as of %s 1.16.0.",
        format_code(method),
        format_pkg("polars")
      ),
      i = sprintf(
        "Use an explicit character vector for %s.",
        format_arg("fields")
      )
    ),
    user_env = user_env
  )
}

warn_deprecated_rolling_sum_by_min_samples <- function(user_env = caller_env(2)) {
  deprecate_warn(
    c(
      `!` = sprintf(
        "The default value of %s in %s will change in %s 2.0.",
        format_arg("min_samples"),
        format_fn("<expr>$rolling_sum_by"),
        format_pkg("polars")
      ),
      i = sprintf(
        "Use %s to retain the current behavior or %s to opt into the new default.",
        format_code("min_samples = 1"),
        format_code("min_samples = 0")
      )
    ),
    user_env = user_env
  )
}

warn_deprecated_sample_shuffle <- function(fn, user_env = caller_env(2)) {
  deprecate_warn(
    c(
      `!` = sprintf(
        "The default value of %s in %s will change in %s 2.0.",
        format_arg("shuffle"),
        format_fn(fn),
        format_pkg("polars")
      ),
      i = sprintf(
        "Use %s to retain the current behavior; sample order will not be guaranteed by default in %s 2.0.",
        format_code("shuffle = FALSE"),
        format_pkg("polars")
      )
    ),
    user_env = user_env
  )
}

warn_deprecated_list_sample_default <- function(user_env = caller_env(2)) {
  deprecate_warn(
    c(
      `!` = sprintf(
        "The default sampling strategy of %s will change in %s 2.0.",
        format_fn("<expr>$list$sample"),
        format_pkg("polars")
      ),
      i = sprintf(
        "Use %s to retain the current behavior or %s to opt into the new default.",
        format_code("fraction = 1"),
        format_code("n = 1")
      )
    ),
    user_env = user_env
  )
}

warn_deprecated_reinterpret_signed <- function(user_env = caller_env(2)) {
  deprecate_warn(
    c(
      `!` = sprintf(
        "Calling %s without the %s argument is deprecated as of %s 1.16.0.",
        format_fn("<expr>$reinterpret"),
        format_arg("signed"),
        format_pkg("polars")
      ),
      i = sprintf(
        "Use %s to retain the current behavior. In %s 2.0, exactly one of %s or %s must be supplied.",
        format_code("signed = TRUE"),
        format_pkg("polars"),
        format_arg("signed"),
        format_arg("dtype")
      )
    ),
    user_env = user_env
  )
}

warn_deprecated_set_sorted_nulls_last <- function(user_env = caller_env(2)) {
  deprecate_warn(
    c(
      `!` = sprintf(
        "The default value of %s in %s will change in %s 2.0.",
        format_arg("nulls_last"),
        format_fn("<expr>$set_sorted"),
        format_pkg("polars")
      ),
      i = sprintf(
        "Use %s to retain the current behavior or %s to opt into the new default.",
        format_code("nulls_last = TRUE"),
        format_code("nulls_last = FALSE")
      )
    ),
    user_env = user_env
  )
}

warn_deprecated_bare_string <- function(argument, fn, user_env = caller_env(2)) {
  deprecate_warn(
    c(
      `!` = sprintf(
        "Using a bare character string as the %s argument of %s is deprecated as of %s 1.16.0.",
        format_arg(argument),
        format_fn(fn),
        format_pkg("polars")
      ),
      i = sprintf(
        "In %s 2.0, bare strings will be literals. Use %s for a column or %s for a literal.",
        format_pkg("polars"),
        format_code("pl$col(...)"),
        format_code("pl$lit(...)")
      )
    ),
    user_env = user_env
  )
}
