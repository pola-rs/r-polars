# nolint start: object_name_linter

# exported in zzz.R
# TODO: support `convert = TRUE`
r_to_py.polars_series <- function(x, convert = FALSE) {
  check_installed("nanoarrow", version = "0.7.0.9000") # TODO: update to 0.8.0 after the release

  pypl <- try_fetch(
    reticulate::import("polars", convert = FALSE),
    error = function(cnd) {
      abort(
        c(
          "Python Polars is not available in the reticulate environment."
        ),
        parent = cnd
      )
    }
  )

  target_compat_level <- get_target_compat_level(pypl)

  py_array_stream <- as_nanoarrow_array_stream.polars_series(
    x,
    polars_compat_level = target_compat_level
  ) |>
    reticulate::r_to_py(convert = FALSE)

  pypl$Series(py_array_stream)
}

# nolint end
