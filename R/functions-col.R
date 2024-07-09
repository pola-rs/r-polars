# TODO: support datatype input
pl__col <- function(...) {
  check_dots_unnamed()

  dots <- list2(...) |>
    unlist(recursive = FALSE)

  if (is.character(dots)) {
    if (anyNA(dots)) {
      abort("`NA` is not a valid column name")
    }

    if (length(dots) == 1L) {
      col(dots[[1]]) |>
        wrap()
    } else {
      cols(dots) |>
        wrap()
    }
  } else if (is_polars_data_type(dots[[1]])) {
    dots |>
      lapply(\(x) x$`_dt`) |>
      dtype_cols() |>
      wrap()
  } else {
    # TODO: error message improvement
    abort("invalid input for `pl$col()`.")
  }
}
