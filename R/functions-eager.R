# TODO: check `how` argument
pl__concat <- function(..., how = "vertical") {
  check_dots_unnamed()

  elems <- list2(...)

  if (length(elems) == 0L) {
    abort("No arguments have been provided to concat.")
  }

  first <- elems[[1]]

  if (length(elems) == 1L && (is_polars_df(first) || is_polars_series(first) || is_polars_lf(first))) {
    return(first)
  }

  if (is_polars_df(first)) {
    elems |>
      lapply(\(x) x$`_df`) |>
      concat_df() |>
      wrap()
  } else {
    abort("todo")
  }
}
