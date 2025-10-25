# nolint start: object_name_linter

# exported in zzz.R
# TODO: support `convert = TRUE`
r_to_py.polars_data_frame <- function(x, convert = FALSE) {
  py_series <- as_polars_series(x) |>
    r_to_py.polars_series(convert = convert)

  py_series$struct$unnest()
}

# nolint end
