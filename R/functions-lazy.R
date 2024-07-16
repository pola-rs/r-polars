pl__field <- function(...) {
  wrap({
    check_dots_unnamed()

    dots <- list2(...) |>
      unlist(recursive = FALSE)
    check_character(dots, arg = "...")

    field(dots)
  })
}

pl__select <- function(...) {
  pl$DataFrame()$select(...)
}
