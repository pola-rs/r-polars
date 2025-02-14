#' Get the minimum value horizontally across columns
#'
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]> Columns to aggregate
#' horizontally. Accepts expressions. Strings are parsed as column
#' names, other non-expression inputs are parsed as literals.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, NA),
#'   c = c("x", "y", "z")
#' )
#' df$with_columns(
#'   min = pl$min_horizontal("a", "b")
#' )
pl__min_horizontal <- function(...) {
  wrap({
    check_dots_unnamed()
    parse_into_list_of_expressions(...) |>
      min_horizontal()
  })
}

#' Get the maximum value horizontally across columns
#'
#' @inheritParams pl__min_horizontal
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 8, 3),
#'   b = c(4, 5, NA),
#'   c = c(1, 2, NA, Inf)
#' )
#' df$with_columns(
#'   max = pl$max_horizontal("a", "b")
#' )
pl__max_horizontal <- function(...) {
  wrap({
    check_dots_unnamed()
    parse_into_list_of_expressions(...) |>
      max_horizontal()
  })
}

#' Apply the AND logical horizontally across columns
#'
#' @inheritParams pl__min_horizontal
#'
#' @details
#' [Kleene logic](https://en.wikipedia.org/wiki/Three-valued_logic) is used to
#' deal with nulls: if the column contains any null values and no `FALSE`
#' values, the output is null.
#'
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = c(FALSE, FALSE, TRUE, TRUE, FALSE, NA),
#'   b = c(FALSE, TRUE, TRUE, NA, NA, NA),
#'   c = c("u", "v", "w", "x", "y", "z")
#' )
#'
#' df$with_columns(
#'   all = pl$all_horizontal("a", "b", "c")
#' )
pl__all_horizontal <- function(...) {
  wrap({
    check_dots_unnamed()
    parse_into_list_of_expressions(...) |>
      all_horizontal()
  })
}

#' Apply the OR logical horizontally across columns
#'
#' @inheritParams pl__min_horizontal
#' @inherit pl__all_horizontal details
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = c(FALSE, FALSE, TRUE, TRUE, FALSE, NA),
#'   b = c(FALSE, TRUE, TRUE, NA, NA, NA),
#'   c = c("u", "v", "w", "x", "y", "z")
#' )
#'
#' df$with_columns(
#'   any = pl$any_horizontal("a", "b", "c")
#' )
pl__any_horizontal <- function(...) {
  wrap({
    check_dots_unnamed()
    parse_into_list_of_expressions(...) |>
      any_horizontal()
  })
}

#' Compute the sum horizontally across columns
#'
#' @inheritParams pl__min_horizontal
#' @inherit as_polars_expr return
#' @param ignore_nulls A logical.
#' If `TRUE`, ignore null values (default). If `FALSE`,
#' any null value in the input will lead to a null output.
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 8, 3)
#'   b = c(4, 5, NA),
#'   c = c("x", "y", "z")
#' )
#' df$with_columns(
#'   sum = pl$sum_horizontal("a", "b")
#' )
pl__sum_horizontal <- function(..., ignore_nulls = TRUE) {
  wrap({
    check_dots_unnamed()
    parse_into_list_of_expressions(...) |>
      sum_horizontal(ignore_nulls = ignore_nulls)
  })
}

#' Compute the mean horizontally across columns
#'
#' @inheritParams pl__min_horizontal
#' @inheritParams pl__sum_horizontal
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, 8, 3)
#'   b = c(4, 5, NA),
#'   c = c("x", "y", "z")
#' )
#'
#' df$with_columns(
#'   mean = pl$mean_horizontal("a", "b")
#' )
pl__mean_horizontal <- function(..., ignore_nulls = TRUE) {
  wrap({
    check_dots_unnamed()
    parse_into_list_of_expressions(...) |>
      mean_horizontal(ignore_nulls = ignore_nulls)
  })
}
