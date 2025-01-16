pl__field <- function(...) {
  check_dots_unnamed()

  dots <- list2(...)
  check_list_of_string(dots, arg = "...")

  field(as.character(dots)) |>
    wrap()
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
  pl$col("")
}

#' Folds the columns from left to right, keeping the first non-null value
#' @inherit as_polars_expr return
#' @param ... <[`dynamic-dots`][rlang::dyn-dots]>
#' Non-named objects can be referenced as columns.
#' Each object will be converted to [expression] by [as_polars_expr()].
#' Strings are parsed as column names, other non-expression inputs are parsed as literals.
#' @examples
#' df <- pl$DataFrame(
#'   a = c(1, NA, NA, NA),
#'   b = c(1, 2, NA, NA),
#'   c = c(5, NA, 3, NA)
#' )
#'
#' df$with_columns(d = pl$coalesce("a", "b", "c", 10))
#'
#' df$with_columns(d = pl$coalesce(pl$col("a", "b", "c"), 10))
pl__coalesce <- function(...) {
  check_dots_unnamed()

  parse_into_list_of_expressions(...) |>
    coalesce() |>
    wrap()
}

#' Return indices where `condition` evaluates to `TRUE`
#'
#' @param condition Boolean expression to evaluate.
#' @inherit as_polars_expr return
#'
#' @examples
#' df <- pl$DataFrame(a = 1:5)
#' df$select(
#'   pl$arg_where(pl$col("a") %% 2 == 0)
#' )
pl__arg_where <- function(condition) {
  arg_where(as_polars_expr(condition)$`_rexpr`) |>
    wrap()
}
