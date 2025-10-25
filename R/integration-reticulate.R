import_py_polars <- function() {
  call <- caller_env()
  try_fetch(
    reticulate::import("polars", convert = FALSE),
    error = function(cnd) {
      abort(
        c(
          "Python Polars is not available in the reticulate environment."
        ),
        parent = cnd,
        call = call
      )
    }
  )
}

# Choose the maximum supported between both us and Python's compatibility level
get_target_compat_level <- function(python_polars) {
  compat_level_newest_py <- python_polars$interchange$CompatLevel$newest()$`_version` |>
    reticulate::py_to_r()

  min(
    compat_level_newest_py,
    pl__CompatLevel$newest
  )
}

check_py_version <- function(python_polars) {
  call <- caller_env()

  current_version <- python_polars$`__version__` |>
    reticulate::py_to_r()
  required_version <- PY_VERSION

  if (!identical(current_version, required_version)) {
    warn(
      c(
        `!` = "Version mismatch between R Polars and Python Polars.",
        i = sprintf(
          "The corresponding Python Polars version is %s, but the detected version is %s.",
          format_emph(required_version),
          format_emph(current_version)
        )
      ),
      call = call
    )
  }
}
