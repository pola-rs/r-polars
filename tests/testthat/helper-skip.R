# https://github.com/r-lib/testthat/issues/2236
skip_on_dev_version <- function() {
  version <- asNamespace(testing_package())[[".__NAMESPACE__."]][["spec"]][[
    "version"
  ]] |>
    package_version() |>
    unclass() |>
    getElement(1L)

  # We use larger than `9000` version for the development versions
  if (tail(version, 1L) < 9000) {
    invisible()
  } else {
    skip("Skip on development versions.")
  }
}

skip_if_no_py_polars <- function(version = NULL) {
  skip_if_not_installed("reticulate")

  if (!reticulate::py_module_available("polars")) {
    skip("Python Polars is not available.")
  }

  if (!is.null(version)) {
    current_version <- reticulate::import("polars", convert = FALSE)$`__package__` |>
      reticulate::import("importlib.metadata")$version() |>
      reticulate::py_to_r()
    if (!identical(current_version, version)) {
      skip(sprintf(
        "Python Polars version %s is required, but version %s is installed.",
        version,
        current_version
      ))
    }
  }
}

# nolint start: object_name_linter
skip_if_no_nanoarrow_py_integration <- function() {
  # nolint end
  skip_if_not_installed("nanoarrow")
  skip_if_not_installed("reticulate")

  na_namespace <- asNamespace("nanoarrow")
  if (
    !exists("as_nanoarrow_array_stream.python.builtin.object", envir = na_namespace) ||
      !exists("r_to_py.nanoarrow_array_stream", envir = na_namespace)
  ) {
    skip("nanoarrow reticulate integration is not available.")
  }

  if (!reticulate::py_module_available("nanoarrow")) {
    skip("Python nanoarrow is not available.")
  }
}
