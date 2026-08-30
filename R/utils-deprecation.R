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
