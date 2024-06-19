# TODO: support datatype input
pl__col <- function(...) {
  # TODO: check if dots is empty
  # TODO: use rlang::list2
  dots <- list(...)

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
    stop("Only character input is supported now")
  }
}
