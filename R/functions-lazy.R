pl__field <- function(...) {
  wrap({
    check_dots_unnamed()

    dots <- list2(...) |>
      unlist(recursive = FALSE)
    check_character(dots, arg = "...", allow_na = FALSE)

    field(dots)
  })
}

pl__select <- function(...) {
  pl$DataFrame()$select(...)
}

#' Alias for an element being evaluated in an eval expression
#'
#' @inherit as_polars_expr return
#' @examples
#' # A horizontal rank computation by taking the elements of a list:
#' df <- pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2)
#' )
#' df$with_columns(
#'   rank = pl$concat_list(c("a", "b"))$list$eval(pl$element()$rank())
#' )
#'
#' # A mathematical operation on array elements:
#' df <- pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, 2)
#' )
#' df$with_columns(
#'   a_b_doubled = pl$concat_list(c("a", "b"))$list$eval(pl$element() * 2)
#' )
pl__element <- function() {
  wrap({
    pl$col("")
  })
}
