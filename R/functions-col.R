# TODO: support datatype input
pl__col <- function(...) {
  # TODO: check if dots is empty
  dots <- list2(...)

  if (is.character(dots[[1]])) {
    if (length(dots) == 1L && length(dots[[1]]) == 1L && !is.na(dots[[1]])) {
      col(dots[[1]]) |>
        wrap()
    } else {
      # TODO: NA_character_ should not be converted to "NA"
      cols(unlist(dots)) |>
        wrap()
    }
  } else {
    abort("Only character input is supported now")
  }
}
