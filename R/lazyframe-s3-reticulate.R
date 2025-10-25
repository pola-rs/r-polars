# nolint start: object_name_linter

# exported in zzz.R
# TODO: support `convert = TRUE`
r_to_py.polars_lazy_frame <- function(x, convert = FALSE) {
  pypl <- import_py_polars()
  check_py_version(pypl)

  pyio <- reticulate::import("io", convert = FALSE)

  x$serialize() |>
    reticulate::import_builtins(convert = FALSE)$bytes() |>
    pyio$BytesIO() |>
    pypl$LazyFrame$deserialize()
}

# nolint end
