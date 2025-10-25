# Choose the maximum supported between both us and Python's compatibility level
get_target_compat_level <- function(python_polars) {
  compat_level_newest_py <- python_polars$interchange$CompatLevel$newest()$`_version` |>
    reticulate::py_to_r()

  min(
    compat_level_newest_py,
    pl__CompatLevel$newest
  )
}
