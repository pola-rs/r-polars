# Copied from rlang or lifecycle
# https://github.com/r-lib/lifecycle/blob/2a852fee7c4f873b865ffe9553150fefc1f1becf/R/arg.R
deprecated <- function() missing_arg()

# Copied from lifecycle
# https://github.com/r-lib/lifecycle/blob/2a852fee7c4f873b865ffe9553150fefc1f1becf/R/arg.R
is_present <- function(arg) {
  !is_missing(maybe_missing(arg))
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
